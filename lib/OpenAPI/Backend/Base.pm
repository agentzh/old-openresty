package OpenAPI::Backend::Base;

use strict;
use warnings;

#use Smart::Comments;
use SQL::Insert;

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

sub state {
    $_[0]->{dbh}->state;
}

sub disconnect {
    $_[0]->{dbh}->disconnect;
    $_[0]->{dbh} = undef;
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
            my $insert = SQL::Insert->new("$user._access_rules")
                ->cols(qw< role method url >)
                ->values("'$role'", "'$rule->[0]'", "'/=/$rule->[1]'");
            $sql .= $insert;
        }
    }
    $self->do($sql);
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
        role text references _roles(name) not null,
        method varchar(10) not null,
        url text not null
    );

    create table $user._views (
        id serial primary key,
        name text unique not null,
        definition text unique not null,
        createdate timestamp with time zone default current_timestamp,
        updatedate timestamp with time zone default current_timestamp,
        description text
    );
_EOC_
    #$retval += 0;
    ### $admin_password
    $self->add_default_roles($user, $admin_password);
    return $retval;
}

1;

