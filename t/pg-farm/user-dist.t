#!/usr/bin/env perl

use strict;
use warnings;

my ($reason, $env);
BEGIN {
    $env = 'OPENAPI_TEST_CLUSTER';
    $reason = "environment $env not set.";
}
use Test::More $ENV{$env} ? 'no_plan' : (skip_all => $reason);

use lib 'lib';
use OpenAPI::Backend::PgFarm;
use Data::Dumper;
use subs 'dump';

use constant {
    NODE_COUNT => 2,
    USER_COUNT => 10,
};

my $backend = OpenAPI::Backend::PgFarm->new({ RaiseError => 0 });
ok $backend, "database handle okay";

=pod

if ($backend->has_user("agentz")) {
    #    $backend->do("drop table test cascade");
    $backend->drop_user("agentz");
}

=cut

my @userdb;
my %cnt;
my $res;
for (my $i = 0 ; $i < USER_COUNT; $i ++) {
    my $name = "t_" . rand_str(15);

=pod

    eval {
        $backend->drop_user($name);
    };

=cut

    my $res = $backend->has_user($name);
    if ($res) {
        $backend->drop_user($name);
    }
    $backend->add_user($name, 'blahblahblah');
    my $machine = $backend->has_user($name);
    $cnt{$machine}++;
    print STDERR "$name\@$machine  ";
    push @userdb, $name;
}

#warn dump(\%cnt);
is scalar(keys %cnt), NODE_COUNT, 'all nodes been visited';
for my $b (@userdb) {
    #warn "$b...";
    $res = $backend->drop_user($b);
}

sub dump {
    my $var = shift;
    my $s = Dumper($var);
    $s =~ s/^\$VAR1\s*=\s*//;
    $s
}

sub rand_str {
    my $len = shift;
    my $s;
    for (1..$len) {
        $s .= chr(ord('a')+rand(25));
    }
    $s;
}

