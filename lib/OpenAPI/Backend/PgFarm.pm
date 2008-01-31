package OpenAPI::Backend::PgFarm;

use strict;
use warnings;

#use Smart::Comments;
use DBI;
use JSON::Syck 'Load';
use Encode 'encode';
use base 'OpenAPI::Backend::Base';

$YAML::Syck::ImplicitUnicode = 1;
$JSON::Syck::ImplicitUnicode = 1;

our ($Host, $User, $Password, $Port);

sub new {
    #
    # XXX todo: change it to use params
    #
    my $class = shift;
    my $opts = shift || {};
    $Host ||= $OpenAPI::Config{'backend.host'}  or
        die "No backend.host specified in the config files.\n";
    $User ||= $OpenAPI::Config{'backend.user'} or
        die "No backend.user specified in the config files.\n";
    $Password ||= $OpenAPI::Config{'backend.password'} || '';
    $Port ||= $OpenAPI::Config{'backend.port'};
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=proxy host=$Host".
            ($Port ? ";port=$Port" : ""),
        $User, $Password,
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1, %$opts}
    );
    return bless {
        dbh => $dbh
    }, $class;
}

sub encode_string {
    my ($self, $str, $charset) = @_;
    encode($charset, $str);
}

sub select {
    my ($self, $sql, $opts) = @_;
    $opts ||= {};
    my $type = $opts->{use_hash} ? 1 : 0;
    my $readonly = $opts->{read_only} ? 1 : 0;
    $sql = $self->quote($sql);
    #warn "==================> $sql\n";
    my $sql_cmd = "select xquery('$self->{user}', $sql, $type, $readonly)";
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

sub quote_identifier {
    my ($self, $val) = @_;
    return $self->{dbh}->quote_identifier($val);
}

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";
    #my $sql = "select xquery('$self->{user}',')', 0)";
    #my $dbh = $self->{dbh};
    my $sql = "select max(id) from \"$table\"";
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
    my $self = shift;
    my $user = shift;
    my $retval = $self->{dbh}->do(<<"_EOC_");
    SELECT useradd('$user','');
    -- grant usage on schema $user to anonymous;
_EOC_
    $self->set_user($user);
    $self->SUPER::add_user($user, @_);
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

sub login {
    my ($self, $user, $role, $captcha, $pass) = @_;
    my $retval;

    # TODO
}

1;
