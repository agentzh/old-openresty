package OpenAPI::Backend::Pg;

use strict;
use warnings;
use DBI;
use SQL::Select;

sub new {
    my $class = shift;
    my $opts = shift || {};
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=test;host=localhost",
        "agentzh", "agentzh",
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1, %$opts}
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

sub quote_identifier {
    my ($self, $val) = @_;
    return $self->{dbh}->quote_identifier($val);
}

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";
    my $res = $self->select("select currval('\"${table}_id_seq\"')");
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
    set search_path to $user;

    create table $user._models (
	id serial primary key,
        name text unique not null,
        table_name text unique not null,
        description text
    );

    create table $user._columns (
        id serial primary key,
        name text  not null,
        type text not null,
        table_name text not null,
        native_type varchar(20) default 'text',
        "default" text,
        label text,
	unique(table_name, name)
    );

    create table $user._roles(
	id serial primary key,
	name text unique not null,
        parentRole integer default 0, -- a column reference to $user._roles itself. 0 means no parent
        password text not null,
	obj integer not null, -- a column reference to $user._columns or $user._models
        visible boolean,
	readable boolean,
        writeable boolean,
        manageable boolean
			      );
_EOC_
    #$retval += 0;
    return $retval;
}

sub drop_user {
    my ($self, $user) = @_;
    $self->do(<<"_EOC_");
drop schema $user cascade
_EOC_
}

1;

