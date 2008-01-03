package OpenAPI;

#use Smart::Comments;
use strict;
use warnings;
use vars qw($Cache $UUID $Dumper);
use CGI::Cookie;

sub GET_login_user {
    my ($self, $bits) = @_;
    my $user = $bits->[1];
    $self->login($user);
}

sub GET_login_user_password {
    my ($self, $bits) = @_;
    my $user = $bits->[1];
    my $password = $bits->[2];
    $self->login($user, $password);
}

sub login {
    my ($self, $user, $password) = @_;
    _STRING($user) or die "Bad user name: ", $Dumper->($user), "\n";
    my $account;
    my $role = 'Admin';
    if ($user =~ /^(\w+)\.(\w+)$/) {
        ($account, $role) = ($1, $2);
    } elsif ($user =~ /^\w+$/) {
        $account = $&;
    } else {
        die "Bad user name: ", $Dumper->($user), "\n";
    }
    _IDENT($account) or die "Bad account name: ", $Dumper->($account), "\n";
    _IDENT($role) or die "Bad role name: ", $Dumper->($role), "\n";
    ### $role
    # this part is lame?
    if (!$account) {
        die "Login required.\n";
    }
    if (!$self->has_user($account)) {
        ### Found user: $user
        die "Account \"$account\" does not exist.\n";
    }
    $self->set_user($account);

    if (!$self->has_role($role)) {
        ### Found user: $user
        die "Role \"$role\" does not exist.\n";
    }

    ### $account
    ### $role
    ### $password
    if (defined $password) {
        my $res = $self->select("select count(*) from _roles where name = " . Q($role) . " and login = 'password' and password = " . Q($password) . ";");
        ### with password: $res
        if ($res->[0][0] == 0) {
            die "Password for $account.$role is incorrect.\n";
        }
    } else {
        my $res = $self->select("select count(*) from _roles where name = " . Q($role) . " and login = 'anonymous';");
        ### no password: $res
        ### no password (2): $res->[0][0]
        if ($res->[0][0] == 0) {
            ### dying...
            die "Password for $account.$role is required.\n";
        }
    }
    $self->set_role($role);

    my $uuid = $UUID->create_from_name_str($account, $role);
    $self->{_cookie} = { session => $uuid };
    $Cache->set($uuid => "$account.$role");

    return {
        success => 1,
        account => $account,
        role => $role,
    };
}

1;

