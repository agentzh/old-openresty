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
    my @ln = map { s/\s+$//g; $_ } split /\n+/, $stdout;
    is "$ln[0]\n", $block->ast, "AST ok - $desc";
    is "$ln[1]\n", $block->out, "Pg/SQL output ok - $desc";
};

__DATA__

=== TEST 1: basic
--- in
select foo, bar from Bah
--- ast
Select [Column "foo",Column "bar"] From [Model "Bah"] NullClause
--- out
select "foo", "bar" from "Bah"



=== TEST 2: select only
--- in
select foo
--- ast
Select [Column "foo"] NullClause NullClause
--- out
select "foo"


=== TEST 3: spaces around separator (,)
--- in
select id,name , age from  Post , Comment
--- ast
Select [Column "id",Column "name",Column "age"] From [Model "Post",Model "Comment"] NullClause
--- out
select "id", "name", "age" from "Post", "Comment"
--- LAST



=== TEST 4: simple where clause
--- in
select id,name , age from  Post , Comment where a or b
--- ast
--- out



=== TEST 5: and in or
--- in
select id,name , age from  Post , Comment where a and c or b and d or e'
--- ast
--- out

