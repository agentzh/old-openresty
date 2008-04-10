#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use OpenResty::Config;

my $reason;
BEGIN {
    OpenResty::Config->init('.');
    if ($OpenResty::Config{'backend.type'} ne 'PgFarm') {
        $reason = 'backend.type in the config files is not PgFarm.';
    }
}
use Test::More $reason ? (skip_all => $reason) : 'no_plan';

use OpenResty::Backend::PgFarm;

use Data::Dumper;
use subs 'dump';

use constant {
    NODE_COUNT => 2,
    USER_COUNT => 10,
};

OpenResty::Config->init('.');
my $backend = OpenResty::Backend::PgFarm->new({ RaiseError => 0 });
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

