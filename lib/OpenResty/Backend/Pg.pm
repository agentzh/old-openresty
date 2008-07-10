package OpenResty::Backend::Pg;

use strict;
use warnings;

#use Smart::Comments;
use DBI;
use OpenResty::SQL::Select;
use base 'OpenResty::Backend::Base';

our $Recording;
our ($Host, $User, $Password, $Port, $Database);

sub new {
    my $class = shift;
    my $opts = shift || {};

    $Host ||= $OpenResty::Config{'backend.host'}  or
        die "No backend.host specified in the config files.\n";
    $User ||= $OpenResty::Config{'backend.user'} or
        die "No backend.user specified in the config files.\n";
    $Password ||= $OpenResty::Config{'backend.password'} || '';
    $Port ||= $OpenResty::Config{'backend.port'};
    $Database ||= $OpenResty::Config{'backend.database'} or
        die "No backend.database specified in the config files.\n";

    my $dbh = DBI->connect(
        "dbi:Pg:dbname=$Database;host=$Host".
            ($Port ? ";port=$Port" : ""),
        $User, $Password,
        {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1, %$opts, PrintError => 0}
    );

    $Recording = $OpenResty::Config{'backend.recording'} && ! $OpenResty::Config{'test_suite.use_http'};
    if ($Recording) {
        my $t_file;
        if ($0 =~ m{[^/]+\.t$}) {
            $t_file = $&;
            require OpenResty::Backend::PgMocked;
            OpenResty::Backend::PgMocked->start_recording_file($t_file);
        } else {
            warn "Config setting backend.recording ignored.";
            undef $Recording;
        }
    }

    return bless {
        dbh => $dbh
    }, $class;
}

END {
    if ($Recording) {
        OpenResty::Backend::PgMocked->stop_recording_file();
    }
}

sub select {
    my ($self, $sql, $opts) = @_;
    $opts ||= {};
    my $dbh = $self->{dbh};
    if ($Recording) {
        my $res;
        eval {
            $res = $dbh->selectall_arrayref(
                $sql,
                $opts->{use_hash} ? {Slice=>{}} : ()
            );
        };
        if ($@) {
            my $err = $@;
            OpenResty::Backend::PgMocked->record($sql => bless \$err, 'die');
            die $err;
        }
        OpenResty::Backend::PgMocked->record($sql => $res);
        return $res;
    } else {
        return $dbh->selectall_arrayref(
            $sql,
            $opts->{use_hash} ? {Slice=>{}} : ()
        );
    }
}

sub do {
    my ($self, $sql) = @_;
    if ($Recording) {
        my $res;
        eval { $res = $self->{dbh}->do($sql); };
        if ($@) {
            my $err = $@;
            OpenResty::Backend::PgMocked->record($sql => $err => 'die');
            die $err;
        }
        OpenResty::Backend::PgMocked->record($sql => $res);
        return $res;
    } else {
        return $self->{dbh}->do($sql);
    }

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
    $self->do("set search_path to $user");
    $self->{user} = $user;
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
        (my $error = $@) =~ s/^DBD::Pg::db do failed: ERROR:  //g;
        die $error;
    }
}

1;
__END__

=head1 NAME

OpenResty::Backend::Pg - OpenResty backend for PostgreSQL standalone databases 

=head1 INHERITANCE

    OpenResty::Backend::Pg
        ISA OpenResty::Backend::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@gmail.com >>

=head1 SEE ALSO

L<OpenResty::Backend::Base>, L<OpenResty::Backend::PgFarm>, L<OpenResty::Backend::PgMocked>, L<OpenResty>.

