package OpenAPI;

use strict;
use warnings;

use Smart::Comments;
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper ();
use Lingua::EN::Inflect qw( ORD);
use List::Util qw(first);
use Params::Util qw(_HASH _STRING _ARRAY _SCALAR);
use Encode qw(decode_utf8 from_to encode decode);
#use encoding "utf8";

#$YAML::Syck::ImplicitBinary = 1;

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
our ($dbh, $Dumper, $Importer);
$Dumper = \&JSON::Syck::Dump;
$Importer = \&JSON::Syck::Load;

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
    my ($class, $rurl, $cgi) = @_;
    my $charset = $cgi->url_param('charset') || 'UTF-8';
    my $var = $cgi->url_param('var');
    my $url = $$rurl;
    $url =~ s{/+$}{}g;
    $url =~ s/\%2A/*/g;
    from_to($url, $charset, 'UTF-8');
    if ($url =~ s/$Ext$//) {
        my $ext = $&;
        # XXX obsolete
        $class->set_formatter($ext);
    }
    my $http_meth = $ENV{'REQUEST_METHOD'};
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
    ### $url
    if ($http_meth eq 'POST' and $url =~ s{^=/put/}{=/}) {
        $http_meth = 'PUT';
    } elsif ($http_meth =~ /^GET|POST$/ and $url =~ s{^=/delete/}{=/}) {
        $http_meth = 'DELETE';
    }
    $$rurl = $url;

    if ($req_data) {
        from_to($req_data, $charset, 'UTF-8');
        $req_data = OpenAPI->parse_data($req_data);
    }

    return bless {
        _cgi => $cgi,
        _var => $var,
        _url => $url,
        _charset => $charset,
        _error => '',
        _data => undef,
        _warning => '',
        _method => $http_meth,
        _req_data => $req_data,
    }, $class;
}

sub error {
    $_[0]->{_error} .= $_[1] . "\n";
}

sub data {
    $_[0]->{_data} = $_[1];
}

sub response {
    my $self = shift;
    my $charset = $self->{_charset};
    print $self->{_cgi}->header(-type => "text/plain; charset=$charset");
    my $str = '';
    if ($self->{_error}) {
        $str = $self->emit_error($self->{_error});
    } elsif ($self->{_data}) {
        $str = $self->emit_data($self->{_data});
    }
    #die $charset;
    # XXX if $charset is 'UTF-8' then don't bother decoding and encoding...
    eval {
        #$str = decode_utf8($str);
        #from_to($str, 'UTF-8', $charset);
    };  warn $@ if $@;
    if (my $var = $self->{_var}) {
        $str = "var $self->{_var}=$str;";
    }
    print $str, "\n";
}

sub DELETE_model_list {
    my ($self, $bits) = @_;
    my $user = 'tester';
    my $res = OpenAPI->get_tables();
    if (!$res) {
        return { success => 1 };
    }; # no-op
    my @tables = map { @$_ } @$res;
    #$tables = $tables->[0];
    ### tables: @tables
    for my $table (@tables) {
        OpenAPI->drop_table($table);
    }
    return { success => 1 };
}

sub GET_model_list {
    my ($self, $bits) = @_;
    my $models = OpenAPI->get_models;
    $models ||= [];
    ### $models
    map { $_->{src} = "/=/model/$_->{name}" } @$models;
    $models;
}

sub GET_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    return OpenAPI->get_model_cols($model);
}

sub POST_model {
    my ($self, $bits) = @_;
    my $data = $self->{_req_data};
    my $model = $bits->[1];
    ### $model
    $data->{name} = $model;
    return OpenAPI->new_model($data);
}

sub POST_model_row {
    my ($self, $bits) = @_;
    my $data = $self->{_req_data};
    my $model = $bits->[1];
    return OpenAPI->insert_records($model, $data);
}

sub GET_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    if ($column ne '*' and $value ne '*') {
        return OpenAPI->select_records($model, $column, $value);
    }
    if ($column ne '*' and $value eq '*') {
        return OpenAPI->select_records($model, $column);
    }
    if ($column eq '*' and $value eq '*') {
        return OpenAPI->select_all_records($model);
    } else {
        return { success => 0, error => "Unsupported operation." };
    }
}

sub DELETE_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    return OpenAPI->delete_records($model, $column, $value);
}

sub PUT_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    my $data = $self->{_req_data};
    return OpenAPI->update_records($model, $column, $value, $data);
}

sub PUT_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $data = $self->{_req_data};
    return OpenAPI->alter_model($model, $data);
}

sub set_formatter {
    my ($self, $ext) = @_;
    $ext ||= '.json';
    $Dumper = $ext2dumper{$ext};
    $Importer = $ext2importer{$ext};
}

sub connect {
    shift;
    $dbh =  DBI->connect("dbi:Pg:dbname=test", "agentzh", "agentzh", {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1});
}

sub get_tables {
    #my ($self, $user) = @_;
    my $self = shift;
    return $self->selectall_arrayref(<<_EOC_);
select table_name
from _models
_EOC_
}

sub get_models {
    my $self = shift;
    return $self->selectall_arrayref(<<_EOC_, { Slice => {} });
select name, description
from _models
_EOC_
}

sub get_model_cols {
    my ($self, $model) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = lc($model);
    my $list = $self->selectall_arrayref("select description from _models where name='$model'");
    my $desc = $list->[0][0];
    $list = $self->selectall_arrayref(<<_EOC_, { Slice => {} });
select name, type, label
from _columns
where table_name='$table'
_EOC_
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
    my $list = $self->selectall_arrayref(<<_EOC_);
select name
from _columns
where table_name='$table'
_EOC_
    if (!$list or !ref $list) { return []; }
    return [map { @$_ } @$list];
}

sub emit_data {
    my ($self, $data) = @_;
    return $Dumper->($data);
}

sub has_user {
    my ($self, $user) = @_;
    my $retval;
    eval {
        $retval = $self->do(<<"_EOC_");
select nspname
from pg_namespace
where nspname='$user'
limit 1
_EOC_
    };
    return $retval + 0;
}

sub new_user {
    my $self = shift;
    my $user = shift;
    eval {
        $self->do(<<"_EOC_");
create schema $user
    create table _models (
        name text primary key,
        table_name text unique,
        description text
    )
    create table _columns (
        id serial primary key,
        name text,
        type text,
        table_name text,
        native_type varchar(20),
        label text
    );
_EOC_
    };
}

sub new_model {
    my ($self, $data) = @_;
    my $model = $data->{name} or
        die "No 'name' field found for the new model\n";
    if (length($model) >= 32) {
        die "Model name \"$model\" is too long.\n";
    }
    if ($model !~ /^[A-Z]\w*$/) {
        die "Invalid model name: \"$model\"\n";
    }
    my $table = lc($model);
    ### Table: $table
    my $description = $data->{description} or
        die "No 'description' specified for model \"$model\".\n";
    # XXX Should we allow 0 column table here?
    if (!ref $data) {
        die "Malformed data. Hash expected.\n";
    }
    my $columns = $data->{columns};
    if (!$columns or !@$columns) {
        die "No 'columns' specified for model \"$model\".\n";
    }
    my $i = 1;
    if ($self->has_model($model)) {
        die "Model $model already exists.\n";
    }
    my $sql .= <<_EOC_;
insert into _models (name, table_name, description)
values ('$model', '$table', '$description');

_EOC_
    my $sth = $dbh->prepare("insert into _columns (name, type, native_type, label, table_name) values (?, ?, ?, ?, ?)");
    $sql .=
        "create table $table (\n\tid serial primary key";
    my $found_id = undef;
    for my $col (@$columns) {
        my $name = $col->{name} or
            die "No 'name' specified for the " . ORD($i) . " column.\n";
        if (length($name) >= 32) {
            die "Column name \"$name\" is too long.\n";
        }
        $name = lc($name);
        # discard 'id' column
        if ($name eq 'id') {
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
        $sth->execute($name, $type, $ntype, $label, $table);
        $i++;
    }
    $sql .= "\n)";
    ### $sql
    #register_table($table);
    #register_columns
    eval {
        $self->do($sql);
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
    my $retval;
    eval {
        $retval = $self->do(<<"_EOC_");
select name
from _models
where name='$model'
limit 1
_EOC_
    };
    return $retval + 0;
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
    my $self = shift;
    my $user = shift;
    $self->do(<<"_EOC_");
drop schema $user cascade
_EOC_
}

sub do {
    shift;
    if (!$dbh) {
        die "No database handler found;";
    }
    return $dbh->do(@_);
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

sub selectall_arrayref {
    my $self = shift;
    if (!$dbh) {
        die "No database handler found.\n";
    }
    return $dbh->selectall_arrayref(@_);
}

sub selectall_hashref {
    my $self = shift;
    if (!$dbh) {
        die "No database handler found.\n";
    }
    return $dbh->selectall_hashref(@_);
}

sub insert_records {
    my ($self, $model, $data) = @_;
    if (!ref $data) {
        die "Malformed data: Hash or Array expected\n";
    }
    ## Data: $data
    my $table = lc($model);
    my $cols = $self->get_model_col_names($model);
    my $flds = join(",", @$cols);
    my $place_holders = join(",", map { "?" } @$cols);
    my $sth = $dbh->prepare("insert into $table ($flds) values ($place_holders)");

    if (ref $data eq 'HASH') { # record found
        ### Row inserted: $data
        my $num = insert_record($sth, $data, $cols, 1);
        #...
        my $last_id = $dbh->last_insert_id(undef, undef, undef, undef, { sequence => $table . '_id_seq' });
        return { rows_affected => $num, last_row => "/=/model/$model/id/$last_id", success => $num?1:0 };
    } elsif (ref $data eq 'ARRAY') {
        my $i = 0;
        my $rows_affected = 0;
        for my $row_data (@$data) {
            if (!ref $row_data || ref $row_data ne 'HASH') {
                die "Malformed row data found in $i: Hash expected.\n";
            }
            $rows_affected += insert_record($sth, $row_data, $cols, $i);
            $i++;
        }
        my $last_id = $dbh->last_insert_id(undef, undef, undef, undef, { sequence => $table . '_id_seq' });
        return { rows_affected => $rows_affected, last_row => "/=/model/$model/id/$last_id", success => $rows_affected?1:0 };
    } else {
        die "Malformed data: Hash or Array expected.\n";
    }
}

sub insert_record {
    my ($sth, $row_data, $cols, $row_num) = @_;
    my @vals;
    for my $col (@$cols) {
        push @vals, delete $row_data->{$col};
    }
    if (%$row_data) {
        die "Unknown column found in row $row_num: ",
            join(", ", keys %$row_data), "\n";
    }
    return 0 + $sth->execute(@vals);
}

sub select_records {
    my ($self, $model, $user_col, $val) = @_;
    my $table = lc($model);
    my $cols = $self->get_model_col_names($model);
    if ($user_col ne 'id') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    my $flds = join(",", @$cols);
    my $sql;
    if (defined $val) { 
        $sql = "select id,$flds from $table where $user_col=?";
    } else {
        $sql = "select $user_col from $table";
    }
    my $sth = $dbh->prepare($sql);
    ### $sql
    ### $val
    $sth->execute(defined $val ? $val : ());
    my $res = $sth->fetchall_arrayref({});
    if (!$res and !ref $res) { return []; }
    return $res;
}

sub delete_records {
    my ($self, $model, $user_col, $val) = @_;
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
        $sql = "delete from $table where $user_col=?";
    } else {
        $sql = "delete from $table";
    }
    my $sth = $dbh->prepare($sql);
    ### $sql
    ### $val
    my $retval = $sth->execute(defined $val ? $val : ());
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
    my (@inner_sql, @vals);
    while (my ($key, $val) = each %$data) {
        my $col = lc($key);
        if ($col eq 'id') {
            next;  # XXX maybe issue a warning?
        }
        push @inner_sql, "$key=?";
        push @vals, $val;
    }

    my $sql;
    local $" = ",";
    if (defined $val) {
        $sql = "update $table set @inner_sql where $user_col=?";
    } else {
        $sql = "update $table set @inner_sql";
    }
    my $sth = $dbh->prepare($sql);
    push @vals, $val if defined $val;
    ### $sql
    ### @vals
    my $retval = $sth->execute(@vals) + 0;
    return {success => $retval ? 1 : 0,rows_affected => $retval};
}

sub select_all_records {
    my ($self, $model) = @_;
    if (!$self->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $table = lc($model);
    my $list = $self->selectall_arrayref("select * from $table", { Slice => {} });
    if (!$list or !ref $list) { return []; }
    return $list;
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
    my $retval = $dbh->do($sql);
    ### $retval
    return {success => 1};
}

1;

