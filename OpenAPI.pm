package OpenAPI;

use strict;
use warnings;

use Smart::Comments;
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper ();
use Lingua::EN::Inflect qw( ORD);
use List::Util qw(first);
use Params::Util qw(_HASH _ARRAY _SCALAR);

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

sub set_formatter {
    my ($self, $ext) = @_;
    $ext ||= '.yaml';
    $Dumper = $ext2dumper{$ext};
    $Importer = $ext2importer{$ext};
}

sub connect {
    shift;
    $dbh =  DBI->connect("dbi:Pg:dbname=test", "agentzh", "agentzh", {AutoCommit => 1, RaiseError => 1});
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
        $sql .= "update _models set description='$desc' where table='$new_model';\n"
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

