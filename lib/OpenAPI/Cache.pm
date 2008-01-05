package OpenAPI::Cache;

use strict;
use warnings;
use FindBin;

# This is a hack...

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    my $params = shift;
    my $expire_time = $params->{expired};
    my $spec = $ENV{OPENAPI_CACHE} || 'mmap';
    my $obj;
    my $self = bless {}, $class;
    if ($spec eq 'mmap') {
        require Cache::FastMmap;
        $obj = Cache::FastMmap->new(
            share_file => "/tmp/openapi-mmap.dat",
            expire_time => $expire_time,
        );
    } elsif ($spec =~ /^memcached\:(.+)$/) {
        my $list = $1;
        require Cache::Memcached::Fast;
        my @addr = split /\s*,\s*|\s+/, $list;
        $obj = Cache::Memcached::Fast->new({
            servers => [@addr],
        });
        #$obj->set(dog => 32);
        #die "Dog value: ", $obj->get('dog');
        $self->{expire_time} = $expire_time;
        #die $obj;
    } else {
        die "Invalid OPENAPI_CACHE value: $spec\n";
    }
    $self->{obj} = $obj;
    return $self;
}

sub set {
    my ($self, $key, $val) = @_;
    my $expire_time = $self->{expire_time};
    $self->{obj}->set($key, $val, $expire_time ? $expire_time : ());
}

sub get {
    $_[0]->{obj}->get($_[1]);
}

sub remove {
    my $self = shift;
    my $obj = $self->{obj};
    if ($obj->can('remove')) {
        $obj->remove(@_);
    } else {
        $obj->delete(@_);
    }
}

1;

