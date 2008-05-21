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
    my $rename = $block->rename;
    if (!$rename) { die "No rename section defined for $desc" }
    my ($old, $new) = split /\s+/, $rename;
    run3 [qw< bin/restyview rename >, $old, $new],
        \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    $stdout =~ s/\n+$/\n/s;
    my $out = $block->out;
    is $stdout, $out, "Renamed output ok - $desc";
};

__DATA__

=== TEST 1: basic
--- in
select $foo, $bar from $foo
--- rename: foo bar
--- out
select $bar, $bar from $bar



=== TEST 2: select only
--- in
select foo
--- rename: foo bar
--- out
select foo



=== TEST 3: spaces around separator (,)
--- in
select $foo,$bar , $age from  Post , $comment
--- rename: bar blah
--- out
select $foo,$blah , $age from  Post , $comment



=== TEST 4: spaces around separator (,)
--- in
select $foo,$bar , $age from  Post , $comment
--- rename: comment blah
--- out
select $foo,$bar , $age from  Post , $blah



=== TEST 5: spaces around separator (,)
--- in
select $foo,
$bar ,
$age from  Post , $comment
--- rename: age blah
--- out
select $foo,
$bar ,
$blah from  Post , $comment



=== TEST 6: spaces around separator (,)
--- in
select $foo,
$bar , $age,
$age from  Post where '$age' > $age
--- rename: age agentzh
--- out
select $foo,
$bar , $agentzh,
$agentzh from  Post where '$age' > $agentzh



=== TEST 7: spaces around separator (,)
--- in
select $foo,
$bar ,
$age from  Post , $comment
--- rename: comment blah
--- out
select $foo,
$bar ,
$age from  Post , $blah



=== TEST 8: with parens in and/or
--- in
select id from Post where (( $a > $b ) and ( $b < $c or $c > 1 ))
--- rename: a x
--- out
select id from Post where (( $x > $b ) and ( $b < $c or $c > 1 ))



=== TEST 9: with parens in and/or
--- in
select sum($b) from Post where (( $a > $b ) and ( $b < $c or $c > 1 ))
--- rename: b x
--- out
select sum($x) from Post where (( $a > $x ) and ( $x < $c or $c > 1 ))



=== TEST 10: \t is 8 columns long
--- in eval
"select \tsum(\$b) from Post where\t\t ( \$a > \$b )"
--- rename: b x
--- out eval
"select \tsum(\$x) from Post where\t\t ( \$a > \$x )\n"

