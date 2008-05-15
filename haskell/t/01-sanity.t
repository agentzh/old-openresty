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
    run3 ['bin/restyscript', $block->in], \undef, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my @ln = split /\n+/, $stdout;
    my $ast = $block->ast;
    if (defined $ast) {
        is "$ln[0]\n", $ast, "AST ok - $desc";
    }
    is "$ln[1]\n", $block->out, "Pg/SQL output ok - $desc";
};

__DATA__

=== TEST 1: basic
--- in
select foo, bar from Bah
--- ast
Select [Column (Symbol "foo"),Column (Symbol "bar")] From [Model (Symbol "Bah")]
--- out
select "foo", "bar" from "Bah"



=== TEST 2: select only
--- in
select foo
--- ast
Select [Column (Symbol "foo")]
--- out
select "foo"



=== TEST 3: spaces around separator (,)
--- in
select id,name , age from  Post , Comment
--- ast
Select [Column (Symbol "id"),Column (Symbol "name"),Column (Symbol "age")] From [Model (Symbol "Post"),Model (Symbol "Comment")]
--- out
select "id", "name", "age" from "Post", "Comment"



=== TEST 4: simple where clause
--- in
select id from Post where a > b
--- ast
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (Compare ">" (Column (Symbol "a")) (Column (Symbol "b")))
--- out
select "id" from "Post" where "a" > "b"



=== TEST 5: floating-point numbers
--- in
select id from Post where 00.003 > 3.14 or 3. > .0
--- out
select "id" from "Post" where (0.003 > 3.14 or 3.0 > 0.0)



=== TEST 6: integral numbers
--- in
select id from Post where 256 > 0
--- ast
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (Compare ">" (Integer 256) (Integer 0))
--- out
select "id" from "Post" where 256 > 0



=== TEST 7: simple or
--- in
select id from Post  where a > b or b <= c
--- out
select "id" from "Post" where ("a" > "b" or "b" <= "c")



=== TEST 8: and in or
--- in
select id from Post where a>b and a like b or b=c and d>=e or e<>d
--- out
select "id" from "Post" where ((("a" > "b" and "a" like "b") or ("b" = "c" and "d" >= "e")) or "e" <> "d")



=== TEST 9: with parens in and/or
--- in
select id from Post where (( a > b ) and ( b < c or c > 1 ))
--- out
select "id" from "Post" where ("a" > "b" and ("b" < "c" or "c" > 1))



=== TEST 10: literal strings
--- in
select id from Post where 'a''\'' != 'b\\\n\r\b\a'
--- out
select "id" from "Post" where 'a''''' != 'b\\\n\r\ba'



=== TEST 11: order by
--- in
select id order  by  id
--- ast
Select [Column (Symbol "id")] OrderBy [OrderPair (Column (Symbol "id")) "asc"]
--- out
select "id" order by "id" asc



=== TEST 12: complicated order by
--- in
select * order by id desc, name , foo  asc
--- out
select * order by "id" desc, "name" asc, "foo" asc



=== TEST 13: group by
--- in
select sum(id) group by id
--- out
select "sum"("id") group by "id"



=== TEST 14: select literals
--- in
 select 3.14 , 25, sum ( 1 ) , * from Post
--- out
select 3.14, 25, "sum"(1), * from "Post"



=== TEST 15: quoted symbols
--- in
select "id", "date_part"("created") from "Post" where "id" = 1
--- out
select "id", "date_part"("created") from "Post" where "id" = 1



=== TEST 16: offset and limit
--- in
select id from Post offset 3 limit 5
--- out
select "id" from "Post" offset 3 limit 5



=== TEST 17: offset and limit (with quoted values)
--- in
select id from Post offset '3' limit '5'
--- out
select "id" from "Post" offset '3' limit '5'



=== TEST 18: simple variable
--- in
select $var
--- ast
Select [Variable "var"]
--- out
select ?



=== TEST 19: variable as model
--- in
select * from $model_name, $bar
--- ast
Select [AnyColumn] From [Model (Variable "model_name"),Model (Variable "bar")]
--- out
select * from ?, ?



=== TEST 20: variable in where, offset, limit and group by
--- in
select * from A where $id > 0 offset $off limit $lim group by $foo
--- ast
Select [AnyColumn] From [Model (Symbol "A")] Where (Compare ">" (Variable "id") (Integer 0)) Offset (Variable "off") Limit (Variable "lim") GroupBy (Column (Variable "foo"))
--- out
select * from "A" where ? > 0 offset ? limit ? group by ?



=== TEST 21: weird identifiers
--- in
select select, 0.125 from from where where > or or and < and and order > 3.12 order by order, group group by by
--- out
select "select", 0.125 from "from" where ("where" > "or" or ("and" < "and" and "order" > 3.12)) order by "order" asc, "group" asc group by "by"



=== TEST 22: signed negative numbers
--- in
select -3 , - 3 , -1.25,- .3
--- out
select -3, -3, -1.25, -0.3



=== TEST 23: signed positive numbers
--- in
select +3 , + 3 , +1.25,+ .3 , 1
--- out
select 3, 3, 1.25, 0.3, 1



=== TEST 24: qualified columns
--- in
select Foo.bar , Foo . bar , "Foo" . bar , "Foo"."bar" from Foo
--- out
select "Foo"."bar", "Foo"."bar", "Foo"."bar", "Foo"."bar" from "Foo"



=== TEST 25: selected cols with parens
--- in
select (32) , ((5)) as item
--- ast
Select [Integer 32,Alias (Integer 5) (Symbol "item")]
--- out
select 32, 5 as "item"



=== TEST 26: count(*)
--- in
select count(*), count ( * ) from Post
--- out
select "count"(*), "count"(*) from "Post"



=== TEST 27: aliased cols
--- in
select id as foo, count(*) as bar from Post
--- ast
Select [Alias (Column (Symbol "id")) (Symbol "foo"),Alias (FuncCall "count" [AnyColumn]) (Symbol "bar")] From [Model (Symbol "Post")]
--- out
select "id" as "foo", "count"(*) as "bar" from "Post"



=== TEST 28: alias for models
--- in
select * from Post as foo
--- out
select * from "Post" as "foo"



=== TEST 29: from proc
--- in
select * from proc(32, 'hello'), blah(3) as poo
--- out
select * from "proc"(32, 'hello'), "blah"(3) as "poo"

