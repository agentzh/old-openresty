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
    run3 [qw< bin/restyview frags >], \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my @ln = split /\n+/, $stdout;
    my $out = $block->out;
    is "$ln[0]\n", $out, "Pg/SQL output ok - $desc";
};

__DATA__

=== TEST 1: simple for column
--- in
select -foo, +bar from Bah
--- out
["select -\"foo\", \"bar\" from \"Bah\""]



=== TEST 2: simple for function
--- in
select -count(foo), +max(id) from Bah
--- out
["select -\"count\"(foo), \"max\"(id) from \"Bah\""]



=== TEST 3: simple for var
--- in
select -$v, +$v from vertical
--- out
["select -",["v","unknown"],", ",["v","unknown"]," from \"vertical\"]



=== TEST 4: for column in bracketes
--- in
select -(foo), +(bar) from Bah
--- out
["select -\"foo\", \"bar\" from \"Bah\""]



=== TEST 5: for function in bracketes
--- in
select -(count(foo)), +(max(id)) from Bah
--- out
["select -\"count\"(\"foo\") \"max\"(\"id\") from \"Bah\""]



=== TEST 6: for $var in bracketes
--- in
select -($v), +($v) from vertical
--- out
["select -",["v","unknown"],", ",["v","unknown"]," from \"vertical\"]



=== TEST 7: remove duplicated bracketes
--- in
select -((1)), +((no)), -((func(1)))), +(($v))
--- out
["select -1, \"no\", -\"func\"(1), ",["v","unknown"]]



=== TEST 8: complex expression
--- in
select -$k * 3 / -func(t - -v * +$c)
--- out
["select ((-",["k","unknown"]," * 3) / -\"func\"(\"t\" - (-\"v\" * ",["c","unknown"],")))"]



=== TEST 9: -- --> remove && ++ --> remove ?
--- in
select -(-v), +(+v)
--- out
["select \"v\", \"v\"]



=== TEST 10: +- --> - && -+ --> - ?
--- in
select +(-v), -(+v)
--- out
["select -\"v\", -\"v\""]



=== TEST 11: type casting ::
--- in
select -32::float8
--- out
["select -32::\"float8\""]



=== TEST 12: type casting ::
--- in
select -$foo::$bar, +$foo::$bar
--- out
["select -",["foo","unknown"],"::",["bar","symbol"],", ",["foo","unknown"],"::",["bar","symbol"]]



=== TEST 13: type casting ::
--- in
select -$foo::float8, +$foo::float8
--- out
["select -",["foo","unknown"],"::\"float8\"",", ",["foo","unknown"],"::\"float8\""]



=== TEST 14: type casting ::
--- in
select 21::-$bar
--- out
[error]



=== TEST 15: type casting ::
--- in
select 21::-float8
--- out
[error]



=== TEST 16: type casting ::
--- in
select 21::+$bar
--- out
[error]



=== TEST 17: type casting ::
--- in
select 21::+float8
--- out
[error]



=== TEST 18: type casting :: 
--- in
select ('2003-03' || '-01' || -$foo) :: date
--- out
["select (('2003-03' || '-01') || -",["foo",unknown],") :: date"]



=== TEST 19: type casting ::
--- in
select ('2003-03' || '-01' || +$foo) :: date
--- out
["select (('2003-03' || '-01') || ",["foo",unknown],") :: date"]



=== TEST 20: +- in where clause
--- in
select id from Post where -a > +b
--- out
["select \"id\" from \"Post\" where -\"a\" > \"b\""]



=== TEST 21: +- in where clause
--- in
select id from Post where -00.003 > +3.14 or -3. > +.0 or +3 > -1
--- out
["select \"id\" from \"Post\" where ((-0.003 > 3.14 or -3.0 > 0.0) or 3 > -1)"]



=== TEST 22: var in qualified col
--- in
select -$table.$col from $table
--- out
["select -",["table","symbol"],".",["col","symbol"]," from ",["table","symbol"]]



=== TEST 23: var in qualified col
--- in
select +$table.col from $table
--- out
["select ",["table","symbol"],".\"col\" from ",["table","symbol"]]



=== TEST 24: var in qualified col
--- in
select $table.-$col from $table
--- out
[error]



=== TEST 25: var in proc call
--- in
select -$proc(32)
--- out
["select -",["proc","symbol"],"(32)"]



=== TEST 26: aliased cols
--- in
select id as foo, -count(*) as bar
from Post
--- out
["select \"id\" as \"foo\", -\"count\"(*) as \"bar\" from \"Post\""]



=== TEST 27: not
--- in
select * from test where not a > b or not (b < c) and (not c) = true
--- out
["select * from \"test\" where ((not (\"a\" > \"b\")) or ((not (\"b\" < \"c\")) and (not \"c\") = true))"]
