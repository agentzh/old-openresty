use strict;
use warnings;

use Test::Base;

plan tests => 1 * blocks();

require OpenResty::QuasiQuote::Validator;

my $val = bless {}, 'OpenResty::QuasiQuote::Validator';

no_diff;

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
ref $_ && ref $_ eq 'HASH' or die "Invalid value: Hash expected.\n";
{
local $_ = "foo";
defined $_ and !ref $_ and length($_) or die "Bad value for foo: String expected.\n";
}



=== TEST 2: simple hash
---  spec
{ "foo": STRING }
--- perl
ref $_ && ref $_ eq 'HASH' or die "Invalid value: Hash expected.\n";
{
local $_ = "\"foo\"";
defined $_ and !ref $_ and length($_) or die "Bad value for "foo": String expected.\n";
}



=== TEST 3: strings
---  spec
STRING
--- perl
defined $_ and !ref $_ and length($_) or die "Bad value: String expected.\n";



=== TEST 4: numbers
---  spec
INT
--- perl
defined $_ and /^[-+]?\d+$/ or die "Bad value: Integer expected.\n";



=== TEST 5: identifiers
---  spec
IDENT
--- perl
defined $_ and /^\w+$/ or die "Bad value: Identifier expected.\n";

