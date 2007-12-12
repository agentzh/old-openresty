package OpenAPI::Backend::PgFarm;

use strict;
use warnings;
use Smart::Comments;
use DBI;

sub new {
    #
    # todo: change it to use params
    #
    my $class = shift;
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=proxy host=os901000.inktomisearch.com",
        "searcher", "",
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1}
    );
    return bless {
        dbh => $dbh
    }, $class;
}

sub select {
    my ($self, $sql, $opts) = @_;
    $opts ||= {};
	$sql = $self->quote($sql);
    my $sql_cmd = "select * from xquery('$self->{user}', $sql)";
    my $dbh = $self->{dbh};
    return $dbh->selectall_arrayref(
        $sql,
        $opts->{use_hash} ? {Slice=>{}} : ()
    );
}

sub do {
    my ($self, $sql) = @_;
	$sql=$self->quote($sql);
    my $sql_cmd = "select doe('$self->{user}', $sql)";
    $self->{dbh}->do($sql_cmd);
}

sub quote {
    my ($self, $val) = @_;
    return $self->{dbh}->quote($val);
}

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";

	my $sql = "select * from xquery('$self->{user}','select currval(''''${table}_id_seq'''')')";
    my $dbh = $self->{dbh};
    return $dbh->selectall_arrayref($sql);
}

sub has_user {
	my ($self,$user,$opts) = @_;
    my $res = $self->{dbh}->selectall_arrayref(
        "select registered('$user','')",
        $opts->{use_hash} ? {Slice=>{}} : ()
    );
    if ($res && @$res) { return $res->[0][0]; }
}

sub set_user {
    my ($self, $user) = @_;
    $self->{user} = $user;
}

sub add_user {
    my ($self, $user) = @_;
    my $retval = $self->{dbh}->do(<<"_EOC_");
    SELECT useradd('$user','');
_EOC_
    $retval += 0;
    return $retval;
}

sub drop_user {
    my ($self, $user) = @_;
    my $retval=$self->{dbh}->do(<<"_EOC_");
    SELECT userdel('$user','');
_EOC_
	$retval += 0;
	return $retval;
}

1;
