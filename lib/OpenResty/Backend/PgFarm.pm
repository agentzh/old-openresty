package OpenResty::Backend::PgFarm;

use strict;
use warnings;

#use Smart::Comments;
use JSON::XS ();
use DBI;
use Encode ();
use base 'OpenResty::Backend::Base';

our ($Host, $User, $Password, $Port);

my $json_xs = JSON::XS->new->utf8;

sub new {
    #
    # XXX todo: change it to use params
    #
    my $class = shift;
    my $opts = shift || {};
    $Host ||= $OpenResty::Config{'backend.host'}  or
        die "No backend.host specified in the config files.\n";
    $User ||= $OpenResty::Config{'backend.user'} or
        die "No backend.user specified in the config files.\n";
    $Password ||= $OpenResty::Config{'backend.password'} || '';
    $Port ||= $OpenResty::Config{'backend.port'};
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=proxy host=$Host".
            ($Port ? ";port=$Port" : ""),
        $User, $Password,
        {AutoCommit => 1, RaiseError => 1, %$opts, PrintError => 0}
    );
    return bless {
        dbh => $dbh
    }, $class;
}

sub select {
    my ($self, $sql, $opts) = @_;
    #warn "SQL: $sql";
    $opts ||= {};
    my $type = $opts->{use_hash} ? 1 : 0;
    my $readonly = $opts->{read_only} ? 1 : 0;
    $sql = $self->quote($sql);
    #warn "==================> $sql\n";
    my $sql_cmd = "select xquery('$self->{user}', $sql, $type, $readonly)";
    #warn $sql_cmd, "\n";
    #warn "------------------> $sql_cmd";
    my $dbh = $self->{dbh};
    my $res = $dbh->selectall_arrayref($sql_cmd);
    ### JSON: $res->[0][0]
    my $json = $res->[0][0];
    eval {
        $res = $json_xs->decode($json);
    };
    if ($@) {
        use Data::Dumper;
        die "Failed to load JSON from PgFarm's response: $@\n", Data::Dumper::Dumper($json);
    }
    return $res;
}

sub do {
    my ($self, $sql) = @_;
    $sql = $self->quote($sql);
    my $sql_cmd = "select xdo('$self->{user}', $sql)";
    #warn "SQL: $sql_cmd\n";
    my $res = $self->{dbh}->selectall_arrayref($sql_cmd);
    ### $res
    return $res->[0][0]+0;
}

sub quote {
    my ($self, $val) = @_;
    $self->{dbh}->quote($val);
    #$s =~ s/\n/\\n/g;
    #$s =~ s/\t/\\t/g;
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
    my $retval = $self->add_empty_user($user);
    $self->set_user($user);
    $self->SUPER::add_user($user, @_);
    return $retval >= 0;
}

sub add_empty_user {
    my ($self, $user) = @_;
    $self->{dbh}->do(<<"_EOC_");
        SELECT useradd('$user','');
        -- grant usage on schema $user to anonymous;
_EOC_
}

sub drop_user {
    my ($self, $user) = @_;
    $self->SUPER::drop_user($user);
    my $retval = $self->{dbh}->do(<<"_EOC_");
    SELECT userdel('$user','');
_EOC_
    $retval += 0;
    return $retval;
}

sub login {
    my ($self, $account, $role, $captcha, $pass) = @_;
    my $retval;

    $account = $self->quote($account);
    $role = $self->quote($role);
    $captcha = $self->quote($captcha);
    $pass = $self->quote($pass);

    my $sql = "select * from public.login($account, $role, $captcha, $pass)";
    #warn $sql;
    eval {
        $self->do($sql);
    };
    if ($@) {
        (my $error = $@) =~ s/^\QDBD::Pg::db selectall_arrayref failed: ERROR:  PL\/Proxy function public.xdo(2): libpq error in weird result: ERROR:  \E//;
        $error =~ s/\nCONTEXT.*//s;
        die "$error\n";
    }
}

1;
