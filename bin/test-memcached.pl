use strict;
use warnings;
use Test::More;

use Cache::Memcached::libmemcached;
my @servers = map glob, @ARGV;
if (!@servers) { die "No server specified.\n"; }

plan tests => 2 * @servers;

for my $server (@servers) {
    my $obj = Cache::Memcached::libmemcached->new({
        servers => [$server],
    });

    ok $obj, "$server - memcached obj ok";
    $obj->delete('foo');
    $obj->set(foo => $server, 3);
    my $value = $obj->get('foo');
    is $value, $server, "$server - successfully set and get the key foo";
}

