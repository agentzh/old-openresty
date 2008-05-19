#!/usr/bin/env perl
# vi:filetype=

use strict;
use warnings;

use IPC::Run3;
use Test::Base 'no_plan';
#use Test::LongString;

run {
    my $block = shift;
    my $desc = $block->description;
    my ($stdout, $stderr);
    my $stdin = $block->in;
    run3 [qw< bin/restyscript stats >], \$stdin, \$stdout, \$stderr;
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
Stats {modelList = ["Bah"], funcList = [], selectedMax = 2, joinedMax = 1, comparedCount = 0, queryCount = 1}


=== TEST 2: select only
--- in
select foo
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 3: spaces around separator (,)
--- in
select id,name , age from  Post , Comment
--- out
Stats {modelList = ["Post","Comment"], funcList = [], selectedMax = 3, joinedMax = 2, comparedCount = 0, queryCount = 1}



=== TEST 4: simple where clause
--- in
select id from Post where a > b
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 1, queryCount = 1}



=== TEST 5: floating-point numbers
--- in
select id from Post where 00.003 > 3.14 or 3. > .0
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 2, queryCount = 1}



=== TEST 8: and in or
--- in
select id from Post where a>b and a like b or b=c and d>=e or e<>d
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 5, queryCount = 1}



=== TEST 9: with parens in and/or
--- in
select id from Post where (( a > b ) and ( b < c or c > 1 ))
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 3, queryCount = 1}




=== TEST 11: order by
--- in
select id order  by  id
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 12: complicated order by
--- in
select * order by id desc, name , foo  asc
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}


=== TEST 13: group by
--- in
select sum(id) group by id
--- out
Stats {modelList = [], funcList = ["sum"], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}


=== TEST 14: select literals
--- in
 select 3.14 , 25, sum ( 1 ) , * from Post
--- out
Stats {modelList = ["Post"], funcList = ["sum"], selectedMax = 4, joinedMax = 1, comparedCount = 0, queryCount = 1}



=== TEST 15: quoted symbols
--- in
select "id", "date_part"("created") from "Post" where "id" = 1
--- out
Stats {modelList = ["Post"], funcList = ["date_part"], selectedMax = 2, joinedMax = 1, comparedCount = 1, queryCount = 1}



=== TEST 16: offset and limit
--- in
select id from Post offset 3 limit 5
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 0, queryCount = 1}


=== TEST 17: offset and limit (with quoted values)
--- in
select id from Post offset '3' limit '5'
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 0, queryCount = 1}



=== TEST 18: simple variable
--- in
select $var
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 19: variable as model
--- in
select * from $model_name, $bar
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 2, comparedCount = 0, queryCount = 1}



=== TEST 20: variable in where, offset, limit and group by
--- in
select * from A where $id > 0 offset $off limit $lim group by $foo
--- out
Stats {modelList = ["A"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 1, queryCount = 1}



=== TEST 21: weird identifiers
--- in
select select, 0.125 from from where where > or or and < and and order > 3.12 order by order, group group by by
--- out
Stats {modelList = ["from"], funcList = [], selectedMax = 2, joinedMax = 1, comparedCount = 3, queryCount = 1}



=== TEST 24: qualified columns
--- in
select Foo.bar , Foo . bar , "Foo" . bar , "Bar"."bar" from Foo
--- out
Stats {modelList = ["Foo"], funcList = [], selectedMax = 4, joinedMax = 1, comparedCount = 0, queryCount = 1}


=== TEST 25: selected cols with parens
--- in
select (32) , ((5)) as item
--- out
Stats {modelList = [], funcList = [], selectedMax = 2, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 26: count(*)
--- in
select count(*),
     count ( * )
 from Post
--- out
Stats {modelList = ["Post"], funcList = ["count","count"], selectedMax = 2, joinedMax = 1, comparedCount = 0, queryCount = 1}



=== TEST 27: aliased cols
--- in
select id as foo, count(*) as bar
from Post
--- out
Stats {modelList = ["Post"], funcList = ["count"], selectedMax = 2, joinedMax = 1, comparedCount = 0, queryCount = 1}



=== TEST 28: alias for models
--- in
select * from Post as foo
--- out
Stats {modelList = ["Post"], funcList = [], selectedMax = 1, joinedMax = 1, comparedCount = 0, queryCount = 1}



=== TEST 29: from proc
--- in
select *
from proc(32, 'hello'), blah() as poo
--- out
Stats {modelList = [], funcList = ["proc","blah"], selectedMax = 1, joinedMax = 2, comparedCount = 0, queryCount = 1}



=== TEST 30: arith
--- in
select 3+5/3*2 - 36 % 2
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 31: arith (with parens)
--- in
select (3+5)/(3*2) - ( 36 % 2 )
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 32: string cat ||
--- in
select proc(2) || 'hello' || 5 - 2 + 5
--- out
Stats {modelList = [], funcList = ["proc"], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 33: ^
--- in
select 3*3*5^6^2
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}



=== TEST 34: union
--- in
select 2 union select 3
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 2}


=== TEST 35: union two big select
--- in
(select max(*) from Post, Comment where a > 3) union
(select min(*) from Post, Student where b < 5) intersect
(select sum(*), 3, 2 from Blah)
--- out
Stats {modelList = ["Post","Comment","Post","Student","Blah"], funcList = ["max","min","sum"], selectedMax = 3, joinedMax = 2, comparedCount = 2, queryCount = 3}



=== TEST 35: union 2
--- in
(select count(*) from "Post" limit 3) union select sum(1) from "Comment";
--- out
Stats {modelList = ["Post","Comment"], funcList = ["count","sum"], selectedMax = 1, joinedMax = 1, comparedCount = 0, queryCount = 2}


=== TEST 36: chained union
--- in
select 3 union select 2 union select 1;
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 3}



=== TEST 37: chained union and except
--- in
select 3 union select 2 union select 1 except select 2;
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 4}



=== TEST 38: parens with set ops
--- in
select 3 union (select 2 except select 3)
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 3}



=== TEST 41: union all
--- in
select 2 union all select 2
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 2}


=== TEST 42: type casting ::
--- in
select 32::float8
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}




=== TEST 43: more complicated type casting ::
--- in
select ('2003-03' || '-01') :: date
--- out
Stats {modelList = [], funcList = [], selectedMax = 1, joinedMax = 0, comparedCount = 0, queryCount = 1}

