#!/usr/bin/env perl

use strict;
use warnings;

use Text::CSV;

my $csv = Text::CSV->new({binary => 1});
while (<>) {
    s/\s*\|\s*$/\n/g;
    my @cols = split /\|/;
    my $count = grep { $_ } @cols;
    next if !$cols[0] or !$cols[1] or $count < 4;
    print join(",", @cols);
}

