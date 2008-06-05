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
    run3 [qw< bin/restyaction frags >], \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my @ln = split /\n+/, $stdout;
    my $out = $block->out;
    is "$ln[0]\n", $out, "Pg/SQL output ok - $desc";
};

__DATA__

=== TEST 1: basic delete
--- in
delete from $foo where $foo > $id;
--- out
[[["delete from ",["foo","symbol"]," where ",["foo","unknown"]," > ",["id","unknown"]]]]



=== TEST 2: basic delete
--- in
delete from Foo where col > $id;
--- out
[[["delete from \"Foo\" where \"col\" > ",["id","unknown"]]]]



=== TEST 3: basic update
--- in
update $blah set $foo=$blah+1
--- out
[[["update ",["blah","symbol"]," set ",["foo","symbol"]," = (",["blah","unknown"]," + 1) "]]]



=== TEST 4: basic update
--- in
update Foo set col=col+1
--- out
[[["update \"Foo\" set \"col\" = (\"col\" + 1) "]]]



=== TEST 5: update with delete
--- in
update
    Foo set foo = $foo where $foo>$bar and $foo like '%hey' ;
    ;
delete from $foo where $foo=5
 ;
--- out
[[["update \"Foo\" set \"foo\" = ",["foo","unknown"]," where (",["foo","unknown"]," > ",["bar","unknown"]," and ",["foo","unknown"]," like '%hey')"]],[["delete from ",["foo","symbol"]," where ",["foo","unknown"]," = 5"]]]



=== TEST 6: simple GET
--- in
GET $bah;
--- out
[["GET",[["bah","quoted"]]]]



=== TEST 7: GET with expr
--- in
GET ( '/=/'||$foo) || $foo
--- out
[["GET",["/=/",["foo","quoted"],["foo","quoted"]]]]



=== TEST 8: GET with expr
--- in
GET ( '/=/'|| 'ver') || 'sion'
--- out
[["GET",["/=/version"]]]



=== TEST 9: simple POST
--- in
POST '/=/model/Post/~/~' || $foo
{ $foo: "hello" || $foo }
--- out
[["POST",["/=/model/Post/~/~",["foo","quoted"]],["{\"",["foo","quoted"],"\": \"hello",["foo","quoted"],"\"}"]]]



=== TEST 10: POST a simple array
--- in
POST
'/=/model/Post/' || '~/~'
[1,$foo,2.5,"hi"||$foo]
--- out
[["POST",["/=/model/Post/~/~"],["[1, ",["foo","literal"],", 2.5, \"hi",["foo","quoted"],"\"]"]]]



=== TEST 11: PUT a literal
--- in
PUT '/=/foo' $foo
--- out
[["PUT",["/=/foo"],[["foo","literal"]]]]
--- LAST



=== TEST 12: PUT a hash of lists of hashes
--- in
POST '/=/model/~'
{ "description": $type,
    "columns": [
        { "name": "name", $type: 'text'},
        { "name":"created",$type:"timestamp (0) with time zone", default: [$type] }
    ]
}
--- out
POST '/=/model/~'
{ "description": $abc,
    "columns": [
        { "name": "name", $abc: 'text'},
        { "name":"created",$abc:"timestamp (0) with time zone", default: [$abc] }
    ]
}



=== TEST 13: with variables and some noises
--- in
            update Post
            set comments = comments + 1
            where id = $post_id;
            POST '/=/model/Comment/~/~'
            { "sender": $sender, "body": $body, "$post_id": $post_id };
--- out
            update Post
            set comments = comments + 1
            where id = $post;
            POST '/=/model/Comment/~/~'
            { "sender": $sender, "body": $body, "$post_id": $post };



=== TEST 14: try delete
--- in
DELETE '/=/model' || $foo;
DELETE '/=/view';
DELETE $foo
--- out
DELETE '/=/model' || $abc;
DELETE '/=/view';
DELETE $abc

