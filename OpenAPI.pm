package OpenAPI;

use strict;
use warnings;

our $dbh;

sub connect {
    shift;
    $dbh =  DBI->connect("dbi:Pg:dbname=test", "agentzh", "agentzh", {AutoCommit => 1, RaiseError => 1});
}

sub get_tables {
    my ($self, $user) = @_;
    $self->selectall_arrayref(<<_EOC_);
select name
from _tables
_EOC_
}

sub has_user {
    my ($self, $user) = @_;
    my $retval;
    eval {
        $retval = $self->do(<<"_EOC_");
select nspname
from pg_namespace
where nspname='$user'
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
    create table _tables (
        name text primary key,
        columns integer[],
        description text
    )
    create table _columns (
        id serial primary key,
        name text,
        type text,
        label text
    );
_EOC_
    };
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
    return eval { $dbh->do(@_) };
}

sub selectall_arrayref {
    shift;
    my $sql = shift;
    if (!$dbh) {
        die "No database handler found;";
    }
    return eval { $dbh->selectall_arrayref(@_) };
}

1;

