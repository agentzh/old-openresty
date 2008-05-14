#!/usr/bin/env perl

use strict;
use warnings;

use IPC::Run3;
use Test::Base;
use Test::LongString;

plan tests => 3 * blocks();

run {
    my $block = shift;
    my $desc = $block->description;
    my ($stdout, $stderr);
    run3 ['./restyscript', $block->in], \undef, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my @ln = split /\n+/, $stdout;
    is "$ln[0]\n", $block->ast, "AST ok - $desc";
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
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (OrExpr [AndExpr [RelExpr (">",Column (Symbol "a"),Column (Symbol "b"))]])
--- out
select "id" from "Post" where ((("a" > "b")))



=== TEST 5: simple or
--- in
select id from Post  where a > b or b <= c
--- ast
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (OrExpr [AndExpr [RelExpr (">",Column (Symbol "a"),Column (Symbol "b"))],AndExpr [RelExpr ("<=",Column (Symbol "b"),Column (Symbol "c"))]])
--- out
select "id" from "Post" where ((("a" > "b")) or (("b" <= "c")))



=== TEST 6: and in or
--- in
select id from Post where a > b and a like b or b = c and d >= e or e <> d'
--- ast
Select [Column (Symbol "id")] From [Model (Symbol "Post")] Where (OrExpr [AndExpr [RelExpr (">",Column (Symbol "a"),Column (Symbol "b")),RelExpr ("like",Column (Symbol "a"),Column (Symbol "b"))],AndExpr [RelExpr ("=",Column (Symbol "b"),Column (Symbol "c")),RelExpr (">=",Column (Symbol "d"),Column (Symbol "e"))],AndExpr [RelExpr ("<>",Column (Symbol "e"),Column (Symbol "d"))]])
--- out
select "id" from "Post" where ((("a" > "b") and ("a" like "b")) or (("b" = "c") and ("d" >= "e")) or (("e" <> "d")))

