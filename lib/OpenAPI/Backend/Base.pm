package OpenAPI::Backend::Base;

use strict;
use warnings;

sub add_default_roles {
    my ($self) = @_;
    $self->do(<<'_EOC_');
insert into _roles (name, description, login)
values ('Admin', 'Administrator', 'password');

insert into _roles (name, description, login)
values ('Public', 'Anonymous', 'anonymous');
_EOC_
}

sub add_user {
    my ($self, $user) = @_;
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
        native_type varchar(20) default 'text',
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
    $self->add_default_roles;
    return $retval;
}

1;

