use strict;
use warnings;

use lib 'lib';
use Test::More 'no_plan';
use OpenAPI::Backend::PgFarm;
use Data::Dumper;
use subs 'dump';

use constant {
    NUM_OF_NODES => 2,
    TRIALS => 10,
};

my $backend = OpenAPI::Backend::PgFarm->new({ RaiseError => 0 });
ok $backend, "database handle okay";
if ($backend->has_user("agentz")) {
    #    $backend->do("drop table test cascade");
    $backend->drop_user("agentz");
}

my @userdb;
my %cnt;
my $res;
for (my $i = 0 ; $i < TRIALS; $i ++) {
    my $name = sprintf "%s%d", "t_", int(rand()*10000);
	
    eval {
        $backend->drop_user($name);
    };
    $res = $backend->add_user($name);
    $res = $backend->has_user($name);
    if (! $cnt{$res}) {$cnt{$res} = 0; }
    $cnt{$res} ++; 
	warn dump($name);
    push @userdb, $name;
}

#warn dump(\%cnt);
is scalar(keys %cnt), NUM_OF_NODES, 'all of the nodes visited';
while (my $b = pop @userdb) {
    $res = $backend->drop_user($b);
}

sub dump {
    my $var = shift;
    my $s = Dumper($var);
    $s =~ s/^\$VAR1\s*=\s*//;
    $s
}
