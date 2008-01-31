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
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1, %$opts, PrintError => 0}
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
    my ($self, $account, $role, $captcha, $pass) = @_;

    $account = $self->quote($account);
    $role = $self->quote($role);
    $captcha = $self->quote($captcha);
    $pass = $self->quote($pass);

    eval {
        $self->do(<<"_EOC_");
create or replace function login(account text, role text,
  captcha text, pass text) returns integer as \$\$
declare
  u text;
begin
  execute 'set search_path to '$account'';
  if captcha is not null then

    if captcha !~ '[^ ]:[^ ]' then
      raise exception 'Bad captcha parameter: %', captcha;
    end if;
    execute 'select name from _roles where name = '''||role||''' and login = ''captcha''' into u;
    if u is null then
      raise exception 'Cannot login as %.% via captchas.', account , role;
    end if;
  elsif pass is not null then
  
    execute 'select name from _roles where name = '''||role||''' and login = ''password'' and password = '''||pass||'''' into u;
    if u is null then
      raise exception 'Password for %.% is incorrect.', account , role;
    end if;
  else 

    execute 'select name from _roles where name = '''||role||''' and login = ''anonymous''' into u;
    if u is null then
      raise exception 'Password for %.% is required.', account , role;
    end if;
  end if;
  return 0;
end;
\$\$ language plpgsql;
select login($account, $role, $captcha, $pass);
_EOC_
    };
    if ($@) {
        (my $error = $@) =~ s/^DBD::Pg::db do failed: ERROR:  //g;
        die $error;
    }
}


1;

