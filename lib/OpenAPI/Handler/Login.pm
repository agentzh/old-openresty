package OpenAPI;

use Smart::Comments;
use strict;
use warnings;
use vars qw($Dumper);
use CGI::Cookie;

sub GET_login_user {
    my ($self, $bits) = @_;
    my $user = $bits->[1];
    _STRING($user) or die "Bad user name: ", $Dumper->($user), "\n";
    my $cookies = CGI::Cookie->fetch;
    my $account;
    if ($cookies) {
        my $cookie = $cookies->{account};
        if ($cookie) {
            $account = $cookie->value;
        }
    }
    my $role = 'Admin';
    if ($user =~ /^(\S+)\.(\S+)$/) {
        ($account, $role) = ($1, $2);
    } elsif ($user =~ /^\.(\S+)$/) {
        $role = $1;
    } elsif ($user =~ /^\S+$/) {
        $account = $&;
    }else {
        die "Invalid user name: ", $Dumper->($user), "\n";
    }
    _IDENT($account) or die "Bad account name: ", $Dumper->($account), "\n";
    _IDENT($role) or die "Bad role name: ", $Dumper->($role), "\n";
    ### $role
    if (!$account) {
        die "No account name specified: $user\n";
    }
    if (!$role) {
        die "No role name specified: $user\n";
    }
    $self->set_user($account);
    $self->set_role($role);
    my $res = $self->{_cookie} = {
        account => $account,
        role => $role,
    };
    $res->{success} = 1;
    $res;
}

1;

