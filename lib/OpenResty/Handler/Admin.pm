package OpenResty::Handler::Admin;

use strict;
use warnings;

use Params::Util qw( _STRING );

sub POST_admin_op {
    my ($self, $openresty, $bits) = @_;
    my $op = $bits->[1];
    if ($op ne 'select' and $op ne 'do') {
        die "Admin operation not supported: $op\n";
    }
    ### $op
    my $sql = _STRING($openresty->{_req_data}) or
        die "SQL literal must be a string.\n";

    if ($op eq 'select') {
        return $openresty->select($sql, { use_hash => 1 });
    } elsif ($op eq 'do') {
        $openresty->do($sql);
        return { success => 1 };
    }
}

1;

