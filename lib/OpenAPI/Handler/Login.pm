package OpenAPI;

#use Smart::Comments;
use strict;
use warnings;
use vars qw($Cache $UUID $Dumper);
use CGI::Cookie;
use Encode 'is_utf8';

sub GET_login_user {
    my ($self, $bits) = @_;
    my $user = $bits->[1];
    $self->login($user);
}

sub GET_login_user_password {
    my ($self, $bits) = @_;
    my $user = $bits->[1];
    my $password = $bits->[2];
    $self->login($user, { password => $password });
}

sub trim_sol {
    my $s = $_[0];
    unless (is_utf8($s)) {
        $s = decode('UTF-8', $s);
    }
    $s =~ s/\W+//g;
    $s;
}

sub login {
    my ($self, $user, $params) = @_;
    _STRING($user) or die "Bad user name: ", $Dumper->($user), "\n";
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
    ### capture param:  $captcha
    if (defined $captcha) {
        my ($id, $user_sol) = split /:/, $captcha, 2;
        if (!$id or !$user_sol) {
            die "Bad captcha parameter: $captcha\n";
        }
        my $res = $self->select("select count(*) from _roles where name = " . Q($role) . " and login = 'captcha'");
        ### with captcha: $res
        if ($res->[0][0] == 0) {
            die "Cannot login as $account.$role via captchas.\n";
        }
        ### Captcha ID: $id
        my $true_sol = $Cache->get($id);
        ### True sol: $true_sol
        $Cache->remove($id);
        if (!defined $true_sol) {
            die "Capture ID is bad or expired.\n";
        }
        if ($true_sol eq '1') {
            die "Captcha image never used.\n";
        }
        # XXX for testing purpose...
        if ($account eq 'peee' && $role eq 'Poster') {
            if ($true_sol =~ /[a-z]/) {
                $true_sol = 'hello world ';
            } else {
                $true_sol = '你好世界';
            }
        }
        if (trim_sol($user_sol) ne trim_sol($true_sol)) {
            die "Solution to the captcha is incorrect.\n";
        }
    } elsif (defined $password) {
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

    my $session_from_cookie = $self->{_session_from_cookie};
    ### Get session ID from cookie: $session_from_cookie
    if ($session_from_cookie) {
        $OpenAPI::Cache->remove($session_from_cookie)
    }

    my $captcha_from_cookie = $self->{_captcha_from_cookie};
    if ($captcha_from_cookie) {
        $OpenAPI::Cache->remove($captcha_from_cookie);
    }

    my $uuid = $UUID->create_str;
    $self->{_cookie} = { session => $uuid };
    $Cache->set($uuid => "$account.$role");

    return {
        success => 1,
        account => $account,
        role => $role,
    };
}

1;

