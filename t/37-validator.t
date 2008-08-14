use strict;
use warnings;

use Test::Base;

plan tests => 1 * blocks();

require OpenResty::QuasiQuote::Validator;

my $val = bless {}, 'OpenResty::QuasiQuote::Validator';

#no_diff;

run {
    my $block = shift;
    my $name = $block->name;
    my $perl = $val->validator($block->spec);
    my $expected = $block->perl;
    $expected =~ s/^\s+//gm;
    is $perl, $expected, "$name - perl code match";
};

__DATA__

=== TEST 1: simple hash
---  spec
{ foo: STRING }
--- perl
defined and ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
if (defined) {
    {
        local $_ = $_->{"foo"};
        defined and !ref and length or die qq{Bad value for "foo": String expected.\n};
    }
}



=== TEST 2: simple hash
---  spec
{ "foo": STRING }
--- perl
defined and ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
if (defined) {
    {
        local $_ = $_->{"foo"};
        defined and !ref and length or die qq{Bad value for "foo": String expected.\n};
    }
}



=== TEST 3: strings
---  spec
STRING
--- perl
defined and !ref and length or die qq{Bad value: String expected.\n};



=== TEST 4: numbers
---  spec
INT
--- perl
defined and /^[-+]?\d+$/ or die qq{Bad value: Integer expected.\n};



=== TEST 5: identifiers
---  spec
IDENT
--- perl
defined and /^\w+$/ or die qq{Bad value: Identifier expected.\n};



=== TEST 6: arrays
--- spec
[STRING, STRING]
--- perl
defined and ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
if (defined) {
    for (@$_) {
        defined and !ref and length or die qq{Bad value for array element: String expected.\n};
    }
}



=== TEST 7: hashes of arrays
--- spec
{ columns: [ { name: STRING, type: STRING } ] }
--- perl
defined and ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
if (defined) {
    {
        local $_ = $_->{"columns"};
        defined and ref and ref eq 'ARRAY' or die qq{Invalid value for "columns": Array expected.\n};
        if (defined) {
            for (@$_) {
                defined and ref and ref eq 'HASH' or die qq{Invalid value for "columns" array element: Hash expected.\n};
                if (defined) {
                    {
                        local $_ = $_->{"name"};
                        defined and !ref and length or die qq{Bad value for "name": String expected.\n};
                    }
                    {
                        local $_ = $_->{"type"};
                        defined and !ref and length or die qq{Bad value for "type": String expected.\n};
                    }
                }
            }
        }
    }
}



=== TEST 8: simple hash required
---  spec
{ "foo": STRING } :required
--- perl
defined or die qq{Value required.\n};
defined and ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
{
    local $_ = $_->{"foo"};
    defined and !ref and length or die qq{Bad value for "foo": String expected.\n};
}



=== TEST 9: array required
--- spec
[INT] :required(1)
--- perl
defined or die qq{Value required.\n};
defined and ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
for (@$_) {
    defined and /^[-+]?\d+$/ or die qq{Bad value for array element: Integer expected.\n};
}



=== TEST 10: scalar required
--- spec
IDENT :required
--- perl
defined or die qq{Value required.\n};
defined and /^\w+$/ or die qq{Bad value: Identifier expected.\n};



=== TEST 11: scalar required
--- spec
STRING :required
--- perl
defined or die qq{Value required.\n};
defined and !ref and length or die qq{Bad value: String expected.\n};

