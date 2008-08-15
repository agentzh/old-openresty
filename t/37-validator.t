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
if (defined) {
    ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
    {
        local $_ = delete $_->{"foo"};
        if (defined) {
            !ref and length or die qq{Bad value for "foo": String expected.\n};
        }
    }
    die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;
}



=== TEST 2: simple hash
---  spec
{ "foo": STRING }
--- perl
if (defined) {
    ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
    {
        local $_ = delete $_->{"foo"};
        if (defined) {
            !ref and length or die qq{Bad value for "foo": String expected.\n};
        }
    }
    die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;
}



=== TEST 3: strings
---  spec
STRING
--- perl
if (defined) {
    !ref and length or die qq{Bad value: String expected.\n};
}



=== TEST 4: numbers
---  spec
INT
--- perl
if (defined) {
    /^[-+]?\d+$/ or die qq{Bad value: Integer expected.\n};
}



=== TEST 5: identifiers
---  spec
IDENT
--- perl
if (defined) {
    /^\w+$/ or die qq{Bad value: Identifier expected.\n};
}



=== TEST 6: arrays
--- spec
[STRING]
--- perl
if (defined) {
    ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
    for (@$_) {
        if (defined) {
            !ref and length or die qq{Bad value for array element: String expected.\n};
        }
    }
}



=== TEST 7: hashes of arrays
--- spec
{ columns: [ { name: STRING, type: STRING } ] }
--- perl
if (defined) {
    ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
    {
        local $_ = delete $_->{"columns"};
        if (defined) {
            ref and ref eq 'ARRAY' or die qq{Invalid value for "columns": Array expected.\n};
            for (@$_) {
                if (defined) {
                    ref and ref eq 'HASH' or die qq{Invalid value for "columns" array element: Hash expected.\n};
                    {
                        local $_ = delete $_->{"name"};
                        if (defined) {
                            !ref and length or die qq{Bad value for "name": String expected.\n};
                        }
                    }
                    {
                        local $_ = delete $_->{"type"};
                        if (defined) {
                            !ref and length or die qq{Bad value for "type": String expected.\n};
                        }
                    }
                    die qq{Unrecognized keys in hash for "columns" array element: }, join(' ', keys %$_), "\n" if %$_;
                }
            }
        }
    }
    die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;
}



=== TEST 8: simple hash required
---  spec
{ "foo": STRING } :required
--- perl
defined or die qq{Value required.\n};
ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
{
    local $_ = delete $_->{"foo"};
    if (defined) {
        !ref and length or die qq{Bad value for "foo": String expected.\n};
    }
}
die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;



=== TEST 9: array required
--- spec
[INT] :required(1)
--- perl
defined or die qq{Value required.\n};
ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
for (@$_) {
    if (defined) {
        /^[-+]?\d+$/ or die qq{Bad value for array element: Integer expected.\n};
    }
}



=== TEST 10: scalar required
--- spec
IDENT :required
--- perl
defined or die qq{Value required.\n};
/^\w+$/ or die qq{Bad value: Identifier expected.\n};



=== TEST 11: scalar required
--- spec
STRING :required
--- perl
defined or die qq{Value required.\n};
!ref and length or die qq{Bad value: String expected.\n};



=== TEST 12: scalar required in a hash
--- spec
{ name: STRING :required, type: STRING :required }
--- perl
if (defined) {
    ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
    {
        local $_ = delete $_->{"name"};
        defined or die qq{Value for "name" required.\n};
        !ref and length or die qq{Bad value for "name": String expected.\n};
    }
    {
        local $_ = delete $_->{"type"};
        defined or die qq{Value for "type" required.\n};
        !ref and length or die qq{Bad value for "type": String expected.\n};
    }
    die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;
}



=== TEST 13: scalar required in a hash required also
--- spec
{ name: STRING :required, type: STRING :required } :required
--- perl
defined or die qq{Value required.\n};
ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
{
    local $_ = delete $_->{"name"};
    defined or die qq{Value for "name" required.\n};
    !ref and length or die qq{Bad value for "name": String expected.\n};
}
{
    local $_ = delete $_->{"type"};
    defined or die qq{Value for "type" required.\n};
    !ref and length or die qq{Bad value for "type": String expected.\n};
}
die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;

