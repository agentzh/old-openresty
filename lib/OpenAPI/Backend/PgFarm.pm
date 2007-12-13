package OpenAPI::Backend::PgFarm;

use strict;
use warnings;
#use Smart::Comments;
use DBI;
use JSON::Syck 'Load';

sub new {
    #
    # XXX todo: change it to use params
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
    my $type = $opts->{use_hash} ? 1 : 0;
    $sql = $self->quote($sql);
    #warn "==================> $sql\n";
    my $sql_cmd = "select xquery('$self->{user}', $sql, $type)";
    #warn "------------------> $sql_cmd";
    my $dbh = $self->{dbh};
    my $res = $dbh->selectall_arrayref($sql_cmd);
    ### JSON: $res->[0][0]
    $res = Load($res->[0][0]);
    return $res;
}

sub do {
    my ($self, $sql) = @_;
    $sql=$self->quote($sql);
    my $sql_cmd = "select xdo('$self->{user}', $sql)";
    my $res = $self->{dbh}->selectall_arrayref($sql_cmd);
    ### $res
    return $res->[0][0]+0;
}

sub quote {
    my ($self, $val) = @_;
    return $self->{dbh}->quote($val);
}

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";
    #my $sql = "select xquery('$self->{user}',')', 0)";
    #my $dbh = $self->{dbh};
    my $sql = "select max(id) from ${table}";
    my $res = $self->select($sql);
    return $res->[0][0];
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
    $self->set_user($user);
    $retval = $self->do(<<"_EOC_");
    --create schema $user;
    create table $user._models (
	id serial primary key,
        name text,
        table_name text unique,
        description text
    );

    create unique index $user.$user__models_name_idx on $user._models using btree (name);

    create table $user._columns (
        id serial primary key,
        name text,
        type text,
        table_name text,
        native_type varchar(20),
        label text
    );
    create table $user._roles(
	id serial primary key,
	name text,
        parentRole integer default 0, -- a column reference to $user._roles itself.
        password text,
	obj integer, -- a column reference to $user._columns or $user._models
        accessable boolean,
	readable boolean,
        writeable boolean,
        manageable boolean
			      );
    create unique index $user.$user__roles_name_idx on $user._roles using btree(name);
_EOC_

    #$retval += 0;
    return $retval >= 0;
}

sub drop_user {
    my ($self, $user) = @_;
    my $retval = $self->{dbh}->do(<<"_EOC_");
    SELECT userdel('$user','');
_EOC_
    $retval += 0;
    return $retval;
}

1;
