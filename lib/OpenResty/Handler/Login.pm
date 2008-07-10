package OpenResty::Handler::Login;

#use Smart::Comments;
use strict;
use warnings;

use CGI::Simple::Cookie;
use OpenResty::Util;
use Params::Util qw( _STRING );

#*login = \&login_by_sql;
*login = \&login_by_perl;

sub GET_login_user {
    my ($self, $openresty, $bits) = @_;
    my $user = $bits->[1];
    $self->login($openresty, $user);
}

sub GET_login_user_password {
    my ($self, $openresty, $bits) = @_;
    my $user = $bits->[1];
    my $password = $bits->[2];
    $self->login($openresty, $user, { password => $password });
}

sub login_by_perl {
    my ($self, $openresty, $user, $params) = @_;
    _STRING($user) or die "Bad user name: ", $OpenResty::Dumper->($user), "\n";
    $params ||= {};
    ### $params
    ### caller: caller()
    my $password = $params->{password};
    my $captcha = $params->{captcha};
    my $account;
    my $role = 'Admin';
    if ($user =~ /^(\w+)\.(\w+)$/) {
        ($account, $role) = ($1, $2);
    } elsif ($user =~ /^\w+$/) {
        $account = $&;
    } else {
        die "Bad user name: ", $OpenResty::Dumper->($user), "\n";
    }
    _IDENT($account) or die "Bad account name: ", $OpenResty::Dumper->($account), "\n";
    _IDENT($role) or die "Bad role name: ", $OpenResty::Dumper->($role), "\n";
    ### $role
    # this part is lame?
    if (!$account) {
        die "Login required.\n";
    }
    if (!$openresty->has_user($account)) {
        ### Found user: $user
        die "Account \"$account\" does not exist.\n";
    }
    $openresty->set_user($account);

    my $login_meth = $openresty->has_role($role);
    if (!$login_meth) {
        ### Found user: $user
        die "Role \"$role\" does not exist.\n";
    }

    ### $account
    ### $role
    ### $password
    ### capture param:  $captcha
    if (defined $captcha) {
        my ($id, $user_sol) = split /:/, $captcha, 2;
        if (!$id or !$user_sol) {
            die "Bad captcha parameter: $captcha\n";
        }
        ### with captcha: $res
        #warn "!!! $login_meth !!!\n";
        if ($login_meth ne 'captcha') {
            die "Cannot login as $account.$role via captchas.\n";
        }

        my ($rc, $err) = OpenResty::Handler::Captcha::validate_captcha($openresty,$id,$user_sol);
        if (!$rc) {
            die $err."\n";
        }
    } elsif (defined $password) {
        if (!$login_meth eq 'password') {
            die "Password for $account.$role is incorrect.\n";
        }
        my $res = $openresty->select("select count(*) from _roles where name = " . Q($role) . " and password = " . Q($password) . ";");
        ### with password: $res
        if ($res->[0][0] == 0) {
            die "Password for $account.$role is incorrect.\n";
        }
    } else {
        if ($role eq 'Admin') {
            die "$account.$role is not anonymous.\n";
        }
        if ($role ne 'Public') {
            if ($login_meth ne 'anonymous') {
                ### dying...
                die "$account.$role is not anonymous.\n";
            }
        }
    }
    $openresty->set_role($role);

    my $session_from_cookie = $openresty->{_session_from_cookie};
    ### Get session ID from cookie: $session_from_cookie
    if ($session_from_cookie) {
        $OpenResty::Cache->remove($session_from_cookie)
    }

    #my $captcha_from_cookie = $openresty->{_captcha_from_cookie};
    #if ($captcha_from_cookie) {
        #$OpenResty::Cache->remove($captcha_from_cookie);
    #}

    my $uuid = $OpenResty::UUID->create_str;
    if ($openresty->{_use_cookie}) {
        $openresty->{_cookie} = { session => $uuid };
    }
    $OpenResty::Cache->set($uuid => "$account.$role", 48 * 3600);  # expire in 8 h

    return {
        success => 1,
        account => $account,
        role => $role,
        session => $uuid,
    };
}

sub login_by_sql {
    my ($self, $openresty, $user, $params) = @_;
    _STRING($user) or die "Bad user name: ", $OpenResty::Dumper->($user), "\n";
    $params ||= {};
    ### $params
    ### caller: caller()
    my $password = $params->{password};
    my $captcha = $params->{captcha};
    my $account;
    my $role = 'Admin';
    if ($user =~ /^(\w+)\.(\w+)$/) {
        ($account, $role) = ($1, $2);
    } elsif ($user =~ /^\w+$/) {
        $account = $&;
    } else {
        die "Bad user name: ", $OpenResty::Dumper->($user), "\n";
    }
    _IDENT($account) or die "Bad account name: ", $OpenResty::Dumper->($account), "\n";
    _IDENT($role) or die "Bad role name: ", $OpenResty::Dumper->($role), "\n";
    ### $role
    # this part is lame?
    if (!$account) {
        die "Login required.\n";
    }

    ### True sol: $true_sol
    $openresty->set_user($account);
    $OpenResty::Backend->login($account, $role, $captcha, $password);

    if (defined $captcha) {
        my ($id, $user_sol) = split /:/, $captcha, 2;

        my ($rc,$err)=OpenResty::Handler::Captcha::validate_captcha($openresty,$id,$user_sol);
        if (!$rc) {
            die $err."\n";
        }
    }

    $openresty->set_role($role);

    my $session_from_cookie = $openresty->{_session_from_cookie};
    ### Get session ID from cookie: $session_from_cookie
    if ($session_from_cookie) {
        $OpenResty::Cache->remove($session_from_cookie)
    }

    #my $captcha_from_cookie = $openresty->{_captcha_from_cookie};
    #if ($captcha_from_cookie) {
        #$OpenResty::Cache->remove($captcha_from_cookie);
    #}

    my $uuid = $OpenResty::UUID->create_str;
    if ($openresty->{_use_cookie}) {
        $openresty->{_cookie} = { session => $uuid };
    }
    $OpenResty::Cache->set($uuid => "$account.$role", 48 * 3600);  # expire in 8 h

    return {
        success => 1,
        account => $account,
        role => $role,
        session => $uuid,
    };
}

1;
__END__

=head1 NAME

OpenResty::Handler::Login - The login handler for OpenResty

=head1 SYNOPSIS

=head1 DESCRIPTION

This OpenResty handler class implements the Login API, i.e., the C</=/login/*> stuff.

=head1 METHODS

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@gmail.com >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

