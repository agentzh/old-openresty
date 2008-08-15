package OpenResty::QuasiQuote::Validator;

use strict;
use warnings;

#use Smart::Comments;
require Filter::QuasiQuote;
our @ISA = qw( Filter::QuasiQuote );

use Parse::RecDescent;

my $grammar = <<'_END_GRAMMAR_';

validator: value <commit> eofile { return $item[1] }
         | <error>

value: hash
     | array
     | scalar
     | <error>

hash: '{' <commit> pair(s? /,/) '}' attr(s?)
    {
        my $attrs = { map { @$_ } @{ $item[5] } };
        my $pairs = $item[3];
        my $topic = $arg{topic};
        ### $attrs
        my $for_topic = $topic ? " for $topic" : "";
        my ($code, $code2);
        my $required;
        if (delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\n};
_EOC_
            $required = 1;
        }
        my $code3 = '';
        if (delete $attrs->{nonempty}) {
            $code3 .= <<"_EOC_";
\%\$_ or die qq{Hash cannot be empty$for_topic.\\n};
_EOC_
        }

        $code2 .= <<"_EOC_" . $code3 . join('', map { $_->[1] } @$pairs);
ref and ref eq 'HASH' or die qq{Invalid value$for_topic: Hash expected.\\n};
_EOC_
        my @keys = map { $_->[0] } @$pairs;
        my $cond = join ' or ', map { '$_ eq "' . quotemeta($_) . '"' } @keys;
        $code2 .= <<"_EOC_";
for (keys \%\$_) {
$cond or die qq{Unrecognized key in hash$for_topic: \$_\\n};
}
_EOC_
        if ($required) {
            $code .= $code2
        } else {
            $code .= "if (defined) {\n$code2}\n";
        }

        if (my $var = delete $attrs->{to}) {
            $code .= "$var = \$_;\n";
        }

        if (%$attrs) {
            die "Bad attribute for hash: ", join(" ", keys %$attrs), "\n";
        }

        $code;
    }

pair: key <commit> ':' value[ topic => qq{"$item[1]"} ]
        {
            my $quoted_key = quotemeta($item[1]);
            [$item[1], <<"_EOC_" . $item[4] . "}\n"]
{
local \$_ = \$_->{"$quoted_key"};
_EOC_
        }
    | <error?> <reject>

key: { extract_delimited($text, '"') } { eval $item[1] }
   | ident

ident: /^[A-Za-z]\w*/

scalar: type <commit> attr(s?)
    {
        my $attrs = { map { @$_ } @{ $item[3] } };
        my $topic = $arg{topic};
        my $for_topic = $topic ? " for $topic" : "";
        my $code;
        my $code2 = $item[1];
        my $required;
        if (delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\n};
_EOC_
            $required = 1;
        }

        if ($required) {
            $code .= $code2;
        } else {
            $code .= "if (defined) {\n$code2}\n";
        }
        if (my $default = delete $attrs->{default}) {
            if ($required) {
                die "validator: Required scalar cannot take default value at the same time.\n";
            }
            $code .= <<"_EOC_";
else {
\$_ = $default;
}
_EOC_
        }
        if (my $var = delete $attrs->{to}) {
            $code .= "$var = \$_;\n";
        }

        if (%$attrs) {
            die "validator: Bad attribute for scalar: ", join(" ", keys %$attrs), "\n";
        }


        #$code . $code2;
        $code;
    }

array: '[' <commit> array_elem ']' attr(s?)
    {
        my $attrs = { map { @$_ } @{ $item[5] } };
        my $topic = $arg{topic};
        my $for_topic = $topic ? " for $topic" : "";
        my $required;
        my ($code, $code2);
        if ($required = delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\n};
_EOC_
            #$required = 1;
        }
        my $code3 = '';
        if (delete $attrs->{nonempty}) {
            $code3 .= <<"_EOC_";
\@\$_ or die qq{Array cannot be empty$for_topic.\\n};
_EOC_
        }

        $code2 .= <<"_EOC_";
ref and ref eq 'ARRAY' or die qq{Invalid value$for_topic: Array expected.\\n};
${code3}for (\@\$_) \{
$item[3]}
_EOC_

        if ($required) {
            $code .= $code2;
        } else {
            $code .= "if (defined) {\n$code2}\n";
        }

        if (my $default = delete $attrs->{default}) {
            if ($required) {
                die "validator: Required array cannot take default value at the same time.\n";
            }
            $code .= <<"_EOC_";
else {
\$_ = $default;
}
_EOC_
        }

        if (my $var = delete $attrs->{to}) {
            $code .= "$var = \$_;\n";
        }

        if (%$attrs) {
            die "Bad attribute for array: ", join(" ", keys %$attrs), "\n";
        }

        $code;
    }
    | <error?> <reject>

array_elem: {
                if ($arg{topic}) {
                    $arg{topic} . " "
                } else {
                    ""
                }
            } value[topic => $item[1] . 'array element']

type: 'STRING'
        {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
!ref and length or die qq{Bad value$for_topic: String expected.\\n};
_EOC_
        }
    | 'INT'
        {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
/^[-+]?\\d+\$/ or die qq{Bad value$for_topic: Integer expected.\\n};
_EOC_
        }
    | 'IDENT'
        {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
/^[A-Za-z]\\w*\$/ or die qq{Bad value$for_topic: Identifier expected.\\n};
_EOC_
        }
    | <error>

attr: ':' ident '(' <commit> argument ')'
        { [ $item[2] => $item[5] ] }
    | ':' <commit> ident
        { [ $item[3] => 1 ] }
    | <error?> <reject>

argument: /^\d+/
        | '[]'
        | /\$[A-Za-z]\w*/
        | { extract_quotelike($text) } { $item[1] }
        | { extract_codeblock($text) } { "do $item[1]" }
        | <error>

eofile: /^\Z/

_END_GRAMMAR_

$::RD_HINT = 1;
#$::RD_TRACE = 1;
our $Parser = new Parse::RecDescent ($grammar);

sub validator {
    my ($self, $s, $fname, $ln, $col) = @_;
    return $Parser->validator($s);
}

1;

