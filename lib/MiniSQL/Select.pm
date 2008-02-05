####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package MiniSQL::Select;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 5 "grammar/Select.yp"


my (
    @Models, @Columns, @OutVars,
    $InVals, %Defaults, $Quote, $QuoteIdent,
    @Unbound,
);



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			"select" => 3
		},
		GOTOS => {
			'select_stmt' => 1,
			'statement' => 2,
			'miniSQL' => 4
		}
	},
	{#State 1
		ACTIONS => {
			";" => 5
		},
		DEFAULT => -3
	},
	{#State 2
		DEFAULT => -1
	},
	{#State 3
		ACTIONS => {
			"sum" => 11,
			"max" => 7,
			"*" => 13,
			'VAR' => 14,
			"count" => 15,
			'IDENT' => 8,
			"min" => 19
		},
		GOTOS => {
			'symbol' => 6,
			'proc_call' => 9,
			'qualified_symbol' => 10,
			'pattern' => 12,
			'pattern_list' => 16,
			'aggregate' => 17,
			'func' => 18,
			'column' => 20
		}
	},
	{#State 4
		ACTIONS => {
			'' => 21
		}
	},
	{#State 5
		DEFAULT => -2
	},
	{#State 6
		ACTIONS => {
			"." => 22
		},
		DEFAULT => -32
	},
	{#State 7
		DEFAULT => -18
	},
	{#State 8
		ACTIONS => {
			"(" => 23
		},
		DEFAULT => -34
	},
	{#State 9
		DEFAULT => -13
	},
	{#State 10
		DEFAULT => -31
	},
	{#State 11
		DEFAULT => -21
	},
	{#State 12
		ACTIONS => {
			"," => 24
		},
		DEFAULT => -10
	},
	{#State 13
		DEFAULT => -15
	},
	{#State 14
		ACTIONS => {
			"|" => 25
		},
		DEFAULT => -36
	},
	{#State 15
		DEFAULT => -20
	},
	{#State 16
		ACTIONS => {
			"where" => 26,
			"order by" => 31,
			"limit" => 30,
			"group by" => 34,
			"from" => 35,
			"offset" => 37
		},
		DEFAULT => -5,
		GOTOS => {
			'postfix_clause_list' => 29,
			'order_by_clause' => 28,
			'offset_clause' => 27,
			'from_clause' => 36,
			'where_clause' => 32,
			'group_by_clause' => 33,
			'limit_clause' => 38,
			'postfix_clause' => 39
		}
	},
	{#State 17
		ACTIONS => {
			'IDENT' => 41,
			'VAR' => 14
		},
		DEFAULT => -12,
		GOTOS => {
			'symbol' => 40,
			'alias' => 42
		}
	},
	{#State 18
		ACTIONS => {
			"(" => 43
		}
	},
	{#State 19
		DEFAULT => -19
	},
	{#State 20
		DEFAULT => -14
	},
	{#State 21
		DEFAULT => 0
	},
	{#State 22
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 44
		}
	},
	{#State 23
		ACTIONS => {
			'NUM' => 49,
			'VAR' => 52,
			'STRING' => 48
		},
		GOTOS => {
			'parameter' => 51,
			'literal' => 50,
			'number' => 46,
			'variable' => 45,
			'string' => 47,
			'parameter_list' => 53
		}
	},
	{#State 24
		ACTIONS => {
			"sum" => 11,
			"max" => 7,
			"*" => 13,
			'VAR' => 14,
			"count" => 15,
			'IDENT' => 8,
			"min" => 19
		},
		GOTOS => {
			'symbol' => 6,
			'proc_call' => 9,
			'qualified_symbol' => 10,
			'pattern' => 12,
			'func' => 18,
			'aggregate' => 17,
			'pattern_list' => 54,
			'column' => 20
		}
	},
	{#State 25
		ACTIONS => {
			'IDENT' => 55
		}
	},
	{#State 26
		ACTIONS => {
			"(" => 59,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 56,
			'symbol' => 6,
			'conjunction' => 57,
			'disjunction' => 58,
			'condition' => 61,
			'column' => 60,
			'qualified_symbol' => 10
		}
	},
	{#State 27
		DEFAULT => -44
	},
	{#State 28
		DEFAULT => -42
	},
	{#State 29
		DEFAULT => -4
	},
	{#State 30
		ACTIONS => {
			'NUM' => 49,
			'VAR' => 52,
			'STRING' => 48
		},
		GOTOS => {
			'literal' => 62,
			'number' => 46,
			'variable' => 45,
			'string' => 47
		}
	},
	{#State 31
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'order_by_objects' => 64,
			'column' => 65,
			'qualified_symbol' => 10,
			'order_by_object' => 63
		}
	},
	{#State 32
		DEFAULT => -40
	},
	{#State 33
		DEFAULT => -41
	},
	{#State 34
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 66,
			'column' => 67,
			'qualified_symbol' => 10
		}
	},
	{#State 35
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 8
		},
		GOTOS => {
			'models' => 68,
			'symbol' => 69,
			'model' => 70,
			'proc_call' => 71
		}
	},
	{#State 36
		DEFAULT => -45
	},
	{#State 37
		ACTIONS => {
			'NUM' => 49,
			'VAR' => 52,
			'STRING' => 48
		},
		GOTOS => {
			'literal' => 72,
			'number' => 46,
			'variable' => 45,
			'string' => 47
		}
	},
	{#State 38
		DEFAULT => -43
	},
	{#State 39
		ACTIONS => {
			"where" => 26,
			"order by" => 31,
			"limit" => 30,
			"group by" => 34,
			"from" => 35,
			"offset" => 37
		},
		DEFAULT => -39,
		GOTOS => {
			'postfix_clause_list' => 73,
			'order_by_clause' => 28,
			'offset_clause' => 27,
			'from_clause' => 36,
			'where_clause' => 32,
			'group_by_clause' => 33,
			'limit_clause' => 38,
			'postfix_clause' => 39
		}
	},
	{#State 40
		DEFAULT => -37
	},
	{#State 41
		DEFAULT => -34
	},
	{#State 42
		DEFAULT => -11
	},
	{#State 43
		ACTIONS => {
			"*" => 74,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column' => 75,
			'qualified_symbol' => 10
		}
	},
	{#State 44
		DEFAULT => -33
	},
	{#State 45
		DEFAULT => -66
	},
	{#State 46
		DEFAULT => -65
	},
	{#State 47
		DEFAULT => -64
	},
	{#State 48
		DEFAULT => -29
	},
	{#State 49
		DEFAULT => -27
	},
	{#State 50
		DEFAULT => -25
	},
	{#State 51
		ACTIONS => {
			"," => 76
		},
		DEFAULT => -24
	},
	{#State 52
		ACTIONS => {
			"|" => 77
		},
		DEFAULT => -26
	},
	{#State 53
		ACTIONS => {
			")" => 78
		}
	},
	{#State 54
		DEFAULT => -9
	},
	{#State 55
		DEFAULT => -35
	},
	{#State 56
		ACTIONS => {
			"and" => 79
		},
		DEFAULT => -53
	},
	{#State 57
		ACTIONS => {
			"or" => 80
		},
		DEFAULT => -51
	},
	{#State 58
		DEFAULT => -49
	},
	{#State 59
		ACTIONS => {
			"(" => 59,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 56,
			'symbol' => 6,
			'conjunction' => 57,
			'disjunction' => 58,
			'condition' => 81,
			'column' => 60,
			'qualified_symbol' => 10
		}
	},
	{#State 60
		ACTIONS => {
			"<" => 82,
			"like" => 83,
			"<=" => 87,
			">" => 89,
			"<>" => 88,
			">=" => 85,
			"=" => 84
		},
		GOTOS => {
			'operator' => 86
		}
	},
	{#State 61
		DEFAULT => -48
	},
	{#State 62
		DEFAULT => -77
	},
	{#State 63
		ACTIONS => {
			"," => 90
		},
		DEFAULT => -72
	},
	{#State 64
		DEFAULT => -70
	},
	{#State 65
		ACTIONS => {
			"desc" => 91,
			"asc" => 92
		},
		DEFAULT => -74,
		GOTOS => {
			'order_by_modifier' => 93
		}
	},
	{#State 66
		DEFAULT => -67
	},
	{#State 67
		ACTIONS => {
			"," => 94
		},
		DEFAULT => -69
	},
	{#State 68
		DEFAULT => -46
	},
	{#State 69
		DEFAULT => -8
	},
	{#State 70
		ACTIONS => {
			"," => 95
		},
		DEFAULT => -7
	},
	{#State 71
		DEFAULT => -47
	},
	{#State 72
		DEFAULT => -78
	},
	{#State 73
		DEFAULT => -38
	},
	{#State 74
		ACTIONS => {
			")" => 96
		}
	},
	{#State 75
		ACTIONS => {
			")" => 97
		}
	},
	{#State 76
		ACTIONS => {
			'NUM' => 49,
			'VAR' => 52,
			'STRING' => 48
		},
		GOTOS => {
			'parameter' => 51,
			'literal' => 50,
			'number' => 46,
			'variable' => 45,
			'string' => 47,
			'parameter_list' => 98
		}
	},
	{#State 77
		ACTIONS => {
			'NUM' => 100,
			'STRING' => 99
		}
	},
	{#State 78
		DEFAULT => -22
	},
	{#State 79
		ACTIONS => {
			"(" => 59,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 101,
			'symbol' => 6,
			'column' => 60,
			'qualified_symbol' => 10
		}
	},
	{#State 80
		ACTIONS => {
			"(" => 59,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 56,
			'conjunction' => 102,
			'symbol' => 6,
			'column' => 60,
			'qualified_symbol' => 10
		}
	},
	{#State 81
		ACTIONS => {
			")" => 103
		}
	},
	{#State 82
		DEFAULT => -60
	},
	{#State 83
		DEFAULT => -63
	},
	{#State 84
		DEFAULT => -62
	},
	{#State 85
		DEFAULT => -58
	},
	{#State 86
		ACTIONS => {
			'NUM' => 49,
			'VAR' => 105,
			'IDENT' => 41,
			'STRING' => 48
		},
		GOTOS => {
			'literal' => 104,
			'symbol' => 6,
			'number' => 46,
			'variable' => 45,
			'string' => 47,
			'column' => 106,
			'qualified_symbol' => 10
		}
	},
	{#State 87
		DEFAULT => -59
	},
	{#State 88
		DEFAULT => -61
	},
	{#State 89
		DEFAULT => -57
	},
	{#State 90
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'order_by_objects' => 107,
			'column' => 65,
			'qualified_symbol' => 10,
			'order_by_object' => 63
		}
	},
	{#State 91
		DEFAULT => -76
	},
	{#State 92
		DEFAULT => -75
	},
	{#State 93
		DEFAULT => -73
	},
	{#State 94
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 108,
			'column' => 67,
			'qualified_symbol' => 10
		}
	},
	{#State 95
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'models' => 109,
			'symbol' => 69,
			'model' => 70
		}
	},
	{#State 96
		DEFAULT => -17
	},
	{#State 97
		DEFAULT => -16
	},
	{#State 98
		DEFAULT => -23
	},
	{#State 99
		DEFAULT => -30
	},
	{#State 100
		DEFAULT => -28
	},
	{#State 101
		DEFAULT => -52
	},
	{#State 102
		DEFAULT => -50
	},
	{#State 103
		DEFAULT => -56
	},
	{#State 104
		DEFAULT => -54
	},
	{#State 105
		ACTIONS => {
			"|" => 110,
			"." => -36
		},
		DEFAULT => -26
	},
	{#State 106
		DEFAULT => -55
	},
	{#State 107
		DEFAULT => -71
	},
	{#State 108
		DEFAULT => -68
	},
	{#State 109
		DEFAULT => -6
	},
	{#State 110
		ACTIONS => {
			'NUM' => 100,
			'IDENT' => 55,
			'STRING' => 99
		}
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'miniSQL', 1, undef
	],
	[#Rule 2
		 'statement', 2, undef
	],
	[#Rule 3
		 'statement', 1, undef
	],
	[#Rule 4
		 'select_stmt', 3,
sub
#line 28 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 5
		 'select_stmt', 2,
sub
#line 30 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 6
		 'models', 3,
sub
#line 34 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 7
		 'models', 1, undef
	],
	[#Rule 8
		 'model', 1,
sub
#line 38 "grammar/Select.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 9
		 'pattern_list', 3,
sub
#line 42 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 10
		 'pattern_list', 1, undef
	],
	[#Rule 11
		 'pattern', 2, undef
	],
	[#Rule 12
		 'pattern', 1, undef
	],
	[#Rule 13
		 'pattern', 1, undef
	],
	[#Rule 14
		 'pattern', 1, undef
	],
	[#Rule 15
		 'pattern', 1, undef
	],
	[#Rule 16
		 'aggregate', 4,
sub
#line 54 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'aggregate', 4,
sub
#line 56 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 18
		 'func', 1, undef
	],
	[#Rule 19
		 'func', 1, undef
	],
	[#Rule 20
		 'func', 1, undef
	],
	[#Rule 21
		 'func', 1, undef
	],
	[#Rule 22
		 'proc_call', 4,
sub
#line 66 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'parameter_list', 3,
sub
#line 70 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'parameter_list', 1, undef
	],
	[#Rule 25
		 'parameter', 1, undef
	],
	[#Rule 26
		 'variable', 1,
sub
#line 78 "grammar/Select.yp"
{
                push @OutVars, $_[1];
                my $val = $InVals->{$_[1]};
                if (!defined $val) {
                    push @Unbound, $_[1];
                    return $Quote->("");
                }
                $Quote->($val);
            }
	],
	[#Rule 27
		 'number', 1, undef
	],
	[#Rule 28
		 'number', 3,
sub
#line 91 "grammar/Select.yp"
{
                push @OutVars, $_[1];
                my $val = $InVals->{$_[1]};
                if (!defined $val) {
                    my $default;
                    $Defaults{$_[1]} = $default = $_[3];
                    return $default;
                }
                $Quote->($val);
            }
	],
	[#Rule 29
		 'string', 1,
sub
#line 103 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 30
		 'string', 3,
sub
#line 105 "grammar/Select.yp"
{ push @OutVars, $_[1];
            my $val = $InVals->{$_[1]};
            if (!defined $val) {
                my $default;
                $Defaults{$_[1]} = $default = parse_string($_[3]);
                return $Quote->($default);
            }
            $Quote->($val);
          }
	],
	[#Rule 31
		 'column', 1, undef
	],
	[#Rule 32
		 'column', 1,
sub
#line 117 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 33
		 'qualified_symbol', 3,
sub
#line 121 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 34
		 'symbol', 1, undef
	],
	[#Rule 35
		 'symbol', 3,
sub
#line 130 "grammar/Select.yp"
{ push @OutVars, $_[1];
            my $val = $InVals->{$_[1]};
            if (!defined $val) {
                my $default;
                $Defaults{$_[1]} = $default = $_[3];
                _IDENT($default) or die "Bad symbol: $default\n";
                return $default;
            }
            _IDENT($val) or die "Bad symbol: $val\n";
            $val;
          }
	],
	[#Rule 36
		 'symbol', 1,
sub
#line 142 "grammar/Select.yp"
{ push @OutVars, $_[1];
            my $val = $InVals->{$_[1]};
            if (!defined $val) {
                push @Unbound, $_[1];
                return '';
            }
            #warn _IDENT($val);
            _IDENT($val) or die "Bad symbol: $val\n";
            $val;
          }
	],
	[#Rule 37
		 'alias', 1, undef
	],
	[#Rule 38
		 'postfix_clause_list', 2,
sub
#line 158 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 39
		 'postfix_clause_list', 1, undef
	],
	[#Rule 40
		 'postfix_clause', 1, undef
	],
	[#Rule 41
		 'postfix_clause', 1, undef
	],
	[#Rule 42
		 'postfix_clause', 1, undef
	],
	[#Rule 43
		 'postfix_clause', 1, undef
	],
	[#Rule 44
		 'postfix_clause', 1, undef
	],
	[#Rule 45
		 'postfix_clause', 1, undef
	],
	[#Rule 46
		 'from_clause', 2,
sub
#line 171 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'from_clause', 2,
sub
#line 173 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'where_clause', 2,
sub
#line 177 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'condition', 1, undef
	],
	[#Rule 50
		 'disjunction', 3,
sub
#line 184 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'disjunction', 1, undef
	],
	[#Rule 52
		 'conjunction', 3,
sub
#line 189 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'conjunction', 1, undef
	],
	[#Rule 54
		 'comparison', 3,
sub
#line 194 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'comparison', 3,
sub
#line 196 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'comparison', 3,
sub
#line 198 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'operator', 1, undef
	],
	[#Rule 58
		 'operator', 1, undef
	],
	[#Rule 59
		 'operator', 1, undef
	],
	[#Rule 60
		 'operator', 1, undef
	],
	[#Rule 61
		 'operator', 1, undef
	],
	[#Rule 62
		 'operator', 1, undef
	],
	[#Rule 63
		 'operator', 1, undef
	],
	[#Rule 64
		 'literal', 1, undef
	],
	[#Rule 65
		 'literal', 1, undef
	],
	[#Rule 66
		 'literal', 1, undef
	],
	[#Rule 67
		 'group_by_clause', 2,
sub
#line 216 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 68
		 'column_list', 3,
sub
#line 220 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 69
		 'column_list', 1, undef
	],
	[#Rule 70
		 'order_by_clause', 2,
sub
#line 225 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 71
		 'order_by_objects', 3,
sub
#line 229 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 72
		 'order_by_objects', 1, undef
	],
	[#Rule 73
		 'order_by_object', 2,
sub
#line 234 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 74
		 'order_by_object', 1, undef
	],
	[#Rule 75
		 'order_by_modifier', 1, undef
	],
	[#Rule 76
		 'order_by_modifier', 1, undef
	],
	[#Rule 77
		 'limit_clause', 2,
sub
#line 242 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 78
		 'offset_clause', 2,
sub
#line 246 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 249 "grammar/Select.yp"


#use Smart::Comments;

sub _Error {
    my ($value) = $_[0]->YYCurval;

    my $token = 1;
    ## $value
    my @expect = $_[0]->YYExpect;
    ### expect: @expect
    my ($what) = $value ? "input: \"$value\"" : "end of input";

    map { $_ = "'$_'" if $_ ne '' and !/^\w+$/ } @expect;
    my $expected = join " or ", @expect;
    _SyntaxError(1, "Unexpected $what".($expected?" ($expected expected)":''), $.);
}

sub _SyntaxError {
    my ($level, $message, $lineno) = @_;

    $message= "line $lineno: error: $message";
    die $message, ".\n";
}

sub _Lexer {
    my ($parser) = shift;

    my $yydata = $parser->YYData;
    my $source = $yydata->{source};
    #local $" = "\n";
    defined $yydata->{input} && $yydata->{input} =~ s/^\s+//s;

    if (!defined $yydata->{input} || $yydata->{input} eq '') {
        ### HERE!!!
        $yydata->{input} = <$source>;
    }
    if (!defined $yydata->{input}) {
        return ('', undef);
    }

    ## other data: <$source>
    ### data: $yydata->{input}
    ### lineno: $.

    for ($yydata->{input}) {
        s/^\s*(\d+(?:\.\d+)?)\b//s
                and return ('NUM', $1);
        s/^\s*('(?:\\.|''|[^'])*')//
                and return ('STRING', $1);
        s/^\s*"(\w*)"//
                and return ('IDENT', $1);
        s/^\s*(\$(\w*)\$.*?\$\2\$)//
                and return ('STRING', $1);
        s/^\s*(\*|count|sum|max|min|select|and|or|from|where|delete|update|set|order by|asc|desc|group by|limit|offset)\b//is
                and return (lc($1), lc($1));
        s/^\s*(<=|>=|<>)//s
                and return ($1, $1);
        s/^\s*([A-Za-z][A-Za-z0-9_]*)\b//s
                and return ('IDENT', $1);
        s/^\$(\w+)//s
                and return ('VAR', $1);
        s/^\s*(\S)//s
                and return ($1, $1);
    }
}

sub parse_string {
    my $s = $_[0];
    if ($s =~ /^'(.*)'$/) {
        $s = $1;
        $s =~ s/''/'/g;
        $s =~ s/\\n/\n/g;
        $s =~ s/\\t/\t/g;
        $s =~ s/\\r/\r/g;
        $s =~ s/\\(.)/$1/g;
        return $s;
    } elsif ($s =~ /^\$(\w*)\$(.*)\$\1\$$/) {
        $s = $2;
        return $s;
    } elsif ($s =~ /^[\d\.]*$/) {
        return $s;
    } else {
        die "Unknown string literal: $s";
    }
}

sub parse {
    my ($self, $sql, $params) = @_;
    open my $source, '<', \$sql;
    my $yydata = $self->YYData;
    $yydata->{source} = $source;
    $yydata->{limit} = $params->{limit};
    $yydata->{offset} = $params->{offset};

    $Quote = $params->{quote} || sub { "''" };
    $QuoteIdent = $params->{quote_ident} || sub { '""' };
    $InVals = $params->{vars} || {};
    #$QuoteIdent = $params->{quote_ident};

    #$self->YYData->{INPUT} = ;
    ### $sql
    @Unbound = ();
    @Models = ();
    @Columns = ();
    @OutVars = ();
    %Defaults = ();
    my $sql = $self->YYParse( yydebug => 0 & 0x1F, yylex => \&_Lexer, yyerror => \&_Error );
    close $source;
    return {
        limit   => $yydata->{limit},
        offset  => $yydata->{offset},
        models  => [@Models],
        columns => [@Columns],
        sql => $sql,
        vars => [@OutVars],
        defaults => {%Defaults},
        unbound => [@Unbound],
    };
}

sub _IDENT {
    (defined $_[0] && $_[0] =~ /^[A-Za-z]\w*$/) ? $_[0] : undef;
}

#my ($select) =new Select;
#my $var = $select->Run;

1;


1;
