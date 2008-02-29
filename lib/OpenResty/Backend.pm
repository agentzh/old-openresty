package OpenResty::Backend;

use strict;
use warnings;

sub new {
    my ($class, $backend) = @_;
    if (!$backend) {
        die "No backend specified";
    }
    my $backend_class = $class . '::' . $backend;
    eval "use $backend_class";
    if ($@) {
        die $@;
    }
    $backend_class->new;
}

1;
