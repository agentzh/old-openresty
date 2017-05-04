package OpenResty::Backend::Prophet;

use strict;
use warnings;

#use Smart::Comments;
use OpenResty::SQL::Select;
use OpenResty::Limits;
use base 'OpenResty::Backend::Base';

our ($Host, $User, $Password, $Port, $Database);

sub new {
    my $class = shift;
    my $opts = shift || {};

    $Host ||= $OpenResty::Config{'backend.host'}  or die "No backend.host specified in the config files.\n";
    $User ||= $OpenResty::Config{'backend.user'} or die "No backend.user specified in the config files.\n";
    $Password ||= $OpenResty::Config{'backend.password'} || '';
    $Port ||= $OpenResty::Config{'backend.port'};
    $Database ||= $OpenResty::Config{'backend.database'} or die "No backend.database specified in the config files.\n";


    $ENV{'PROPHET_REPO'} = '/tmp/openresty'; # XXX SPEC
    
    my $prophet = Prophet::CLI->new();
    return bless {
        prophet => $prophet
    }, $class;
}

sub select {
    my ($self, $sql, $opts) = @_;
    $opts ||= {};
    my $dbh = $self->{dbh};
        #warn "==== ", $OpenResty::Dumper->($sql), "\n";
        return $dbh->selectall_arrayref(
            $sql,
            $opts->{use_hash} ? {MaxRows => $MAX_SELECT_LIMIT, Slice=>{}} : ()
        );
}

sub do {
    my ($self, $sql) = @_;
        #warn "==== ", $OpenResty::Dumper->($sql), "\n";
         $self->{dbh}->do($sql);

}

sub last_insert_id {
    my ($self, $table) = @_;
    #die "Found table!!! $table";
    my $res = $self->select("select max(id) from \"$table\"");
    if ($res && @$res) { return $res->[0][0]; }
}

sub has_user {
    my ($self, $user) = @_;
    my $select = OpenResty::SQL::Select->new('nspname')
        ->from('pg_namespace')
        ->where(nspname => $self->quote($user))
        ->limit(1);
    my $retval;
    eval {
        $retval = $self->do("$select");
    };
    if ($@) { warn $@; }
    no warnings 'uninitialized';
    return $retval + 0;
}

sub set_user {
    my ($self, $user) = @_;
    my $old_user = $self->{user};
    if (!$old_user or $user ne $old_user) {
        $self->do("set search_path to $user,public");
        $self->{user} = $user;
    }
}

sub add_user {
    my $self = shift;
    my $user = shift;
    $self->add_empty_user($user);
    $self->SUPER::add_user($user, @_);
}

sub add_empty_user {
    my ($self, $user) = @_;
    $self->do(<<"_EOC_");
create schema $user;
set search_path to $user;
_EOC_
}

sub drop_user {
    my ($self, $user) = @_;
    $self->SUPER::drop_user($user);
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
        (my $error = $@) =~ s/^DBD::Prophet::db do failed: ERROR:  //g;
        die $error;
    }
}

1;
__END__

=head1 NAME

OpenResty::Backend::Prophet - OpenResty backend for Prophet databases

=head1 INHERITANCE

    OpenResty::Backend::Prophet
        ISA OpenResty::Backend::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Jesse Vincent C<< jesse@bestpractical.com >>, Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Backend::Base>, L<OpenResty>.

