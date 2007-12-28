package OpenAPI;

use strict;
use warnings;

#use Smart::Comments;
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper ();
#use Lingua::EN::Inflect qw(PL ORD);
use List::Util qw(first);
use Params::Util qw(_HASH _STRING _ARRAY0 _ARRAY _SCALAR);
use Encode qw(decode_utf8 from_to encode decode);
use Data::Dumper;
use DBI;
use SQL::Select;
use SQL::Update;
use SQL::Insert;
use OpenAPI::Backend;
use OpenAPI::Limits;
use MiniSQL::Select;
#use encoding "utf8";

#$YAML::Syck::ImplicitBinary = 1;
our $Backend;

my %OpMap = (
    contains => 'like',
    gt => '>',
    ge => '>=',
    lt => '<',
    le => '<=',
    eq => '=',
    ne => '<>',
);

my %ext2dumper = (
    '.yml' => \&YAML::Syck::Dump,
    '.yaml' => \&YAML::Syck::Dump,
    '.js' => \&JSON::Syck::Dump,
    '.json' => \&JSON::Syck::Dump,
);

my %ext2importer = (
    '.yml' => \&YAML::Syck::Load,
    '.yaml' => \&YAML::Syck::Load,
    '.js' => \&JSON::Syck::Load,
    '.json' => \&JSON::Syck::Load,
);

my $Ext = qr/\.(?:js|json|xml|yaml|yml)/;
our ($Dumper, $Importer);
$Dumper = \&JSON::Syck::Dump;
$Importer = \&JSON::Syck::Load;

sub Q (@) {
    if (@_ == 1) {
        return $Backend->quote($_[0]);
    } else {
        return map { $Backend->quote($_) } @_;
    }
}

sub QI (@) {
    if (@_ == 1) {
        return $Backend->quote_identifier($_[0]);
    } else {
        return map { $Backend->quote_identifier($_) } @_;
    }
}

# XXX more data types...
our %to_native_type = (
    text => 'text',
    integer => 'integer',
    date => 'date',
    serial => 'serial',
    time => 'time',
    timestamp => 'timestamp',
    real => 'real',
    double => 'double precision',
);

sub parse_data {
    shift;
    if (!$Importer) {
        $Importer = \&JSON::Syck::Load;
    }
    return $Importer->($_[0]);
}

sub new {
    my ($class, $cgi) = @_;
    return bless { _cgi => $cgi, _charset => 'UTF-8' }, $class;
}

sub init {
    my ($self, $rurl) = @_;
    my $class = ref $self;
    my $cgi = $self->{_cgi};

    my $charset = $cgi->url_param('charset') || 'UTF-8';
    $self->{'_charset'} = $charset;

    my $var = $cgi->url_param('var');
    $self->{'_var'} = $var;

    my $offset = $cgi->url_param('offset');
    $offset ||= 0;
    if ($offset !~ /^\d+$/) {
        die "Invalid value for the \"offset\" param: $offset\n";
    }
    $self->{_offset} = $offset;

    my $limit = $cgi->url_param('count');
    # limit is an alias for count
    if (!defined $limit) {
        $limit = $cgi->url_param('limit');
    }
    if (!defined $limit) {
        $limit = $MAX_SELECT_LIMIT;
    } else {
        $limit ||= 0;
        if ($limit !~ /^\d+$/) {
            die "Invalid value for the \"count\" param: $limit\n";
        }
        if ($limit > $MAX_SELECT_LIMIT) {
            die "Value too large for the limit param: $limit\n";
        }
    }
    $self->{_limit} = $limit;

    my $http_meth = $ENV{'REQUEST_METHOD'};
    #$self->{'_method'} = $http_meth;

    #die "#XXXX !!!! $http_meth", Dumper($self);

    my $url = $$rurl;
    eval {
        from_to($url, $charset, 'UTF-8');
    };

    $url =~ s{/+$}{}g;
    $url =~ s/\%2A/*/g;
    if ($url =~ s/$Ext$//) {
        my $ext = $&;
        # XXX obsolete
        $self->set_formatter($ext);
    } else {
        $self->set_formatter;
    }
    my $req_data;
    if ($http_meth eq 'POST') {
        $req_data = $cgi->param('POSTDATA');

        if (!defined $req_data) {
            $req_data = $cgi->param('data') or
                die "No POST content specified.\n";
        } else {
            if (length($req_data) > $POST_LEN_LIMIT) {
                die "Exceeded POST content length limit: $POST_LEN_LIMIT\n";
            }
        }
    }
    elsif ($http_meth eq 'PUT') {
        $req_data = $cgi->param('PUTDATA');

        if (!defined $req_data) {
            $req_data = $cgi->param('data') or
                die "No PUT content specified.\n";
        } else {
            if (length($req_data) > $PUT_LEN_LIMIT) {
                die "Exceeded PUT content length limit: $PUT_LEN_LIMIT\n";
            }
        }
    }

    if ($http_meth eq 'POST' and $url =~ s{^=/put/}{=/}) {
        $http_meth = 'PUT';
    } elsif ($http_meth =~ /^(?:GET|POST)$/ and $url =~ s{^=/delete/}{=/}) {
        $http_meth = 'DELETE';
    } elsif ($http_meth =~ /^GET$/ and $url =~ s{^=/post/}{=/} ) {
        $http_meth = 'POST';
        $req_data = $cgi->url_param('data');
        #$req_data = $Importer->($content);

        #warn "Content: ", $Dumper->($content);
        #warn "Data: ", $Dumper->($req_data);
    }

    $$rurl = $url;
    $self->{'_url'} = $url;
    $self->{'_http_method'} = $http_meth;

    if ($req_data) {
        from_to($req_data, $charset, 'UTF-8');
        $req_data = $self->parse_data($req_data);
    }

    $self->{_req_data} = $req_data;
}

sub fatal {
    my ($self, $s) = @_;
    $self->error($s);
    $self->response();
}

sub error {
    my ($self, $s) = @_;
    $s =~ s/^Syck parser \(line (\d+), column (\d+)\): syntax error at .+/Syntax error found in the JSON input: line $1, column $2./;
    $s =~ s/^DBD::Pg::st execute failed:\s+ERROR:\s+//;
    #$s =~ s/^DBD::Pg::db do failed:\s.*?ERROR:\s+//;
    $self->{_error} .= $s . "\n";

}

sub data {
    $_[0]->{_data} = $_[1];
}

sub warning {
    $_[0]->{_warning} = $_[1];
}

sub response {
    my $self = shift;
    my $charset = $self->{_charset};
    my $cgi = $self->{_cgi};
    print $cgi->header(-type => "text/plain; charset=$charset");
    my $str = '';
    if ($self->{_error}) {
        $str = $self->emit_error($self->{_error});
    } elsif ($self->{_data}) {
        my $data = $self->{_data};
        if ($self->{_warning}) {
            $data->{warning} = $self->{_warning};
        }
        $str = $self->emit_data($data);
    }
    #die $charset;
    # XXX if $charset is 'UTF-8' then don't bother decoding and encoding...
    eval {
        #$str = decode_utf8($str);
        from_to($str, 'UTF-8', $charset);
    }; #warn $@ if $@;
    if (my $var = $self->{_var} and $Dumper eq \&JSON::Syck::Dump) {
        $str = "var $self->{_var}=$str;";
    }
    $str =~ s/\n+$//s;
    print $str, "\n";
}

sub DELETE_model_list {
    my ($self, $bits) = @_;
    my $res = $self->get_tables();
    if (!$res) {
        return { success => 1 };
    }; # no-op
    my @tables = map { @$_ } @$res;
    #$tables = $tables->[0];

    for my $table (@tables) {
        $self->drop_table($table);
    }
    return { success => 1 };
}

sub GET_model_list {
    my ($self, $bits) = @_;
    my $models = $self->get_models;
    $models ||= [];

    map { $_->{src} = "/=/model/$_->{name}" } @$models;
    $models;
}

sub GET_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    #
    # TODO: need to deal with '~'
    #
    return $self->get_model_cols($model);
}

sub POST_model {
    my ($self, $bits) = @_;
    my $data = _HASH($self->{_req_data}) or
        die "The model schema must be a HASH.\n";
    my $model = $bits->[1];

    my $name;
    if ($model eq '~') {
        $model = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $model) {
        $self->warning("name \"$name\" in POST content ignored.");
    }
    $data->{name} = $model;
    return $self->new_model($data);
}

sub DELETE_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $table = $model;
    #$tables = $tables->[0];
    $self->drop_table($table);
    return { success => 1 };
}

sub GET_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];

    my $table_name = $model;

    my $select = SQL::Select->new(qw< name type label >, '"default"')
            ->from('_columns')
            ->where(table_name => Q($table_name))
            ->order_by('id');
    if ($col eq '~') {
        my $list = $Backend->select("$select", { use_hash => 1 });
        if (!$list or !ref $list) { $list = []; }
        unshift @$list, { name => 'id', type => 'serial', label => 'ID' };
        return $list;
    } else {
        $select->where( name => Q($col) );
        my $res = $Backend->select("$select", { use_hash => 1 });
        if (!$res or !@$res) {
            die "Column '$col' not found.\n";
        }

        return $res->[0];
    }
}

sub POST_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = $self->{_req_data};
    my $table_name = $model;

    my $num = $self->column_count;

    if ($num >= $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    $data = _HASH($data) or die "column spec must be a HASH.\n";
    if ($col eq 'id') {
        die "Column id is reserved.";
    }
    if ($col eq '~') {
         $col = $data->{name} || die "you must provide the new the column with a name!";
    }

    my $alias = $data->{name};
    my $cols = $self->get_model_col_names($model);
    my $fst = first { $col eq $_ } @$cols;
    if (defined $fst) {
        die "Column '$col' already exists in model '$model'.\n";
    }
    # type defaults to 'text' if not specified.
    my $type = $data->{type} || 'text';
    my $label = $data->{label} or
        die "No 'label' specified for column \"$col\" in model \"$model\".\n";
    my $ntype = $to_native_type{$type};
    if (!$ntype) {
        die "Bad column type: $type\n",
            "\tOnly the following types are available: ",
            join(", ", sort keys %to_native_type), "\n";
    }

    my $insert = SQL::Insert->new('_columns')
        ->cols(qw< name label type native_type table_name >)
        ->values( Q($col, $label, $type, $ntype, $table_name) );

    my $default = delete $data->{default};
    if (defined $default) {
        $default = $self->process_default($default);
        $insert->cols('"default"')->values(Q($default));
    }
    $default ||= 'null';

    my $sql = "alter table \"$table_name\" add column \"$col\" $ntype default $default;\n";
    $sql .= "$insert";

    my $res = $Backend->do($sql);

    return { success => 1,
             src => "/=/model/$model/$col",
             warning => "Column name \"$alias\" Ignored."
     } if $alias && $alias ne $col;
    return { success => 1, src => "/=/model/$model/$col" };
}

sub PUT_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = _HASH($self->{_req_data}) or
        die "column spec must be a non-empty HASH.\n";
    my $table_name = $model;

    # discard 'id' column
    if (lc($col) eq 'id') {
        die "Column id is reserved.";
    }
    # type defaults to 'text' if not specified.
    my $sql;
    my $new_col = delete $data->{name};
    my $update_meta = SQL::Update->new('_columns');
    if ($new_col) {
        _IDENT($new_col) or die "Bad column name: ",
                $Dumper->($new_col), "\n";

        #$new_col = $new_col);
        $update_meta->set(name => Q($new_col));
        $sql .= "alter table \"$table_name\" rename column \"$col\" to \"$new_col\";\n";
        #$col = $new_col;
    } else {
        $new_col = $col;
    }
    my $type = delete $data->{type};
    my $ntype;
    if ($type) {
        die "Changing column type is not supported.\n";
        $ntype = $to_native_type{$type};
        if (!$ntype) {
            die "Bad column type: $type\n",
                "\tOnly the following types are available: ",
                join(", ", sort keys %to_native_type), "\n";
        }
        $update_meta->set(type => Q($type))
            ->set(native_type => Q($ntype));
        $sql .= "alter table \"$table_name\" alter column \"$new_col\" type $ntype;\n",
    }

    my $label = delete $data->{label};
    if (defined $label) {
        _STRING($label) or die "Lable must be a non-empty string: ",
            $Dumper->($label);
        $update_meta->set(label => Q($label));
    }

    my $default = delete $data->{default};
    if (defined $default) {
        $default = $self->process_default($default);

        $update_meta->set(QI('default') => Q($default));
        $sql .= "alter table \"$table_name\" alter column \"$new_col\" set default $default;\n",
    }

    $update_meta->where(table_name => Q($table_name))
        ->where(name => Q($col));

    $sql .= $update_meta;

    my $res = $Backend->do($sql);

    return { success => $res ? 1 : 0 };
}

sub DELETE_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $table_name = $model;

    # discard 'id' column
    if (lc($col) eq 'id') {
        die "Column \"id\" is reserved.\n";
    }
    my $sql = '';

    if($col eq '~') {
         $self->warning("Column \"id\" is reserved.");
	 my $columns = $self->get_model_col_names($model);
	 for my $c (@$columns) {
              $sql .= "delete from _columns where table_name = '$table_name' and name='$c';" .
                      "alter table \"$table_name\" drop column \"$c\" restrict;";
         }
    } else {
        $sql = "delete from _columns where table_name='$table_name' and name='$col'; alter table \"$table_name\" drop column \"$col\" restrict;";
    }
    my $res = $Backend->do($sql);
    return { success => $res > -1? 1:0 };
}

# alter table $table_name rename column $col TO city;
sub POST_model_row {
    my ($self, $bits) = @_;
    my $data = $self->{_req_data};
    my $model = $bits->[1];

    return $self->insert_records($model, $data);
}

sub GET_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];

    if ($column ne '~' and $value ne '~') {
        return $self->select_records($model, $column, $value);
    }
    if ($column ne '~' and $value eq '~') {
        return $self->select_records($model, $column);
    }
    if ($column eq '~' and $value eq '~') {
        return $self->select_all_records($model);
    }
    if ($column eq '~') {
        return $self->select_records($model, $column, $value);
    } else {
        return { success => 0, error => "Unsupported operation." };
    }
}

sub DELETE_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    if ($column eq '~' and $value eq '~') {
        return $self->delete_all_records($model);
    }

    return $self->delete_records($model, $column, $value);
}

sub PUT_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    my $data = $self->{_req_data};
    return $self->update_records($model, $column, $value, $data);
}

sub PUT_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $data = $self->{_req_data};
    return $self->alter_model($model, $data);
}

sub POST_view{
    my ($self, $bits) = @_;
    my $data = _HASH($self->{_req_data}) or
        die "The view schema must be a HASH.\n";
    my $view = $bits->[1];

    my $name;
    if ($view eq '~') {
        $view = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $view) {
        $self->warning("name \"$name\" in POST content ignored.");
    }
    $data->{name} = $view;
    return $self->new_view($data);
}

sub get_views {
    my $self = shift;
    my $select = SQL::Select->new('name','definition', 'description')->from('_views');

    return $Backend->select("$select", { use_hash => 1 });
}

sub GET_view_list {
    my ($self, $bits) = @_;
    my $views = $self->get_views;
    $views ||= [];

    map { $_->{src} = "/=/view/$_->{name}" } @$views;
    $views;
}

sub GET_view {
    my ($self, $bits) = @_;
    my $view = $bits->[1];

    if($view eq '~'){
	return $self->get_views;
    }
    if(!$self->has_view($view)){
	die "View \"$view\" not found.\n";
    }
    my $select = SQL::Select->new('name','definition', 'description')->from('_views')->where('name', '=', Q($view));

    return $Backend->select("$select", {use_hash => 1})->[0];
}

sub exec_view{
    my ($self,$view, $bits, $cgi) = @_;
    my $select = MiniSQL::Select->new;
    my $sql = "select definition from _views where name =".Q($view);
    ### laser exec_view: "$sql"
    my $view_def = $self->select($sql)->[0][0];
    my $fix_var = $bits->[2];
    my $fix_var_value = $bits->[3];
    my $exists;
    my %vars;

    my $res;
    
    foreach my $var ($cgi->url_param){
	$vars{$var}=$cgi->url_param($var);
    }

    if($fix_var ne '~' and $fix_var_value ne '~'){
	$vars{$fix_var} = $fix_var_value;
    }

    eval {
        $res = $select->parse(
            $view_def,
            { quote => \&quote, vars => \%vars }
        );
    };

    return $self->select($res->{sql}, {use_hash=>1, read_only=>1});

}

sub GET_view_exec{
    my ($self,$bits) = @_;
    my $view = $bits->[1];
    die "View \"$view\" not found.\n" if (!$self->has_view($view));
    return $self->exec_view($view, $bits, $self->{_cgi});
}

sub GET_view_exec_with_param{
    my ($self,$bits) = @_;
    my $view = $bits->[1];

    die "View \"$view\" not found.\n" if (!$self->has_view($view));
    return $self->exec_view($view, $bits, $self->{_cgi});
}

sub view_count{
    my $self = shift;
    return $self->select("select count(*) from _views")->[0][0];
}

sub new_view{
    my ($self, $data) = @_;
    my $nviews = $self->view_count;
    my $res;
    if ($nviews >= $VIEW_LIMIT) {
        #warn "===================================> $num\n";
        die "Exceeded view count limit $VIEW_LIMIT.\n";
    }
    my $select = MiniSQL::Select->new;
    my $sql = $data->{body};
    
    eval {
        $res = $select->parse(
            $sql,
            { quote => \&quote }
        );
    };

    #
    # check to see if modes exists
    #
    my @models = @{$res->{models}};

    foreach my $model (@models){
	if (!$self->has_model($model)) {
        	die "Model \"$model\" not found.\n";
    	}
    }

    my $insert = SQL::Insert->new('_views')->cols(qw<name definition description>)
		->values(Q($data->{name},$data->{body},$data->{description}));

    return $Backend->do($insert) >=0 ?  { success => 1 } : { success => 0};

}

sub DELETE_view {
    my ($self, $bits) = @_;
    my $view = $bits->[1];
    undef $view if ($view eq '~');
    my $sql = defined $view ? "delete from _views where name ='".$view."';" : "truncate _views;";

    return $Backend->do($sql) >= 0 ? { success => 1 } : { success => 0};
}

sub DELETE_view_list {
    my ($self, $bits) = @_;
    my $view = $bits->[1];
    my $sql = defined $view ? "delete from _views where name ='".$view."';" : "truncate _views;";

    return $Backend->do($sql) >= 0 ? { success => 1 } : { success => 0};
}

sub set_formatter {
    my ($self, $ext) = @_;
    $ext ||= '.json';
    $Dumper = $ext2dumper{$ext};
    $Importer = $ext2importer{$ext};
}

sub connect {
    shift;
    my $backend = shift; 
    $Backend = OpenAPI::Backend->new($backend);
}

sub get_tables {
    #my ($self, $user) = @_;
    my $self = shift;
    my $select = SQL::Select->new('name')->from('_models');
    return $Backend->select("$select");
}

sub model_count {
    my $self = shift;
    return $self->select("select count(*) from _models")->[0][0];
}

sub column_count {
    my $self = shift;
    return $self->select("select count(*) from _columns")->[0][0];
}

sub row_count {
    my ($self, $table) = @_;
    return $self->select("select count(*) from \"$table\"")->[0][0];
}

sub get_models {
    my $self = shift;
    my $select = SQL::Select->new('name','description')->from('_models');
    return $Backend->select("$select", { use_hash => 1 });
}

sub get_model_cols {
    my ($self, $model) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = $model;
    my $select = SQL::Select->new('description')
        ->from('_models')
        ->where(name => Q($model));
    my $list = $Backend->select("$select");
    my $desc = $list->[0][0];
    $select->reset( QI(qw< name type label default >) )
           ->from('_columns')
           ->where(table_name => Q($table))
           ->order_by('id');
    $list = $Backend->select("$select", { use_hash => 1 });
    if (!$list or !ref $list) { $list = []; }
    unshift @$list, { name => 'id', type => 'serial', label => 'ID' };
    return { description => $desc, name => $model, columns => $list };
}

sub get_model_col_names {
    my ($self, $model) = @_;

    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = $model;
    my $select = SQL::Select->new('name')
        ->from('_columns')
        ->where(table_name => Q($table));

    my $list = $Backend->select("$select");
    if (!$list or !ref $list) { return []; }
    return [map { @$_ } @$list];
}

sub emit_data {
    my ($self, $data) = @_;
    return $Dumper->($data);
}

sub has_user {
    my ($self, $user) = @_;
    return $Backend->has_user($user);
}

sub add_user {
    my ($self, $user) = @_;
    $Backend->add_user($user);
}

sub new_model {
    my ($self, $data) = @_;
    my $nmodels = $self->model_count;
    if ($nmodels >= $MODEL_LIMIT) {
        #warn "===================================> $num\n";
        die "Exceeded model count limit $MODEL_LIMIT.\n";
    }
    my $model = delete $data->{name} or
        die "No 'name' field found for the new model\n";
    my $table = $model;

    my $description = delete $data->{description} or
        die "No 'description' specified for model \"$model\".\n";
    die "Bad 'description' value: ", $Dumper->($description), "\n"
        unless _STRING($description);

    # XXX Should we allow 0 column table here?
    if (!ref $data) {
        die "Malformed data. Hash or Array expected.\n";
    }

    my $columns = delete $data->{columns};
    if (_HASH($columns)) { $columns = [$columns] }
    if ($columns && !_ARRAY0($columns)) {
        die "Invalid 'columns' value: ", $Dumper->($columns), "\n";
    } elsif (!$columns) {
        $self->warning("No 'columns' specified for model \"$model\".");
        $columns = [];
    } elsif (!@$columns) {
        $self->warning("'columns' empty for model \"$model\".");
    }
    if (@$columns > $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    if (%$data) {
    my @key = sort(keys %$data);
        die "Unrecognized keys in model schema 'TTT': ",
            join(", ", @key),"\n";
    }
    my $i = 1;
    if ($self->has_model($model)) {
        die "Model \"$model\" already exists.\n";
    }
    my $insert = SQL::Insert->new('_models')
        ->cols(qw< name table_name description >)
        ->values( Q($model, $table, $description) );

    my $sql = "$insert";
    $insert->reset('_columns')
        ->cols(QI( qw<name type native_type label table_name> ));
    $sql .=
        "create table \"$table\" (\n\t\"id\" serial primary key";
    my $sql2;
    my $found_id = undef;
    for my $col (@$columns) {
        _HASH($col) or die "Column definition must be a hash: ", $Dumper->($col), "\n";
        my $name = delete $col->{name} or
            die "No 'name' specified for the column $i.\n";
        _STRING($name) or die "Bad column name: ", $Dumper->($name), "\n";
        _IDENT($name) or die "Bad column name: $name\n";
        if (length($name) >= 32) {
            die "Column name too long: $name\n";
        }
        #$name = $name;
        # discard 'id' column
        if (lc($name) eq 'id') {
            $found_id = 1;
            next;
        }
        # type defaults to 'text' if not specified.
        my $type = delete $col->{type} || 'text';
        my $label = $col->{label} or
            die "No 'label' specified for column \"$name\" in model \"$model\".\n";

        my $default = delete $col->{default};
        my $ntype = $to_native_type{$type};
        if (!$ntype) {
            die "Invalid column type: $type\n",
                "\tOnly the following types are available: ",
                join(", ", sort keys %to_native_type), "\n";
        }
        $sql .= ",\n\t\"$name\" $ntype";
        my $ins = $insert->clone
            ->values(Q($name, $type, $ntype, $label, $table));
        if (defined $default) {
            $default = $self->process_default($default);
            # XXX
            $sql .= " default $default";
            $ins->cols(QI('default'))
                ->values(Q($default));
        }
        $sql2 .= $ins;
        $i++;
    }
    $sql .= "\n);\ngrant select on table \"$table\" to anonymous;\n";
   #warn $sql, "\n";

    #register_table($table);
    #register_columns
    eval {
        $self->do($sql2 . $sql);
    };
    if ($@) {
        die "Failed to create model \"$model\": $@\n";
    }
    return {
        success => 1,
        $found_id ? (warning => "Column \"id\" reserved. Ignored.") : ()
    };
}


sub process_default {
    my ($self, $default) = @_;
    if (_STRING($default or $default eq '0')) {
        return Q($default);
    } elsif (_ARRAY($default)) {
        my $func = shift @$default;
        _STRING($func) or
            die "Invalid \"default\" value: ", $Dumper->($default), "\n";
        $func = lc($func);
        if ($func eq 'now') {
            return "now()";
        } else {
            die "Unknown function for \"default\": ", $Dumper->($func);
        }
    } else {
        die "Invalid \"default\" value: ", $Dumper->($default), "\n";
    }
}

sub has_model {
    my ($self, $model) = @_;
    _IDENT($model) or die "Bad model name: $model\n";
    my $retval;
    my $select = SQL::Select->new('name')
        ->from('_models')
        ->where(name => Q($model))
        ->limit(1);
    eval {
        $retval = $self->do("$select");
    };
    return $retval + 0;
}

sub has_view {
    my ($self, $view) = @_;
    _IDENT($view) or die "Bad model name: $view\n";
    my $retval;
    my $select = SQL::Select->new('name')
        ->from('_views')
        ->where(name => Q($view))
        ->limit(1);
    eval {
        $retval = $self->do("$select");
    };
    return $retval + 0;
}

sub has_model_col {
    my ($self, $model, $col) = @_;
    _IDENT($model) or die "Bad model name: $model\n";
    _IDENT($col) or die "Bad model column name: $col\n";
    my $table_name = $model;

    return 1 if $col eq 'id';
    my $res;
    my $select = SQL::Select->new('name')
        ->from('_columns')
        ->where(table_name => Q($table_name))
        ->where(name => Q($col))
        ->limit(1);
    eval {
        $res = $self->do("$select");
    };
    return $res + 0;
}

sub drop_table {
    my ($self, $table) = @_;
    $self->do(<<_EOC_);
drop table if exists "$table";
delete from _models where table_name='$table';
delete from _columns where table_name='$table';
_EOC_
}

sub drop_user {
    my ($self, $user) = @_;
    $Backend->drop_user($user);
}

sub emit_success {
    my $self = shift;
    return $self->emit_data( { success => 1 } );
}

sub emit_error {
    my $self = shift;
    my $msg = shift;
    $msg =~ s/\n+$//s;
    return $self->emit_data( { success => 0, error => $msg } );
}

sub selectall_hashref {
    my $self = shift;
    if (!$Backend) {
        die "No database handler found.\n";
    }
    return $Backend->selectall_hashref(@_);
}

sub insert_records {
    my ($self, $model, $data) = @_;
    if (!ref $data) {
        die "Malformed data: Hash or Array expected\n";
    }
    ## Data: $data
    my $table = $model;
    if ($self->row_count($table) >= $RECORD_LIMIT) {
        die "Exceeded model row count limit: $RECORD_LIMIT.\n";
    }

    my $cols = $self->get_model_col_names($model);
    my $sql;
    my $insert = SQL::Insert->new(QI($table));

    if (ref $data eq 'HASH') { # record found

        my $num = insert_record($insert, $data, $cols, 1);

        my $last_id = $self->last_insert_id($table);

        return { rows_affected => $num, last_row => "/=/model/$model/id/$last_id", success => $num?1:0 };
    } elsif (ref $data eq 'ARRAY') {
        my $i = 0;
        my $rows_affected = 0;
        if (@$data > $INSERT_LIMIT) {
            die "You can only insert $INSERT_LIMIT rows at a time.\n";
        }
        for my $row_data (@$data) {
            _HASH($row_data) or
                die "Bad data in row $i: ", $Dumper->($row_data), "\n";
            $rows_affected += insert_record($insert, $row_data, $cols, $i);
            $i++;
        }
        my $last_id = $self->last_insert_id($table);
        return { rows_affected => $rows_affected, last_row => "/=/model/$model/id/$last_id", success => $rows_affected?1:0 };
    } else {
        die "Malformed data: Hash or Array expected.\n";
    }
}

sub insert_record {
    my ($insert, $row_data, $cols, $row_num) = @_;
    $insert = $insert->clone;
    my $found = 0;
    while (my ($col, $val) = each %$row_data) {
        _IDENT($col) or
            die "Bad column name in row $row_num: ", $Dumper->($col), "\n";
        $insert->cols(QI($col));
        $insert->values(Q($val));
        $found = 1;
    }
    if (!$found) {
        die "No column specified in row $row_num.\n";
    }
    my $sql = "$insert";

    return $Backend->do($sql);
}

sub process_order_by {
    my ($self, $select, $model) = @_;
    my $order_by = $self->{_cgi}->url_param('order_by');
    return unless defined $order_by;
    die "No column found in order_by.\n" if $order_by eq '';
    my @sub_order_by = split ',', $order_by;
    if (!@sub_order_by and $order_by) {
        die "Invalid order_by value: $order_by\n";
    }
    foreach my $item (@sub_order_by){

        my ($col, $dir) = split ':', $item, 2;
        die "No column \"$col\" found in order_by.\n"
            unless $self->has_model_col($model, $col);
        $dir = lc($dir) if $dir;
        die "Invalid order_by direction: $dir\n"
            if $dir and $dir ne 'asc' and $dir ne 'desc';
        $select->order_by($col => $dir || ());
    }
}

sub process_offset {
    my ($self, $select) = @_;
    my $offset = $self->{_offset};
    if ($offset) {
        $select->offset($offset);
    }
}

sub process_limit {
    my ($self, $select) = @_;
    my $limit = $self->{_limit};
    if (defined $limit) {
        $select->limit($limit);
    }
}

sub select_records {
    my ($self, $model, $user_col, $val) = @_;
    my $table = $model;
    my $cols = $self->get_model_col_names($model);

    if (lc($user_col) ne 'id' and $user_col ne '~') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    my $select = SQL::Select->new;
    $select->from(QI($table));
    if (defined $val and $val ne '~') {
        my $op = $self->{_cgi}->url_param('op') || 'eq';
        $op = $OpMap{$op};
        if ($op eq 'like') {
            $val = "%$val%";
        }
        $select->select('id', QI(@$cols));
        if ($user_col eq '~') {
            # XXX
            $select->op('or');
            for my $col (@$cols) {
                $select->where($col => $op => Q($val));
            }
        } else {
            $select->where(QI($user_col) => $op => Q($val));
        }
    } else {
        $select->select($user_col);
    }
    $self->process_order_by($select, $model, $user_col);
    $self->process_offset($select);
    $self->process_limit($select);

    my $res = $Backend->select("$select", { use_hash => 1 });
    if (!$res and !ref $res) { return []; }
    return $res;
}

sub select_all_records {
    my ($self, $model) = @_;
    my $order_by = $self->{'_order_by'};

    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }

    my $table = $model;
    my $select = SQL::Select->new('*')->from(QI($table));

    $self->process_order_by($select, $model);
    $self->process_offset($select);
    $self->process_limit($select);

    my $list = $Backend->select("$select", { use_hash => 1 });
    if (!$list or !ref $list) { return []; }
    return $list;
}

sub delete_all_records {
    my ($self, $model) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = $model;
    my $retval = $Backend->do("delete from \"$table\"");
    return {success => 1,rows_affected => $retval+0};
}

sub delete_records {
    my ($self, $model, $user_col, $val) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = $model;
    my $cols = $self->get_model_col_names($model);
    if (lc($user_col) ne 'id') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    #my $flds = join(",", @$cols);
    my $sql;
    if (defined $val) {
        $sql = "delete from \"$table\" where \"$user_col\"=" . Q($val);
    } else {
        $sql = "delete from \"$table\"";
    }

    my $retval = $Backend->do($sql);
    return {success => 1,rows_affected => $retval+0};
}

sub update_records {
    my ($self, $model, $user_col, $val, $data) = @_;
    my $table = $model;
    my $cols = $self->get_model_col_names($model);
    if ($user_col ne 'id' && $user_col ne '~') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        #my $flds = join(",", @$cols);
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    if (!ref $data || ref $data ne 'HASH') {
        die "HASH data expected in the content body.\n";
    }
    my $update = SQL::Update->new(QI($table));
    while (my ($key, $val) = each %$data) {
        my $col = $key;
        if ($col eq 'id') {
            next;  # XXX maybe issue a warning?
        }
        $update->set(QI($col) => Q($val));
    }

    if (defined $val and $val ne '~') {
        $update->where(QI($user_col) => $val);
    }
    my $retval = $Backend->do("$update") + 0;
    return {success => $retval ? 1 : 0,rows_affected => $retval};
}

sub get_putdata {
    my $self = shift;
    my $putData = shift;
    if (my $contentLength = $ENV{'CONTENT_LENGTH'}) {
        &CGI::read_from_client(undef, \*STDIN, \$putData, $contentLength, 0);
        #$ENV{'REQUEST_METHOD'} = 'GET';
    }
}

sub _IDENT {
    (defined $_[0] && $_[0] =~ /^[A-Za-z]\w*$/) ? $_[0] : undef;
}

sub alter_model {
    my $self = $_[0];
    my $model = _IDENT($_[1]) or die "Invalid model name \"$_[1]\".\n";
    my $data = _HASH($_[2]) or die "HASH expected in the PUT content.\n";
    my $table = $model;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }

    my $sql;
    my $new_model = $model;
    if ($new_model = delete $data->{name}) {
        _IDENT($new_model) or die "Invalid model name \"$new_model\"\n";
        if ($self->has_model($new_model)) {
            die "Model \"$new_model\" already exists.\n";
        }
        my $new_table = $new_model;
        $sql .=
            "update _models set table_name='$new_table', name='$new_model' where name='$model';\n" .
            "update _columns set table_name='$new_table' where table_name='$table';\n" .
            "alter table \"$table\" rename to \"$new_table\";\n";
    }
    if (my $desc = delete $data->{description}) {
        _STRING($desc) or die "Model descriptons must be strings.\n";
        $sql .= "update _models set description='$desc' where name='$new_model';\n"
    }
    if (%$data) {
        die "Unknown fields ", join(", ", keys %$data), "\n";
    }

    my $retval = $Backend->do($sql);

    return {success => 1};
}

sub global_model_check {
    my ($self, $rbits, $meth) = @_;
         #warn "$meth: {@$rbits}\n";

    my ($model, $col);
    if (@$rbits >= 2) {
        $model = $rbits->[1];
        _IDENT($model) or $model eq '~' or die "Bad model name: ", $Dumper->($model), "\n";
        if (length($model) >= 32) {
            die "Model name too long: $model\n";
        }
    }
    if (@$rbits >= 3) {
        # XXX check column name here...
        $col = $rbits->[2];
        (_IDENT($col) || $col eq '~') or die "Bad column name: ", $Dumper->($col), "\n";
    }

    if ($meth eq 'POST') {
            #warn "hello {@$rbits}";
        if (@$rbits >= 3 and $model ne '~') {
            if (!$self->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
 #(_IDENT($col) || $col eq '~') or die "Column '$col' not found.\n";
        }
    } else {

        if ($model and $model ne '~') {
            if (!$self->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
        }
        #
        if ($col and $col ne '~') {
            if ($model ne '~' and ! $self->has_model_col($model, $col)) {
                die "Column '$col' not found.\n";
            }
        }
    }
}

sub set_user {
    my $user = pop;
    $Backend->set_user($user);
}

sub do {
    my $self = shift;
    $Backend->do(@_);
}

sub select {
    my $self = shift;
    $Backend->select(@_);
}

sub last_insert_id {
    my $self = shift;
    $Backend->last_insert_id(@_);
}

sub POST_admin_op {
    my ($self, $bits) = @_;
    my $op = $bits->[1];
    if ($op ne 'select' and $op ne 'do') {
        die "Admin operation not supported: $op\n";
    }
    ### $op
    my $sql = _STRING($self->{_req_data}) or
        die "SQL literal must be a string.\n";

    if ($op eq 'select') {
        return $self->select($sql, { use_hash => 1 });
    } elsif ($op eq 'do') {
        $self->do($sql);
        return { success => 1 };
    }
}

sub POST_action_exec {
    my ($self, $bits) = @_;
    my $action = $bits->[1];
    my $params = {
        $bits->[2] => $bits->[3]
    };
    my $lang = $params->{lang};
    if (!defined $lang) {
        die "The 'lang' param is required in the Select action.\n";
    }
    if (lc($lang) ne 'minisql') {
        die "Only the miniSQL language is supported for Select.\n";
    }
    my $sql = $self->{_req_data};

    warn "$sql";
    _STRING($sql) or
        die "miniSQL must be an non-empty literal string: ", $Dumper->($sql), "\n";
   #warn "SQL 1: $sql\n";
    my $select = MiniSQL::Select->new;
    my $res = $select->parse($sql, { quote => \&Q, limit => $self->{_limit}, offset => $self->{_offset} });
    if (_HASH($res)) {
        my $sql = $res->{sql};
        $sql = $self->append_limit_offset($sql, $res);
        my @models = @{ $res->{models} };
        my @cols = @{ $res->{columns} };
        $self->validate_model_names(\@models);
        $self->validate_col_names(\@models, \@cols);
       #warn "SQL 2: $sql\n";
        $self->select("$sql", {use_hash => 1, read_only => 1});
    }
}

sub append_limit_offset {
    my ($self, $sql, $res) = @_;
    #my $order_by $cgi->url
    my $limit = $res->{limit};
    if (defined $limit) {
        $sql =~ s/;\s*$/ limit $limit/s or
            $sql .= " limit $limit";
    }
    my $offset = $res->{offset};
    if (defined $offset) {
        $sql =~ s/;\s*$/ offset $offset;/s or
            $sql .= " offset $offset";
    }
    return "$sql;\n";
}

sub validate_model_names {
    my ($self, $models) = @_;
    for my $model (@$models) {
        _IDENT($model) or die "Bad model name: \"$model\"\n";
        if (!$self->has_model($model)) {
            die "Model \"$model\" not found.\n";
        }
    }
}

sub validate_col_names {
    my ($self, $models, $cols) = @_;
    # XXX TODO...
}

1;

