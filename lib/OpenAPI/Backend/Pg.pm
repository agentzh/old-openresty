package OpenAPI::Backend::PgFarm;

use strict;
use warnings;
use DBI;

sub new {
    my $class = shift;
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=test",
        "agentzh", "agentzh",
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1}
    );
    return bless {
        dbh => $dbh
    }, $class;
}

sub select {
    my ($self, $sql, $opts) = @_;
    $opts ||= {};
    my $dbh = $self->{dbh};
    return $dbh->selectall_arrayref(
        $sql,
        $opts->{use_hash} ? {Slice=>{}} : ()
    );
}

sub do {
    my ($self, $sql) = @_;
    $self->{dbh}->do($sql);
}

sub quote {
    my ($self, $val) = @_;
    return $self->{dbh}->quote($val);
}

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";
    my $res = $self->select("select currval('${table}_id_seq')");
    if ($res && @$res) { return $res->[0][0]; }
}

sub has_user {
    my ($self, $user) = @_;
    my $select = SQL::Select->new('nspname')
        ->from('pg_namespace')
        ->where(nspname => $self->quote($user))
        ->limit(1);
    my $retval;
    eval {
        $retval = $self->do("$select");
    };
    if ($@) { warn $@; }
    return $retval + 0;
}

sub set_user {
    my ($self, $user) = @_;
    $self->{dbh}->do("set search_path to $user");
    $self->{user} = $user;
}

sub add_user {
    my ($self, $user) = @_;
    my $retval = $self->do(<<"_EOC_");
    create schema $user;
    create table $user._models (
        name text primary key,
        table_name text unique,
        description text
    );
    create table $user._columns (
        id serial primary key,
        name text,
        type text,
        table_name text,
        native_type varchar(20),
        label text
    );
_EOC_
    $retval += 0;
    return $retval;
}

sub drop_user {
    my ($self, $user) = @_;
    $self->do(<<"_EOC_");
drop schema $user cascade
_EOC_
}

1;

