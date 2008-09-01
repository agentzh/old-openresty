package OpenResty::Handler::LastResponse;

use strict;
use warnings;

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('last');

sub requires_acl { undef }

sub level2name {
    (undef, 'last_response_wo_id', 'last_response')[$_[-1]]
}

sub GET_last_response_wo_id {
    die "No last response ID specified.";
}

sub GET_last_response {
    my ($self, $openresty, $bits) = @_;
    die "Only /=/last/response is allowed.\n" if $bits->[1] ne 'response';
    my $last_res_id = $bits->[2];
    my $res = $OpenResty::Cache->get_last_res($last_res_id);
    if (!defined $res) {
        die "No last response found for ID $last_res_id";
        return;
    }
    $openresty->{_bin_data} = "$res\n";
    #warn "last_response: $response_from_cookie\n";
    return;
}

sub set_last_response {
    my ($self, $openresty, $value) = @_;
        #warn "!!!!!!!!!!!!!!!!!!!!!!!!!!wdy!";

    my $id = $openresty->builtin_param('_last_response');
    if ($id) {
        $OpenResty::Cache->set_last_res($id, $value);
    }
}

1;

