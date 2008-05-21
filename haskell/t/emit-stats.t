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
    run3 [qw< bin/restyview stats >], \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my $out = $block->out;
    is $stdout, $out, "Stat output ok - $desc";
};

__DATA__

=== TEST 1: basic
--- in
select foo, bar from Bah
--- out
{"modelList":["Bah"],"funcList":[],"selectedMax":2,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 2: select only
--- in
select foo
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 3: spaces around separator (,)
--- in
select id,name , age from  Post , Comment
--- out
{"modelList":["Post","Comment"],"funcList":[],"selectedMax":3,"joinedMax":2,"comparedCount":0,"queryCount":1}



=== TEST 4: simple where clause
--- in
select id from Post where a > b
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":1,"queryCount":1}



=== TEST 5: floating-point numbers
--- in
select id from Post where 00.003 > 3.14 or 3. > .0
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":2,"queryCount":1}



=== TEST 6: and in or
--- in
select id from Post where a>b and a like b or b=c and d>=e or e<>d
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":5,"queryCount":1}



=== TEST 7: with parens in and/or
--- in
select id from Post where (( a > b ) and ( b < c or c > 1 ))
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":3,"queryCount":1}



=== TEST 8: order by
--- in
select id order  by  id
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 9: complicated order by
--- in
select * order by id desc, name , foo  asc
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 10: group by
--- in
select sum(id) group by id
--- out
{"modelList":[],"funcList":["sum"],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 11: select literals
--- in
 select 3.14 , 25, sum ( 1 ) , * from Post
--- out
{"modelList":["Post"],"funcList":["sum"],"selectedMax":4,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 12: quoted symbols
--- in
select "id", "date_part"("created") from "Post" where "id" = 1
--- out
{"modelList":["Post"],"funcList":["date_part"],"selectedMax":2,"joinedMax":1,"comparedCount":1,"queryCount":1}



=== TEST 13: offset and limit
--- in
select id from Post offset 3 limit 5
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 14: offset and limit (with quoted values)
--- in
select id from Post offset '3' limit '5'
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 15: simple variable
--- in
select $var
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 16: variable as model
--- in
select * from $model_name, $bar, $foo(3)
--- out
{"modelList":["$model_name","$bar"],"funcList":["$foo"],"selectedMax":1,"joinedMax":3,"comparedCount":0,"queryCount":1}



=== TEST 17: variable in where, offset, limit and group by
--- in
select * from A where $id > 0 offset $off limit $lim group by $foo
--- out
{"modelList":["A"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":1,"queryCount":1}



=== TEST 18: weird identifiers
--- in
select select, 0.125 from from where where > or or and < and and order > 3.12 order by order, group group by by
--- out
{"modelList":["from"],"funcList":[],"selectedMax":2,"joinedMax":1,"comparedCount":3,"queryCount":1}



=== TEST 19: qualified columns
--- in
select Foo.bar , Foo . bar , "Foo" . bar , "Bar"."bar" from Foo
--- out
{"modelList":["Foo"],"funcList":[],"selectedMax":4,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 20: selected cols with parens
--- in
select (32) , ((5)) as item
--- out
{"modelList":[],"funcList":[],"selectedMax":2,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 21: count(*)
--- in
select count(*),
     count ( * )
 from Post
--- out
{"modelList":["Post"],"funcList":["count","count"],"selectedMax":2,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 22: aliased cols
--- in
select id as foo, count(*) as bar
from Post
--- out
{"modelList":["Post"],"funcList":["count"],"selectedMax":2,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 23: alias for models
--- in
select * from Post as foo
--- out
{"modelList":["Post"],"funcList":[],"selectedMax":1,"joinedMax":1,"comparedCount":0,"queryCount":1}



=== TEST 24: from proc
--- in
select *
from proc(32, 'hello'), blah() as poo
--- out
{"modelList":[],"funcList":["proc","blah"],"selectedMax":1,"joinedMax":2,"comparedCount":0,"queryCount":1}



=== TEST 25: arith
--- in
select 3+5/3*2 - 36 % 2
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 26: arith (with parens)
--- in
select (3+5)/(3*2) - ( 36 % 2 )
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 27: string cat ||
--- in
select proc(2) || 'hello' || 5 - 2 + 5
--- out
{"modelList":[],"funcList":["proc"],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 28: ^
--- in
select 3*3*5^6^2
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 29: union
--- in
select 2 union select 3
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":2}



=== TEST 30: union two big select
--- in
(select max(*) from Post, Comment where a > 3) union
(select min(*) from Post, Student where b < 5) intersect
(select sum(*), 3, 2 from Blah)
--- out
{"modelList":["Post","Comment","Post","Student","Blah"],"funcList":["max","min","sum"],"selectedMax":3,"joinedMax":2,"comparedCount":2,"queryCount":3}



=== TEST 31: union 2
--- in
(select count(*) from "Post" limit 3) union select sum(1) from "Comment";
--- out
{"modelList":["Post","Comment"],"funcList":["count","sum"],"selectedMax":1,"joinedMax":1,"comparedCount":0,"queryCount":2}



=== TEST 32: chained union
--- in
select 3 union select 2 union select 1;
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":3}



=== TEST 33: chained union and except
--- in
select 3 union select 2 union select 1 except select 2;
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":4}



=== TEST 34: parens with set ops
--- in
select 3 union (select 2 except select 3)
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":3}



=== TEST 35: union all
--- in
select 2 union all select 2
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":2}



=== TEST 36: type casting ::
--- in
select 32::float8
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}



=== TEST 37: more complicated type casting ::
--- in
select ('2003-03' || '-01') :: date
--- out
{"modelList":[],"funcList":[],"selectedMax":1,"joinedMax":0,"comparedCount":0,"queryCount":1}

