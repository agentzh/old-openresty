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
    my $opts = shift || {};
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=proxy host=os901000.inktomisearch.com",
        "searcher", "",
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1, %$opts}
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
        name text unique not null,
        table_name text unique not null,
        description text
    );


    create table $user._columns (
        id serial primary key,
        name text not null,
        type text not null default 'text',
        table_name text not null,
        native_type varchar(20),
        label text,
        "default" text,
	unique(table_name, name)
    );

    create table $user._roles(
	id serial primary key,
	name text unique not null,
        parentRole integer default 0, -- a column reference to $user._roles itself.
        password text not null,
	obj integer, -- a column reference to $user._columns or $user._models
        visible boolean,
	readable boolean,
        writeable boolean,
        manageable boolean
			      );
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
