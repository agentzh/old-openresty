package OpenAPI::Cache;

use strict;
use warnings;
use FindBin;

# This is a hack...
use base 'Cache::FastMmap';

sub new {
    my $proto = shift;
    my $obj;
    eval {
        $obj = $proto->SUPER::new( share_file => "/tmp/openapi-mmap.dat" );
    };
    warn $@ if $@;
    $obj;
}

=pod
sub set {
}

sub get {
}
=cut

1;

