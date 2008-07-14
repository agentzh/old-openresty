package OpenResty::Backend::Base;

use strict;
use warnings;

#use Smart::Comments '####';
use Params::Util qw(_ARRAY0 _ARRAY);
use List::MoreUtils qw(firstidx);
use OpenResty::SQL::Insert;

my %DefaultRules = (
    Admin => [
        [ DELETE => 'model' ],
        [ DELETE => 'model/~' ],
        [ DELETE => 'model/~/~' ],
        [ DELETE => 'model/~/~/~' ],
        [ DELETE => 'model/~/~/~/~' ],

        [ GET => 'model' ],
        [ GET => 'model/~' ],
        [ GET => 'model/~/~' ],
        [ GET => 'model/~/~/~' ],
        [ GET => 'model/~/~/~/~' ],

        [ PUT => 'model' ],
        [ PUT => 'model/~' ],
        [ PUT => 'model/~/~' ],
        [ PUT => 'model/~/~/~' ],
        [ PUT => 'model/~/~/~/~' ],

        [ POST => 'model' ],
        [ POST => 'model/~' ],
        [ POST => 'model/~/~' ],
        [ POST => 'model/~/~/~' ],
        [ POST => 'model/~/~/~/~' ],

        [ DELETE => 'view' ],
        [ DELETE => 'view/~' ],
        [ DELETE => 'view/~/~' ],
        [ DELETE => 'view/~/~/~' ],
        [ DELETE => 'view/~/~/~/~' ],

        [ GET => 'view' ],
        [ GET => 'view/~' ],
        [ GET => 'view/~/~' ],
        [ GET => 'view/~/~/~' ],
        [ GET => 'view/~/~/~/~' ],

        [ PUT => 'view' ],
        [ PUT => 'view/~' ],
        [ PUT => 'view/~/~' ],
        [ PUT => 'view/~/~/~' ],
        [ PUT => 'view/~/~/~/~' ],

        [ POST => 'view' ],
        [ POST => 'view/~' ],
        [ POST => 'view/~/~' ],
        [ POST => 'view/~/~/~' ],
        [ POST => 'view/~/~/~/~' ],

        [ DELETE => 'role' ],
        [ DELETE => 'role/~' ],
        [ DELETE => 'role/~/~' ],
        [ DELETE => 'role/~/~/~' ],
        [ DELETE => 'role/~/~/~/~' ],

        [ GET => 'role' ],
        [ GET => 'role/~' ],
        [ GET => 'role/~/~' ],
        [ GET => 'role/~/~/~' ],
        [ GET => 'role/~/~/~/~' ],

        [ PUT => 'role' ],
        [ PUT => 'role/~' ],
        [ PUT => 'role/~/~' ],
        [ PUT => 'role/~/~/~' ],
        [ PUT => 'role/~/~/~/~' ],

        [ POST => 'role' ],
        [ POST => 'role/~' ],
        [ POST => 'role/~/~' ],
        [ POST => 'role/~/~/~' ],
        [ POST => 'role/~/~/~/~' ],

        [ DELETE => 'action' ],
        [ DELETE => 'action/~' ],
        [ DELETE => 'action/~/~' ],
        [ DELETE => 'action/~/~/~' ],
        [ DELETE => 'action/~/~/~/~' ],

        [ GET => 'action' ],
        [ GET => 'action/~' ],
        [ GET => 'action/~/~' ],
        [ GET => 'action/~/~/~' ],
        [ GET => 'action/~/~/~/~' ],

        [ PUT => 'action' ],
        [ PUT => 'action/~' ],
        [ PUT => 'action/~/~' ],
        [ PUT => 'action/~/~/~' ],
        [ PUT => 'action/~/~/~/~' ],

        [ POST => 'action' ],
        [ POST => 'action/~' ],
        [ POST => 'action/~/~' ],
        [ POST => 'action/~/~/~' ],
        [ POST => 'action/~/~/~/~' ],

        [ POST => 'admin/~' ],
    ],
);

our @GlobalVersionDelta = (
    [
        '0.001' => <<'_EOC_',
create or replace function _upgrade() returns integer as $$
begin
    create table _general (
        version varchar(10)
    );
    insert into _general (version) values ('0.001');
    create table _accounts (
        id serial primary key,
        name text unique not null
    );
    return 0;
end;
$$ language plpgsql;
_EOC_
    ],
    [
        '0.002' => '',
    ],
    [
        '0.003' => '',
    ],
    [
        '0.004' => <<"_EOC_",
create or replace function _upgrade() returns integer as \$\$
begin
    alter table _global._general add column captcha_key char(16) not null
    default '${\(random_secret())}';
    return 0;
end;
\$\$ language plpgsql;
_EOC_
    ],
    [
        '0.005' => '',
    ],
);

our @LocalVersionDelta = (
    [
        '0.001' => <<'_EOC_',
create or replace function _upgrade() returns integer as $$
begin
    create table _general (
        version varchar(10),
        created timestamp (0) with time zone default now()
    );
    insert into _general (version) values ('0.001');
    alter table _access_rules rename to _access;
    alter table _roles rename to _tmp;
    create table _roles (
        id serial primary key,
        name text unique not null,
        password text,
        login text not null,
        description text not null,
        created timestamp (0) with time zone default now()
    );
    insert into _roles
        (name, password, login, description)
        (select name, password, login, description from _tmp);
    drop table _tmp;
    alter table _columns add column indexed text;
    alter table _models add column created timestamp (0) with time zone default now();
    alter table _views add column created timestamp (0) with time zone default now();
    create table _action (
        id serial primary key,
        name text unique not null,
        description text,
        definition text unique not null,
        confirmed_by text,
        created timestamp (0) with time zone default now()
    );
    return 0;
end;
$$ language plpgsql;
_EOC_
    ],
    [
        '0.002' => <<'_EOC_',
create or replace function _upgrade() returns integer as $$
begin
    drop table _action;
    insert into _access (role, method, url) values ('Admin', 'DELETE', '/=/feed');
    insert into _access (role, method, url) values ('Admin', 'DELETE', '/=/feed/~');
    insert into _access (role, method, url) values ('Admin', 'GET', '/=/feed');
    insert into _access (role, method, url) values ('Admin', 'GET', '/=/feed/~');
    insert into _access (role, method, url) values ('Admin', 'GET', '/=/feed/~/~/~');
    insert into _access (role, method, url) values ('Admin', 'POST', '/=/feed/~');
    insert into _access (role, method, url) values ('Admin', 'PUT', '/=/feed/~');
    create table _feeds (
        id serial primary key,
        name text unique not null,
        description text not null,
        view text not null,
        title text not null,
        link text not null,
        logo text,
        copyright text,
        language text,
        author text,
        created timestamp (0) with time zone default now()
    );
    return 0;
end;
$$ language plpgsql;
_EOC_
    ],
    [ '0.003' => <<'_EOC_',
create or replace function _upgrade() returns integer as $$
begin
    update _roles set password=md5(password);
    return 0;
end;
$$ language plpgsql;
_EOC_
    ],
    [ '0.004' => '' ],
    [ '0.005' => <<'_EOC_' ],
create or replace function _upgrade() returns integer as $$
begin
    update _columns set "default" = '["' || regexp_replace(regexp_replace("default", '"', '\\"', 'g'), '''''', '''', 'g') || '"]' where not "default" ~ '^''.*''$';
    update _columns set "default" = regexp_replace("default", '^''|''$', '"', 'g') where "default" ~ '^''.*''$';
    alter table _views drop constraint _views_definition_key;

    return 0;
end;
$$ language plpgsql;
_EOC_
);

sub upgrade_all {
    my ($self) = @_;
    if ( ! $self->has_user('_global')) {
        $self->upgrade_global_metamodel(0);
        warn "WARNING!!! You need to upgrade every user account in your system manually.\n";
        return;
    }
    $self->set_user('_global');
    my $base = $self->get_upgrading_base;
    if ($base < 0) {
        warn "Global metamodel is up to date.\n";
    } else {
        #### Upgrading global metamodel...
        $self->upgrade_global_metamodel($base);
    }
    my @accounts = $self->get_all_accounts;
    #warn "@accounts";
    for my $account (@accounts) {
        $self->set_user($account);
        my $base = $self->get_upgrading_base;
        if ($base < 0) { warn "Account $account is up to date.\n"; }
        else { $self->upgrade_local_metamodel($base); }
    }
}

sub get_all_accounts {
    my ($self) = @_;
    my $res = $self->select("select name from _global._accounts") || [];
    return map { @$_ } @$res;
}

sub get_upgrading_base {
    my ($self) = @_;
    my $user = $self->{user} or die "No user specified";
    my $data = $self->select("select count(*) from pg_tables where tablename = '_general' and schemaname = '$user'");
    #### _general: $data
    if (_ARRAY($data) && defined $data->[0][0] && $data->[0][0] == 0) {
        return 0;
    }
    $data = $self->select("select version from $user._general limit 1");
    #### Version: $data
    my $version;
    if (_ARRAY0($data) && _ARRAY0($data->[0])) {
        $version = $data->[0][0];
        my $from = firstidx { $_->[0] > $version } @LocalVersionDelta;
        #### $from
        return $from;
    }
    return -1;
}

sub upgrade_global_metamodel {
    my ($self, $base) = @_;
    if (!defined $base) { die "No upgrading base specified" }
    if ($base == 0 || !$self->has_user('_global')) {
        $self->add_empty_user("_global");
        $self->set_user("_global");
    }
    #### Upgrading global metamodel...
    $self->_upgrade_metamodel($base, \@GlobalVersionDelta);
}

sub upgrade_local_metamodel {
    my ($self, $base) = @_;

    if (!defined $base) { die "No upgrading base specified" }
    if (!$self->has_user('_global')) {
        my $user = $self->{user};
        $self->upgrade_global_metamodel(0);
        $self->set_user($user);
    }
    $self->_upgrade_metamodel($base, \@LocalVersionDelta);
}

sub _upgrade_metamodel {
    my ($self, $base, $delta_table) = @_;
    my $user = $self->{user} or die "No user specified";
    if (!defined $base) {
        die "No upgrading base specified";
    }
    my $cur_ver;
    if ($base == 0) {
        $cur_ver = 'nil';
    } else {
        $cur_ver = $delta_table->[$base-1]->[0];
    }
    my $res;
    my $max = @$delta_table - 1;
    #### Upgrading meta model...
    for my $i ($base..$max) {
        my $entry = $delta_table->[$i];
        my ($new_ver, $sql) = @$entry;
        warn "Upgrading account $user from $cur_ver to $new_ver...\n";
        if (!$sql) {
            $res = $self->do("update _general set version='$new_ver'");
            $cur_ver = $new_ver;
            next;
        }
        #$sql .= "; update _general set version='$new_ver'";
        $res = $self->do("$sql;");
        $res = $self->do("select _upgrade();");
        $res = $self->do("update _general set version='$new_ver'");
        #for my $stmt (split /;\n/, $sql) {
            #warn "=======", $stmt, "=======\n";
            #next if $stmt =~ /^\s*$/;
            #sleep 1;
            #$res = $self->do("$stmt;");
            #last if $res < 0;
        #}
        $cur_ver = $new_ver;
    }
    return !defined $res || $res >= 0;
}

sub ping {
    $_[0]->{dbh}->ping;
}

sub disconnect {
    $_[0]->{dbh}->disconnect;
}

sub add_default_roles {
    my ($self, $user, $admin_password) = @_;
    if (!defined $admin_password) {
        warn "No password specified.\n";
    }
    my $sql = <<"_EOC_";
insert into $user._roles (name, description, login, password)
values ('Admin', 'Administrator', 'password', '$admin_password');

insert into $user._roles (name, description, login)
values ('Public', 'Anonymous', 'anonymous');
_EOC_
    while (my ($role, $rules) = each %DefaultRules) {
        for my $rule (@$rules) {
            my $insert = OpenResty::SQL::Insert->new("$user._access_rules")
                ->cols(qw< role method url >)
                ->values("'$role'", "'$rule->[0]'", "'/=/$rule->[1]'");
            $sql .= $insert;
        }
    }
    $self->do($sql);
}

sub drop_user {
    my ($self, $user) = @_;
    if ($self->has_user('_global')) {
        $self->set_user('_global');
        $self->do("delete from _accounts where name ='$user'");
        $OpenResty::Cache->remove_has_user($user) if $OpenResty::Cache;
    }
}

sub add_user {
    my ($self, $user, $admin_password) = @_;
    my $retval = $self->do(<<"_EOC_");
    create table $user._models (
        id serial primary key,
        name text unique not null,
        table_name text unique not null,
        description text
    );

    create table $user._columns (
        id serial primary key,
        name text  not null,
        type text not null,
        table_name text not null,
        "default" text,
        label text,
        unique(table_name, name)
    );

    create table $user._roles (
        name text primary key,
        parentRole integer default 0, -- a column reference to $user._roles itself. 0 means no parent
        password text,
        login text not null,
        description text not null
    );

    create table $user._access_rules (
        id serial primary key,
        role text not null,
        method varchar(10) not null,
        url text not null
    );

    create table $user._views (
        id serial primary key,
        name text unique not null,
        definition text unique not null,
        description text
    );
_EOC_
    #$retval += 0;
    ### $admin_password
    $self->add_default_roles($user, $admin_password);
    $self->set_user($user);
    $self->upgrade_local_metamodel(0);
    #return $retval;
    my $cur_user = $self->{user};
    $self->set_user('_global');
    $self->do("insert into _accounts (name) values ('$cur_user')");
    $self->set_user($cur_user);
}

# generating random 16-bytes captcha secret key
sub random_secret
{
    my @set=('0'..'9','a'..'z','A'..'Z');
    my $key=join("",map {$set[int(rand(@set))]} (1..16));
    return $key;
}

# check if the given string is a valid captcha secret
# this sub should be called as a class method!
sub is_valid_captcha_secret
{
    defined($_[1]) && length($_[1])==16 && $_[1]!~/[^0-9a-zA-Z]/;
}

# update the backend captcha secret
sub update_captcha_secret
{
    my $self=shift||die;
    my $secret=shift;

    return undef unless $self->is_valid_captcha_secret($secret);

    # quote string and escape any special characters to prevent SQL injection
    $secret=$self->quote($secret);

    # update captcha secret in the backend
    my $cur_user = $self->{user};
    $self->set_user('_global');
    my $rv=$self->do("update _global._general set captcha_key=$secret");
    $self->set_user($cur_user) if defined($cur_user);
    return defined($rv)?1:undef;
}

1;
__END__

=head1 NAME

OpenResty::Backend::Base - Base class for OpenResty backend classes

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>.

=head1 SEE ALSO

L<OpenResty::Backend::Pg>, L<OpenResty::Backend::PgFarm>, L<OpenResty::Backend::PgMocked>, L<OpenResty>.

