package OpenAPI::Backend::Pg;

use strict;
use warnings;
use DBI;
use SQL::Select;
use base 'OpenAPI::Backend::Base';
use Encode 'from_to';

our ($Host, $User, $Password, $Port, $Database);

sub new {
    my $class = shift;
    my $opts = shift || {};

    $Host ||= $OpenAPI::Config{'backend.host'}  or
        die "No backend.host specified in the config files.\n";
    $User ||= $OpenAPI::Config{'backend.user'} or
        die "No backend.user specified in the config files.\n";
    $Password ||= $OpenAPI::Config{'backend.password'} || '';
    $Port ||= $OpenAPI::Config{'backend.port'};
    $Database ||= $OpenAPI::Config{'backend.database'} or
        die "No backend.database specified in the config files.\n";

    my $dbh = DBI->connect(
        "dbi:Pg:dbname=$Database;host=$Host".
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
    from_to($str, 'UTF-8', $charset);
    $str;
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
    my $res = $self->select("select max(id) from \"$table\"");
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
    my $self = shift;
    my $user = shift;
    $self->do(<<"_EOC_");
create schema $user;
set search_path to $user;
_EOC_
    $self->SUPER::add_user($user, @_);
}

sub drop_user {
    my ($self, $user) = @_;
    $self->do(<<"_EOC_");
drop schema $user cascade
_EOC_
}

sub login {
    my ($self, $user, $role, $captcha, $pass) = @_;
    my $retval;
    
    eval {
      $user = $self->quote($user);
      $role = $self->quote($role);
      $captcha = $self->quote($captcha);
      $pass = $self->quote($pass);

      $retval = $self->do(<<"_EOC_");
create or replace function login("user" text, 
  captcha text, pass text) returns integer as \$\$
declare
  account text;
  role text;
  u text;
begin
  account = split_part("user", '.', 1);
  if account !~ E'\\w+' then 
    raise exception 'invalid account name %', account;
  end if;
  role = split_part("user", '.', 1);
  if role !~ E'\\w+' then 
    role = 'Admin';
  end if;
  execute 'select nspname from pg_namespace where nspname = '||account||' limit 1' into u; 
  if u is null then
    raise exception 'account % does not exist', account;
  end if;
  execute 'set search_path to public, account';
  if captcha !~ E'\\S+:\\S+' then
    raise exception 'invalid captcha %', captcha;
  end if;
  execute 'select name from _roles where name = '||role||' and login = ''captcha''' into u;
  if u is null then
    raise exception 'Cannot login as %.% via captchas.', account , role;
  end if;
  execute 'select name from _roles where name = '||role||' and login = ''password''' and password = '||pass||' into u;
  if u is null then
    raise exception 'Cannot login as %.% via password.', account , role;
  end if;
  execute 'select name from _roles where name = '||role||' and login = ''anonymous''' into u;
  if u is null then
    raise exception 'Cannot login as %.% via anonymous.', account , role;
  end if;
end;
\$\$ language plpgsql;
select login($user, $role, $captcha, $pass);
_EOC_
    };
    if ($@) { die $@; }
}


1;

