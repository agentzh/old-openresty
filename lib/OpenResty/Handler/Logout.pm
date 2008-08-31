package OpenResty::Handler::Logout;

use strict;
use warnings;

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('logout');

sub requires_acl { undef }

sub level2name {
    qw< logout >[$_[-1]];
}

sub GET_logout {
    ### Yeah yeah yeah!
    my ($self, $openresty, $bits) = @_;
    my $session = $openresty->get_session;
    #my $session = $openresty->{_session};
    #warn "session: $session";
    if ($session) {
        $OpenResty::Cache->remove($session);
    }
    #warn "HERE!";
    $openresty->{_bin_data} = "{\"success\":1}\n";
    return undef;
}

1;
