#!/usr/bin/env perl
# vi:filetype=

use strict;
use warnings;

use IPC::Run3;
use Test::Base;
#use Test::LongString;

plan tests => 2 * blocks();

run {
    my $block = shift;
    my $desc = $block->description;
    my ($stdout, $stderr);
    my $stdin = $block->in;
    run3 [qw< bin/restyaction stats >], \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my $out = $block->out;
    is $stdout, $out, "Stat output ok - $desc";
};

__DATA__

=== TEST 1: basic
--- in
update Comment set col=col+1 where date_part('day', created) > 3 and 2<3;
delete from Post where foo(created) = 2;
POST '/=/model/Post/~/~' { "foo": "bah" }
--- out
{"modelList":["Comment","Post"],"funcList":["date_part","foo"],"selectedMax":0,"joinedMax":0,"comparedCount":3,"queryCount":0}

