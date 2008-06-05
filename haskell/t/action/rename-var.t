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
    run3 [qw< bin/restyscript action rename >, $old, $new],
        \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    $stdout =~ s/\n+$/\n/s;
    my $out = $block->out;
    is $stdout, $out, "Renamed output ok - $desc";
};

__DATA__

=== TEST 1: basic delete
--- in
delete from $foo where $foo > $id;
--- rename: foo bar
--- out
delete from $bar where $bar > $id;



=== TEST 2: basic update
--- in
update $blah set $foo=$blah+1
--- rename: blah abc
--- out
update $abc set $foo=$abc+1



=== TEST 3: update with delete
--- in
update
    Foo set foo = $foo where $foo>$bar and $foo like '%hey' ;
    ;
delete from $foo where $foo=5
 ;
--- rename: foo abc
--- out
update
    Foo set foo = $abc where $abc>$bar and $abc like '%hey' ;
    ;
delete from $abc where $abc=5
 ;



=== TEST 4: simple GET
--- in
GET $bah;
--- out
--- rename: bah foo
--- out
GET $foo;



=== TEST 5: GET with expr
--- in
GET ( '/=/'||$foo) || $foo
--- rename: foo bar
--- out
GET ( '/=/'||$bar) || $bar



=== TEST 6: simple POST
--- in
POST '/=/model/Post/~/~' || $foo
{ $foo: "hello" || $foo }
--- rename: foo bar
--- out
POST '/=/model/Post/~/~' || $bar
{ $bar: "hello" || $bar }



=== TEST 7: POST a simple array
--- in
POST
'/=/model/Post/' || '~/~'
[1,$foo,2.5,"hi"||$foo]
--- rename: foo abc
--- out
POST
'/=/model/Post/' || '~/~'
[1,$abc,2.5,"hi"||$abc]



=== TEST 8: PUT a literal
--- in
PUT '/=/foo' $foo
--- rename: foo bar
--- out
PUT '/=/foo' $bar



=== TEST 9: PUT a hash of lists of hashes
--- in
POST '/=/model/~'
{ "description": $type,
    "columns": [
        { "name": "name", $type: 'text'},
        { "name":"created",$type:"timestamp (0) with time zone", default: [$type] }
    ]
}
--- rename: type abc
--- out
POST '/=/model/~'
{ "description": $abc,
    "columns": [
        { "name": "name", $abc: 'text'},
        { "name":"created",$abc:"timestamp (0) with time zone", default: [$abc] }
    ]
}



=== TEST 10: with variables and some noises
--- in
            update Post
            set comments = comments + 1
            where id = $post_id;
            POST '/=/model/Comment/~/~'
            { "sender": $sender, "body": $body, "$post_id": $post_id };
--- rename: post_id post
--- out
            update Post
            set comments = comments + 1
            where id = $post;
            POST '/=/model/Comment/~/~'
            { "sender": $sender, "body": $body, "$post_id": $post };



=== TEST 11: try delete
--- in
DELETE '/=/model' || $foo;
DELETE '/=/view';
DELETE $foo
--- rename: foo abc
--- out
DELETE '/=/model' || $abc;
DELETE '/=/view';
DELETE $abc

