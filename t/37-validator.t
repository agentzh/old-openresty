use strict;
use warnings;

use Test::Base;

plan tests => 1 * blocks();

require OpenResty::QuasiQuote::Validator;

my $val = bless {}, 'OpenResty::QuasiQuote::Validator';

run {
    my $block = shift;
    my $name = $block->name;
    my $perl = $val->validator($block->spec);
    is $perl, $block->perl, "$name - perl code match";
};

__DATA__

=== TEST 1: simple hash
---  spec
{ foo: STRING }
--- perl
ref $_ && ref $_ eq 'HASH' or die "Invalid value",
    ($_topic ? " for \"$_topic\"" : ""), ": Hash expected.\n";
{
local $_ = "foo";
my $_topic = "foo";
_STRING($_) or die "Bad value",
    ($_topic ? " for \"$_topic\"" : ""), ": String expected.\n";
}



=== TEST 2: simple hash
---  spec
{ "foo": STRING }
--- perl
ref $_ && ref $_ eq 'HASH' or die "Invalid value",
    ($_topic ? " for \"$_topic\"" : ""), ": Hash expected.\n";
{
local $_ = "foo";
my $_topic = "foo";
_STRING($_) or die "Bad value",
    ($_topic ? " for \"$_topic\"" : ""), ": String expected.\n";
}

