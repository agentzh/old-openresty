package OpenAPI;

use strict;
use warnings;

use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper ();

my %ext2dumper = (
    '.yml' => \&YAML::Syck::Dump,
    '.yaml' => \&YAML::Syck::Dump,
    '.js' => \&JSON::Syck::Dump,
    '.json' => \&JSON::Syck::Dump,
);

our ($dbh, $Dumper);

sub set_dumper {
    my ($self, $ext) = @_;
    $ext ||= '.yaml';
    $Dumper = $ext2dumper{$ext};
}

sub connect {
    shift;
    $dbh =  DBI->connect("dbi:Pg:dbname=test", "agentzh", "agentzh", {AutoCommit => 1, RaiseError => 1});
}

sub get_tables {
    #my ($self, $user) = @_;
    my $self = shift;
    return $self->selectall_arrayref(<<_EOC_);
select name
from _tables
_EOC_
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

sub drop_table {
    my ($self, $table) = @_;
    $self->do(<<_EOC_);
drop table $table;
delete from $table where name = '$table';
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
    return $self->emit_data( { error => $msg } );
}

sub selectall_arrayref {
    my $self = shift;
    if (!$dbh) {
        die "No database handler found;";
    }
    return $dbh->selectall_arrayref(@_);
}

1;

