package OpenResty::Backend;

#use Smart::Comments;
use strict;
use warnings;

sub new {
    my ($class, $backend) = @_;
    if (!$backend) {
        die "No backend specified";
    }
    my $backend_class = $class . '::' . $backend;
    ### $backend_class
    eval "use $backend_class";
    if ($@) {
        die $@;
    }
    $backend_class->new({ PrintWarn => 0 });
}

1;
