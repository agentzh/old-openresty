package OpenAPI::Cache;

use strict;
use warnings;
use FindBin;

# This is a hack...

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    my $params = shift;
    my $expire_time = $params->{expired};
    my $type = $OpenAPI::Config{'cache.type'} or
        die "No cache.type specified in the config files.\n";
    my $obj;
    my $self = bless {}, $class;
    my $share_file = "/tmp/openapi-mmap.dat";
    if (-e $share_file && (!-r $share_file || !-w $share_file)) {
        $share_file = "$FindBin::Bin/openapi-mmap.dat";
    }
    if ($type eq 'mmap') {
        require Cache::FastMmap;
        $obj = Cache::FastMmap->new(
            share_file => $share_file,
            expire_time => $expire_time,
        );
    } elsif ($type eq 'memcached') {
        my $list = $OpenAPI::Config{'cache.servers'} or
            die "No cache.servers specified in the config files.\n";
        require Cache::Memcached::Fast;
        my @addr = split /\s*,\s*|\s+/, $list;
        if (!@addr) {
            die "No memcached server found: $list.\n";
        }
        $obj = Cache::Memcached::Fast->new({
            servers => [@addr],
        });
        #$obj->set(dog => 32);
        #die "Dog value: ", $obj->get('dog');
        $self->{expire_time} = $expire_time;
        #die $obj;
    } else {
        die "Invalid cache.type value: $type\n";
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

