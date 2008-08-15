use strict;
use warnings;

use Test::Base;
use JSON::XS;

plan tests => 2* blocks() + 76;

require OpenResty::QuasiQuote::Validator;

my $json_xs = JSON::XS->new->utf8->allow_nonref;

my $val = bless {}, 'OpenResty::QuasiQuote::Validator';

#no_diff;

sub validate { 1; }

run {
    my $block = shift;
    my $name = $block->name;
    my $perl;
    eval {
        $perl = $val->validator($block->spec);
    };
    if ($@) {
        die "$name - $@";
    }
    my $expected = $block->perl;
    $expected =~ s/^\s+//gm;
    is $perl, $expected, "$name - perl code match";
    my $code = "*validate = sub { local \$_ = shift; $perl }";
    no warnings 'redefine';
    eval $code;
    if ($@) {
        fail "$name - Bad perl code emitted - $@";
        *validate = sub { 1 };
    } else {
        pass "$name - perl code emitted is well formed";
    }
    my $spec = $block->valid;
    if ($spec) {
        my @ln = split /\n/, $spec;
        for my $ln (@ln) {
            my $data = $json_xs->decode($ln);
            eval {
                validate($data);
            };
            if ($@) {
                fail "$name - Valid data <<$ln>> is valid - $@";
            } else {
                pass "$name - Valid data <<$ln>> is valid";
            }
        }
    }
    $spec = $block->invalid;
    if ($spec) {
        my @ln = split /\n/, $spec;
        while (@ln) {
            my $ln = shift @ln;
            my $excep = shift @ln;
            my $data = $json_xs->decode($ln);
            eval {
                validate($data);
            };
            unless ($@) {
                fail "$name - Invalid data <<$ln>> is invalid - $@";
            } else {
                is $@, "$excep\n", "$name - Invalid data <<$ln>> is invalid";
            }
        }
    }

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

--- valid
{"foo":"dog"}
{"foo":32}
null
{}

--- invalid
{"foo2":32}
Unrecognized keys in hash: foo2
32
Invalid value: Hash expected.
[]
Invalid value: Hash expected.



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
--- valid
"hello"
32
3.14
null
0
--- invalid
{"cat":32}
Bad value: String expected.
[1,2,3]
Bad value: String expected.



=== TEST 4: numbers
---  spec
INT
--- perl
if (defined) {
    /^[-+]?\d+$/ or die qq{Bad value: Integer expected.\n};
}
--- valid
32
0
null
-56
--- invalid
3.14
Bad value: Integer expected.
"hello"
Bad value: Integer expected.
[0]
Bad value: Integer expected.
{}
Bad value: Integer expected.



=== TEST 5: identifiers
---  spec
IDENT
--- perl
if (defined) {
    /^[A-Za-z]\w*$/ or die qq{Bad value: Identifier expected.\n};
}
--- valid
"foo"
"hello_world"
"HiBoy"
--- invalid
"_foo"
Bad value: Identifier expected.
"0a"
Bad value: Identifier expected.
32
Bad value: Identifier expected.
[]
Bad value: Identifier expected.
{"cat":3}
Bad value: Identifier expected.



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
--- valid
[1,2]
["hello"]
null
[]

--- invalid
[[1]]
Bad value for array element: String expected.
32
Invalid value: Array expected.
"hello"
Invalid value: Array expected.
{}
Invalid value: Array expected.



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
--- valid
{"columns":[]}
{"columns":[{"name":"Carrie"}]}
{}
null
--- invalid
{"bar":[]}
Unrecognized keys in hash: bar
{"columns":[{"default":32,"blah":[]}]}
Unrecognized keys in hash for "columns" array element: blah default
{"columns":[32]}
Invalid value for "columns" array element: Hash expected.
32
Invalid value: Hash expected.



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
--- valid
{"foo":"hello"}
{}
{"foo":null}

--- invalid
null
Value required.
{"blah":"hi"}
Unrecognized keys in hash: blah
[]
Invalid value: Hash expected.
32
Invalid value: Hash expected.



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
--- valid
[1,2]
[0]
--- invalid
["hello"]
Bad value for array element: Integer expected.
[1,2,"hello"]
Bad value for array element: Integer expected.
[1.32]
Bad value for array element: Integer expected.
null
Value required.



=== TEST 10: array elem required
--- spec
[INT :required]
--- perl
if (defined) {
    ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
    for (@$_) {
        defined or die qq{Value for array element required.\n};
        /^[-+]?\d+$/ or die qq{Bad value for array element: Integer expected.\n};
    }
}

--- valid
[32]
null
[]
--- invalid
[null]
Value for array element required.



=== TEST 11: nonempty array
--- spec
[INT] :nonempty
--- perl
if (defined) {
    ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
    @$_ or die qq{Array cannot be empty.\n};
    for (@$_) {
        if (defined) {
            /^[-+]?\d+$/ or die qq{Bad value for array element: Integer expected.\n};
        }
    }
}
--- valid
[32]
[1,2]
null
--- invalid
[]
Array cannot be empty.


=== TEST 11: nonempty required array
--- spec
[INT] :nonempty :required
--- perl
defined or die qq{Value required.\n};
ref and ref eq 'ARRAY' or die qq{Invalid value: Array expected.\n};
@$_ or die qq{Array cannot be empty.\n};
for (@$_) {
    if (defined) {
        /^[-+]?\d+$/ or die qq{Bad value for array element: Integer expected.\n};
    }
}
--- valid
[32]
[1,2]
--- invalid
[]
Array cannot be empty.
null
Value required.
["hello"]
Bad value for array element: Integer expected.



=== TEST 12: nonempty hash
--- spec
{"cat":STRING}:nonempty
--- perl
if (defined) {
    ref and ref eq 'HASH' or die qq{Invalid value: Hash expected.\n};
    %$_ or die qq{Hash cannot be empty.\n};
    {
        local $_ = delete $_->{"cat"};
        if (defined) {
            !ref and length or die qq{Bad value for "cat": String expected.\n};
        }
    }
    die qq{Unrecognized keys in hash: }, join(' ', keys %$_), "\n" if %$_;
}

--- valid
{"cat":32}
null
--- invalid
32
Invalid value: Hash expected.
{}
Hash cannot be empty.


=== TEST 12: scalar required
--- spec
IDENT :required
--- perl
defined or die qq{Value required.\n};
/^[A-Za-z]\w*$/ or die qq{Bad value: Identifier expected.\n};



=== TEST 13: scalar required
--- spec
STRING :required
--- perl
defined or die qq{Value required.\n};
!ref and length or die qq{Bad value: String expected.\n};



=== TEST 14: scalar required in a hash
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



=== TEST 15: scalar required in a hash which is required also
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

