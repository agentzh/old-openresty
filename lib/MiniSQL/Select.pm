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
		DEFAULT => -33
	},
	{#State 7
		DEFAULT => -19
	},
	{#State 8
		ACTIONS => {
			"(" => 23
		},
		DEFAULT => -35
	},
	{#State 9
		DEFAULT => -13
	},
	{#State 10
		DEFAULT => -32
	},
	{#State 11
		DEFAULT => -22
	},
	{#State 12
		ACTIONS => {
			"," => 24
		},
		DEFAULT => -10
	},
	{#State 13
		DEFAULT => -16
	},
	{#State 14
		ACTIONS => {
			"|" => 25
		},
		DEFAULT => -37
	},
	{#State 15
		DEFAULT => -21
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
		DEFAULT => -20
	},
	{#State 20
		ACTIONS => {
			"as" => 44
		},
		DEFAULT => -15
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
			'symbol' => 45
		}
	},
	{#State 23
		ACTIONS => {
			'NUM' => 50,
			'VAR' => 53,
			'STRING' => 49
		},
		GOTOS => {
			'parameter' => 52,
			'literal' => 51,
			'number' => 47,
			'variable' => 46,
			'string' => 48,
			'parameter_list' => 54
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
			'pattern_list' => 55,
			'column' => 20
		}
	},
	{#State 25
		ACTIONS => {
			'IDENT' => 56
		}
	},
	{#State 26
		ACTIONS => {
			"(" => 60,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 57,
			'symbol' => 6,
			'conjunction' => 58,
			'disjunction' => 59,
			'condition' => 62,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 27
		DEFAULT => -45
	},
	{#State 28
		DEFAULT => -43
	},
	{#State 29
		DEFAULT => -4
	},
	{#State 30
		ACTIONS => {
			'NUM' => 50,
			'VAR' => 53,
			'STRING' => 49
		},
		GOTOS => {
			'literal' => 63,
			'number' => 47,
			'variable' => 46,
			'string' => 48
		}
	},
	{#State 31
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'order_by_objects' => 65,
			'column' => 66,
			'qualified_symbol' => 10,
			'order_by_object' => 64
		}
	},
	{#State 32
		DEFAULT => -41
	},
	{#State 33
		DEFAULT => -42
	},
	{#State 34
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 67,
			'column' => 68,
			'qualified_symbol' => 10
		}
	},
	{#State 35
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 8
		},
		GOTOS => {
			'models' => 69,
			'symbol' => 70,
			'model' => 71,
			'proc_call' => 72
		}
	},
	{#State 36
		DEFAULT => -46
	},
	{#State 37
		ACTIONS => {
			'NUM' => 50,
			'VAR' => 53,
			'STRING' => 49
		},
		GOTOS => {
			'literal' => 73,
			'number' => 47,
			'variable' => 46,
			'string' => 48
		}
	},
	{#State 38
		DEFAULT => -44
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
		DEFAULT => -40,
		GOTOS => {
			'postfix_clause_list' => 74,
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
		DEFAULT => -38
	},
	{#State 41
		DEFAULT => -35
	},
	{#State 42
		DEFAULT => -11
	},
	{#State 43
		ACTIONS => {
			"*" => 75,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column' => 76,
			'qualified_symbol' => 10
		}
	},
	{#State 44
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 40,
			'alias' => 77
		}
	},
	{#State 45
		DEFAULT => -34
	},
	{#State 46
		DEFAULT => -67
	},
	{#State 47
		DEFAULT => -66
	},
	{#State 48
		DEFAULT => -65
	},
	{#State 49
		DEFAULT => -30
	},
	{#State 50
		DEFAULT => -28
	},
	{#State 51
		DEFAULT => -26
	},
	{#State 52
		ACTIONS => {
			"," => 78
		},
		DEFAULT => -25
	},
	{#State 53
		ACTIONS => {
			"|" => 79
		},
		DEFAULT => -27
	},
	{#State 54
		ACTIONS => {
			")" => 80
		}
	},
	{#State 55
		DEFAULT => -9
	},
	{#State 56
		DEFAULT => -36
	},
	{#State 57
		ACTIONS => {
			"and" => 81
		},
		DEFAULT => -54
	},
	{#State 58
		ACTIONS => {
			"or" => 82
		},
		DEFAULT => -52
	},
	{#State 59
		DEFAULT => -50
	},
	{#State 60
		ACTIONS => {
			"(" => 60,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 57,
			'symbol' => 6,
			'conjunction' => 58,
			'disjunction' => 59,
			'condition' => 83,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 61
		ACTIONS => {
			"<" => 84,
			"like" => 85,
			"<=" => 89,
			">" => 91,
			"<>" => 90,
			">=" => 87,
			"=" => 86
		},
		GOTOS => {
			'operator' => 88
		}
	},
	{#State 62
		DEFAULT => -49
	},
	{#State 63
		DEFAULT => -78
	},
	{#State 64
		ACTIONS => {
			"," => 92
		},
		DEFAULT => -73
	},
	{#State 65
		DEFAULT => -71
	},
	{#State 66
		ACTIONS => {
			"desc" => 93,
			"asc" => 94
		},
		DEFAULT => -75,
		GOTOS => {
			'order_by_modifier' => 95
		}
	},
	{#State 67
		DEFAULT => -68
	},
	{#State 68
		ACTIONS => {
			"," => 96
		},
		DEFAULT => -70
	},
	{#State 69
		DEFAULT => -47
	},
	{#State 70
		DEFAULT => -8
	},
	{#State 71
		ACTIONS => {
			"," => 97
		},
		DEFAULT => -7
	},
	{#State 72
		DEFAULT => -48
	},
	{#State 73
		DEFAULT => -79
	},
	{#State 74
		DEFAULT => -39
	},
	{#State 75
		ACTIONS => {
			")" => 98
		}
	},
	{#State 76
		ACTIONS => {
			")" => 99
		}
	},
	{#State 77
		DEFAULT => -14
	},
	{#State 78
		ACTIONS => {
			'NUM' => 50,
			'VAR' => 53,
			'STRING' => 49
		},
		GOTOS => {
			'parameter' => 52,
			'literal' => 51,
			'number' => 47,
			'variable' => 46,
			'string' => 48,
			'parameter_list' => 100
		}
	},
	{#State 79
		ACTIONS => {
			'NUM' => 102,
			'STRING' => 101
		}
	},
	{#State 80
		DEFAULT => -23
	},
	{#State 81
		ACTIONS => {
			"(" => 60,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 103,
			'symbol' => 6,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 82
		ACTIONS => {
			"(" => 60,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 57,
			'conjunction' => 104,
			'symbol' => 6,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 83
		ACTIONS => {
			")" => 105
		}
	},
	{#State 84
		DEFAULT => -61
	},
	{#State 85
		DEFAULT => -64
	},
	{#State 86
		DEFAULT => -63
	},
	{#State 87
		DEFAULT => -59
	},
	{#State 88
		ACTIONS => {
			'NUM' => 50,
			'VAR' => 107,
			'IDENT' => 41,
			'STRING' => 49
		},
		GOTOS => {
			'literal' => 106,
			'symbol' => 6,
			'number' => 47,
			'variable' => 46,
			'string' => 48,
			'column' => 108,
			'qualified_symbol' => 10
		}
	},
	{#State 89
		DEFAULT => -60
	},
	{#State 90
		DEFAULT => -62
	},
	{#State 91
		DEFAULT => -58
	},
	{#State 92
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'order_by_objects' => 109,
			'column' => 66,
			'qualified_symbol' => 10,
			'order_by_object' => 64
		}
	},
	{#State 93
		DEFAULT => -77
	},
	{#State 94
		DEFAULT => -76
	},
	{#State 95
		DEFAULT => -74
	},
	{#State 96
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 110,
			'column' => 68,
			'qualified_symbol' => 10
		}
	},
	{#State 97
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'models' => 111,
			'symbol' => 70,
			'model' => 71
		}
	},
	{#State 98
		DEFAULT => -18
	},
	{#State 99
		DEFAULT => -17
	},
	{#State 100
		DEFAULT => -24
	},
	{#State 101
		DEFAULT => -31
	},
	{#State 102
		DEFAULT => -29
	},
	{#State 103
		DEFAULT => -53
	},
	{#State 104
		DEFAULT => -51
	},
	{#State 105
		DEFAULT => -57
	},
	{#State 106
		DEFAULT => -55
	},
	{#State 107
		ACTIONS => {
			"|" => 112,
			"." => -37
		},
		DEFAULT => -27
	},
	{#State 108
		DEFAULT => -56
	},
	{#State 109
		DEFAULT => -72
	},
	{#State 110
		DEFAULT => -69
	},
	{#State 111
		DEFAULT => -6
	},
	{#State 112
		ACTIONS => {
			'NUM' => 102,
			'IDENT' => 56,
			'STRING' => 101
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
		 'pattern', 2,
sub
#line 47 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 12
		 'pattern', 1, undef
	],
	[#Rule 13
		 'pattern', 1, undef
	],
	[#Rule 14
		 'pattern', 3,
sub
#line 51 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 15
		 'pattern', 1, undef
	],
	[#Rule 16
		 'pattern', 1, undef
	],
	[#Rule 17
		 'aggregate', 4,
sub
#line 57 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 18
		 'aggregate', 4,
sub
#line 59 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'func', 1, undef
	],
	[#Rule 23
		 'proc_call', 4,
sub
#line 69 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'parameter_list', 3,
sub
#line 73 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'parameter_list', 1, undef
	],
	[#Rule 26
		 'parameter', 1, undef
	],
	[#Rule 27
		 'variable', 1,
sub
#line 81 "grammar/Select.yp"
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
	[#Rule 28
		 'number', 1, undef
	],
	[#Rule 29
		 'number', 3,
sub
#line 94 "grammar/Select.yp"
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
	[#Rule 30
		 'string', 1,
sub
#line 106 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 31
		 'string', 3,
sub
#line 108 "grammar/Select.yp"
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
	[#Rule 32
		 'column', 1, undef
	],
	[#Rule 33
		 'column', 1,
sub
#line 120 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 34
		 'qualified_symbol', 3,
sub
#line 124 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 35
		 'symbol', 1, undef
	],
	[#Rule 36
		 'symbol', 3,
sub
#line 133 "grammar/Select.yp"
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
	[#Rule 37
		 'symbol', 1,
sub
#line 145 "grammar/Select.yp"
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
	[#Rule 38
		 'alias', 1, undef
	],
	[#Rule 39
		 'postfix_clause_list', 2,
sub
#line 161 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 40
		 'postfix_clause_list', 1, undef
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
		 'postfix_clause', 1, undef
	],
	[#Rule 47
		 'from_clause', 2,
sub
#line 174 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'from_clause', 2,
sub
#line 176 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'where_clause', 2,
sub
#line 180 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'condition', 1, undef
	],
	[#Rule 51
		 'disjunction', 3,
sub
#line 187 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'disjunction', 1, undef
	],
	[#Rule 53
		 'conjunction', 3,
sub
#line 192 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'conjunction', 1, undef
	],
	[#Rule 55
		 'comparison', 3,
sub
#line 197 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'comparison', 3,
sub
#line 199 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'comparison', 3,
sub
#line 201 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'operator', 1, undef
	],
	[#Rule 65
		 'literal', 1, undef
	],
	[#Rule 66
		 'literal', 1, undef
	],
	[#Rule 67
		 'literal', 1, undef
	],
	[#Rule 68
		 'group_by_clause', 2,
sub
#line 219 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 69
		 'column_list', 3,
sub
#line 223 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 70
		 'column_list', 1, undef
	],
	[#Rule 71
		 'order_by_clause', 2,
sub
#line 228 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 72
		 'order_by_objects', 3,
sub
#line 232 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 73
		 'order_by_objects', 1, undef
	],
	[#Rule 74
		 'order_by_object', 2,
sub
#line 237 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 75
		 'order_by_object', 1, undef
	],
	[#Rule 76
		 'order_by_modifier', 1, undef
	],
	[#Rule 77
		 'order_by_modifier', 1, undef
	],
	[#Rule 78
		 'limit_clause', 2,
sub
#line 245 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 79
		 'offset_clause', 2,
sub
#line 249 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 252 "grammar/Select.yp"


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
        s/^\s*(\*|as|count|sum|max|min|select|and|or|from|where|delete|update|set|order by|asc|desc|group by|limit|offset)\b//is
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
