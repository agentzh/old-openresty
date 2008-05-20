#!/usr/bin/env perl

use strict;
use warnings;
use Parse::RandGen::Regexp;

my $list_len = 100;
my $cmp_a = 1000;
my $cmp_b = 1000;
my $symbol = qr/[A-Za-z]\w*/;
my $ident = qr/"$symbol"|\$$symbol|\$foo/;
my $ident_list = qr/$ident(\s*,\s*$ident){$list_len,}/;
my $int = qr/[-+]?\d+/;
my $float = qr/[-+]?(\d+\.(\d+)?|\.\d+)/;
my $number = qr/$int|$float/;
my $atom = qr/$number|$ident/;
my $rel_op = qr/>|>=|<|<=|!=|<>| like /;
my $cmp = qr/$atom\s*$rel_op\s*$atom/;
my $logic_op = qr/and|or/;
my $logic_exp = qr/$cmp\s+$logic_op\s+$cmp/;
my $cond = qr/$logic_exp(\s+$logic_op\s+$logic_exp){$cmp_a,$cmp_b}/;
my $gen = Parse::RandGen::Regexp->new(qr/select $ident_list from $ident_list where $cond/);
print $gen->pick;

