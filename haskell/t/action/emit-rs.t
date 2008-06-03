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
    run3 [qw< bin/restyaction ast rs >], \$stdin, \$stdout, \$stderr;
    is $? >> 8, 0, "compiler returns 0 - $desc";
    warn $stderr if $stderr;
    my @ln = split /\n+/, $stdout;
    my $ast = $block->ast;
    if (defined $ast) {
        $ln[0] =~ s/"RestyAction" \(line (\d+), column (\d+)\)/($1,$2)/gs;
        is "$ln[0]\n", $ast, "AST ok - $desc";
    }
    $ln[1] =~ s/\s+$//smg;
    my $out = $block->out;
    is "$ln[1]\n", $out, "Pg/SQL output ok - $desc";
};

__DATA__

=== TEST 1: basic delete
--- in
delete from Foo where id > 3;
--- ast
Action [Delete (Model (Symbol "Foo")) (Where (Compare ">" (Column (Symbol "id")) (Integer 3)))]
--- out
delete from "Foo" where "id" > 3



=== TEST 2: basic update
--- in
update Foo set foo=foo+1
--- ast
Action [Update (Model (Symbol "Foo")) (Assign (Column (Symbol "foo")) (Arith "+" (Column (Symbol "foo")) (Integer 1))) Null]
--- out
update "Foo" set "foo" = ("foo" + 1)

