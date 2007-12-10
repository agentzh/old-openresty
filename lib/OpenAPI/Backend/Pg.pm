package OpenAPI::Backend::Pg;

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

sub set_user {
    my ($self, $user) = @_;
    $self->{dbh}->do("set search_path to $user");
    $self->{user} = $user;
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

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";
    my $res = $self->select("select max(id) from $table");
    if ($res && @$res) { return $res->[0][0]; }
}

sub do {
    my ($self, $sql) = @_;
    $self->{dbh}->do($sql);
}

sub quote {
    my ($self, $val) = @_;
    return $self->{dbh}->quote($val);
}

1;

