package OpenAPI;

use strict;
use warnings;

#use Smart::Comments;
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper ();
use Lingua::EN::Inflect qw(PL ORD);
use List::Util qw(first);
use Params::Util qw(_HASH _STRING _ARRAY0 _SCALAR);
use Encode qw(decode_utf8 from_to encode decode);
use Data::Dumper;
use DBI;
use SQL::Select;
use SQL::Update;
use SQL::Insert;
use OpenAPI::Backend;
use OpenAPI::Limits;
#use encoding "utf8";

#$YAML::Syck::ImplicitBinary = 1;
our $Backend;

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
        ### $req_data
        if (!defined $req_data) {
            $req_data = $cgi->param('data') or
                die "No POST content specified.\n";
        }
    }
    elsif ($http_meth eq 'PUT') {
        $req_data = $cgi->param('PUTDATA');
        ### $req_data
        if (!defined $req_data) {
            $req_data = $cgi->param('data') or
                die "No PUT content specified.\n";
        }
    }
    ### OpenAPI->new url 1: $url
    if ($http_meth eq 'POST' and $url =~ s{^=/put/}{=/}) {
        $http_meth = 'PUT';
    } elsif ($http_meth =~ /^GET|POST$/ and $url =~ s{^=/delete/}{=/}) {
        $http_meth = 'DELETE';
    }
    ### OpenAPI->new url 2: $url
    $$rurl = $url;
    $self->{'_url'} = $url;
    $self->{'_http_method'} = $http_meth;

    if ($req_data) {
        from_to($req_data, $charset, 'UTF-8');
        $req_data = $self->parse_data($req_data);
    }

    $self->{_req_data} = $req_data;
}

sub error {
    my ($self, $s) = @_;
    $s =~ s/^Syck parser \(line (\d+), column (\d+)\): syntax error at .+/Syntax error found in the JSON input: line $1, column $2./;
    $s =~ s/^DBD::Pg::st execute failed:\s+ERROR:\s+//;
    #$s =~ s/^DBD::Pg::db do failed:\s.*?ERROR:\s+//;
    $self->{_error} .= $s . "\n";
### $self->{_error}
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
    };  warn $@ if $@;
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
    ### tables: @tables
    for my $table (@tables) {
        $self->drop_table($table);
    }
    return { success => 1 };
}

sub GET_model_list {
    my ($self, $bits) = @_;
    my $models = $self->get_models;
    $models ||= [];
    ### $models
    map { $_->{src} = "/=/model/$_->{name}" } @$models;
    $models;
}

sub GET_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    return $self->get_model_cols($model);
}

sub POST_model {
    my ($self, $bits) = @_;
    my $data = _HASH($self->{_req_data}) or
        die "The model schema must be a HASH.\n";
    my $model = $bits->[1];
    ### $model
    my $name;
    if ($name = $data->{name} and $name ne $model) {
        $self->warning("name \"$name\" in POST content ignored.");
    }
    $data->{name} = $model;
    return $self->new_model($data);
}

sub DELETE_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $table = lc($model);
    #$tables = $tables->[0];
    $self->drop_table($table);
    return { success => 1 };
}

sub GET_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    ### $model
    ### $col
    my $table_name = lc($model);
    my $select = SQL::Select->new( qw< name type label > )
                            ->from( '_columns' )
                            ->where( table_name => Q($table_name) )
                            ->where( name => Q($col) );
    my $res = $Backend->select("$select", { use_hash => 1 });
    if (!$res or !@$res) {
        die "Column '$col' not found.\n";
    }
    ### $res
    return $res->[0];
}

sub POST_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = $self->{_req_data};
    my $table_name = lc($model);

    my $num = $self->column_count;
    ### Column count: $num
    if ($num >= $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    $data = _HASH($data) or die "column spec must be a HASH.\n";

    # discard 'id' column
    if ($col eq 'id') {
        die "Column id is reserved.";
    }
    my $cols = $self->get_model_col_names($model);
    my $fst = first { lc($col) eq lc($_) } @$cols;
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
    my $sql = "alter table $table_name add column $col $ntype;\n";
    my $res = $Backend->do($sql . "$insert");
    return { success => 1, src => "/=/model/$model/$col" };
}

sub PUT_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = _HASH($self->{_req_data}) or die "column spec must be a HASH.\n";
    my $table_name = lc($model);

    # discard 'id' column
    if ($col eq 'id') {
        die "Column id is reserved.";
    }
    # type defaults to 'text' if not specified.
    my $sql;
    my $new_col = $data->{name};
    my $update_meta = SQL::Update->new('_columns');
    if ($new_col) {
        _IDENT($new_col) or die "Bad column name: ",
                $Dumper->($new_col), "\n";

        #$new_col = $new_col);
        $update_meta->set(name => Q($new_col));
        $sql .= "alter table $table_name rename column $col to $new_col;\n";
        #$col = $new_col;
    } else {
        $new_col = $col;
    }
    my $type = $data->{type};
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
        $sql .= "alter table $table_name alter column $new_col type $ntype;\n",
    }
    my $label = $data->{label};
    if ($label) {
        $update_meta->set(label => Q($label));
    }
    $update_meta->where(table_name => Q($table_name))
        ->where(name => Q($col));
    ### $sql
    my $res = $Backend->do($sql . $update_meta);
    ### $res
    return { success => $res ? 1 : 0 };
}

sub DELETE_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $table_name = lc($model);

    # discard 'id' column
    if ($col eq 'id') {
        die "Column id is reserved.";
    }
    my $sql = "delete from _columns where table_name='$table_name' and name='$col'; alter table $table_name drop column $col restrict;";
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
    my $select = SQL::Select->new('table_name')->from('_models');
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
    return $self->select("select count(*) from $table")->[0][0];
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
    my $table = lc($model);
    my $select = SQL::Select->new('description')
        ->from('_models')
        ->where(name => Q($model));
    my $list = $Backend->select("$select");
    my $desc = $list->[0][0];
    $select->reset('name', 'type', 'label')
           ->from('_columns')
           ->where(table_name => Q($table));
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
    my $table = lc($model);
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
    my $table = lc($model);
    ### Table: $table
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
        die "Unrecognized ",PL("key",scalar @key)," in model schema 'TTT': ",
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
        ->cols(qw< name type native_type label table_name >);
    $sql .=
        "create table $table (\n\tid serial primary key";
    my $sql2;
    my $found_id = undef;
    for my $col (@$columns) {
        _HASH($col) or die "Column definition must be a hash: ", $Dumper->($col), "\n";
        my $name = $col->{name} or
            die "No 'name' specified for the " . ORD($i) . " column.\n";
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
        my $type = $col->{type} || 'text';
        my $label = $col->{label} or
            die "No 'label' specified for column \"$name\" in model \"$model\".\n";
        my $ntype = $to_native_type{$type};
        if (!$ntype) {
            die "Invalid column type: $type\n",
                "\tOnly the following types are available: ",
                join(", ", sort keys %to_native_type), "\n";
        }
        $sql .= ",\n\t$name $ntype";
        $sql2 .= $insert->clone->values(Q($name, $type, $ntype, $label, $table));
        $i++;
    }
    $sql .= "\n)";
    ### $sql
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

sub has_model_col {
    my ($self, $model, $col) = @_;
    _IDENT($model) or die "Bad model name: $model\n";
    _IDENT($col) or die "Bad model column name: $col\n";
    my $table_name = lc($model);
    ### has model col (model):  $model
    ### has model col (col): $col
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
drop table $table;
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
    my $table = lc($model);
    if ($self->row_count($table) >= $RECORD_LIMIT) {
        die "Exceeded model row count limit: $RECORD_LIMIT.\n";
    }
    my $cols = $self->get_model_col_names($model);
    my $sql;
    my $insert = SQL::Insert->new($table)->cols(@$cols);

    if (ref $data eq 'HASH') { # record found
        ### Row inserted: $data
        my $num = insert_record($insert, $data, $cols, 1);
        #...
        my $last_id = $self->last_insert_id($table);
        return { rows_affected => $num, last_row => "/=/model/$model/id/$last_id", success => $num?1:0 };
    } elsif (ref $data eq 'ARRAY') {
        my $i = 0;
        my $rows_affected = 0;
        if (@$data > $INSERT_LIMIT) {
            die "You can only insert $INSERT_LIMIT rows at a time.\n";
        }
        for my $row_data (@$data) {
            if (!ref $row_data || ref $row_data ne 'HASH') {
                die "Malformed row data found in $i: Hash expected.\n";
            }
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
    my @vals;
    for my $col (@$cols) {
        push @vals, delete $row_data->{$col};
    }
    if (%$row_data) {
        die "Unknown column found in row $row_num: ",
            join(", ", keys %$row_data), "\n";
    }
    my $sql = $insert->clone->values(Q(@vals));
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
        ### $item
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
    my $offset = $self->{_cgi}->url_param('offset');
    return unless defined $offset;
    $offset ||= 0;
    if ($offset !~ /^\d+$/) {
        die "Invalid value for the \"offset\" param: $offset\n";
    }
    $select->offset($offset);
}

sub process_limit {
    my ($self, $select) = @_;
    my $cgi = $self->{_cgi};
    my $limit = $cgi->url_param('count');
    # limit is an alias for count
    if (!defined $limit) {
        $limit = $cgi->url_param('limit');
    }
    if (!defined $limit) {
        $select->limit($MAX_SELECT_LIMIT);
        return;
    }
    $limit ||= 0;
    if ($limit !~ /^\d+$/) {
        die "Invalid value for the \"count\" param: $limit\n";
    }
    if ($limit > $MAX_SELECT_LIMIT) {
        die "Value too large for the limit param: $limit\n";
    }
    $select->limit($limit);
}

sub select_records {
    my ($self, $model, $user_col, $val) = @_;
    my $table = lc($model);
    my $cols = $self->get_model_col_names($model);
    ### inside select_records: $self->{'_order_by'}
    if ($user_col ne 'id') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    my $select = SQL::Select->new;
    $select->from($table);
    if (defined $val) {
        $select->select('id', @$cols)
               ->where($user_col => Q($val));
    } else {
        $select->select($user_col);
    }
    $self->process_order_by($select, $model, $user_col);
    $self->process_offset($select);
    $self->process_limit($select);
    ### $val
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

    my $table = lc($model);
    my $select = SQL::Select->new('*')->from($table);

    $self->process_order_by($select, $model);
    $self->process_offset($select);
    $self->process_limit($select);
    ### Select all records SQL: "$select"

    my $list = $Backend->select("$select", { use_hash => 1 });
    if (!$list or !ref $list) { return []; }
    return $list;
}

sub delete_all_records {
    my ($self, $model) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = lc($model);
    my $retval = $Backend->do("delete from $table");
    return {success => 1,rows_affected => $retval+0};
}

sub delete_records {
    my ($self, $model, $user_col, $val) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = lc($model);
    my $cols = $self->get_model_col_names($model);
    if ($user_col ne 'id') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    #my $flds = join(",", @$cols);
    my $sql;
    if (defined $val) {
        $sql = "delete from $table where $user_col=" . Q($val);
    } else {
        $sql = "delete from $table";
    }
    ### $sql
    ### $val
    my $retval = $Backend->do($sql);
    return {success => 1,rows_affected => $retval+0};
}

sub update_records {
    my ($self, $model, $user_col, $val, $data) = @_;
    my $table = lc($model);
    my $cols = $self->get_model_col_names($model);
    if ($user_col ne 'id') {
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
    my $update = SQL::Update->new($table);
    while (my ($key, $val) = each %$data) {
        my $col = $key;
        if ($col eq 'id') {
            next;  # XXX maybe issue a warning?
        }
        $update->set($col => Q($val));
    }

    if (defined $val) {
        $update->where($user_col => $val);
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
    my $table = lc($model);
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
        my $new_table = lc($new_model);
        $sql .=
            "update _models set table_name='$new_table', name='$new_model' where name='$model';\n" .
            "update _columns set table_name='$new_table' where table_name='$table';\n" .
            "alter table $table rename to $new_table;\n";
    }
    if (my $desc = delete $data->{description}) {
        _STRING($desc) or die "Model descriptons must be strings.\n";
        $sql .= "update _models set description='$desc' where name='$new_model';\n"
    }
    if (%$data) {
        die "Unknown fields ", join(", ", keys %$data), "\n";
    }
    ### $sql
    my $retval = $Backend->do($sql);
    ### $retval
    return {success => 1};
}

sub global_model_check {
    my ($self, $rbits, $meth) = @_;
    ### Check model existence and column existence here...
    ### if method is not POST...
    ### method: $meth
    ### URL bits: $rbits
    my ($model, $col);
    if (@$rbits >= 2) {
        $model = $rbits->[1];
        _IDENT($model) or die "Bad model name: ", $Dumper->($model), "\n";
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
        if (@$rbits >= 3) {
            if (!$self->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
        }
    } else {
        ### Testing...
        if ($model) {
            if (!$self->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
        }
        if ($col and $col ne '~') {
            ### Testing 2...
            if (! $self->has_model_col($model, $col)) {
                ### Dying...
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

1;

