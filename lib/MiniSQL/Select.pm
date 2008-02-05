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
			'miniSQL' => 5,
			'compound_select_stmt' => 4
		}
	},
	{#State 1
		ACTIONS => {
			"intersect" => 6,
			"union" => 7,
			"except" => 8
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 9
		}
	},
	{#State 2
		DEFAULT => -1
	},
	{#State 3
		ACTIONS => {
			"sum" => 15,
			"max" => 11,
			"*" => 17,
			'VAR' => 18,
			"count" => 19,
			'IDENT' => 12,
			"min" => 23
		},
		GOTOS => {
			'symbol' => 10,
			'proc_call' => 13,
			'qualified_symbol' => 14,
			'pattern' => 16,
			'pattern_list' => 20,
			'aggregate' => 21,
			'func' => 22,
			'column' => 24
		}
	},
	{#State 4
		ACTIONS => {
			";" => 25
		},
		DEFAULT => -3
	},
	{#State 5
		ACTIONS => {
			'' => 26
		}
	},
	{#State 6
		DEFAULT => -7
	},
	{#State 7
		DEFAULT => -6
	},
	{#State 8
		DEFAULT => -8
	},
	{#State 9
		ACTIONS => {
			"select" => 3
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 27
		}
	},
	{#State 10
		ACTIONS => {
			"." => 28
		},
		DEFAULT => -38
	},
	{#State 11
		DEFAULT => -24
	},
	{#State 12
		ACTIONS => {
			"(" => 29
		},
		DEFAULT => -40
	},
	{#State 13
		DEFAULT => -18
	},
	{#State 14
		DEFAULT => -37
	},
	{#State 15
		DEFAULT => -27
	},
	{#State 16
		ACTIONS => {
			"," => 30
		},
		DEFAULT => -15
	},
	{#State 17
		DEFAULT => -21
	},
	{#State 18
		ACTIONS => {
			"|" => 31
		},
		DEFAULT => -42
	},
	{#State 19
		DEFAULT => -26
	},
	{#State 20
		ACTIONS => {
			"where" => 32,
			"order by" => 37,
			"limit" => 36,
			"group by" => 40,
			"from" => 41,
			"offset" => 43
		},
		DEFAULT => -10,
		GOTOS => {
			'postfix_clause_list' => 35,
			'order_by_clause' => 34,
			'offset_clause' => 33,
			'from_clause' => 42,
			'where_clause' => 38,
			'group_by_clause' => 39,
			'limit_clause' => 44,
			'postfix_clause' => 45
		}
	},
	{#State 21
		ACTIONS => {
			'IDENT' => 47,
			'VAR' => 18
		},
		DEFAULT => -17,
		GOTOS => {
			'symbol' => 46,
			'alias' => 48
		}
	},
	{#State 22
		ACTIONS => {
			"(" => 49
		}
	},
	{#State 23
		DEFAULT => -25
	},
	{#State 24
		ACTIONS => {
			"as" => 50
		},
		DEFAULT => -20
	},
	{#State 25
		DEFAULT => -2
	},
	{#State 26
		DEFAULT => 0
	},
	{#State 27
		DEFAULT => -4
	},
	{#State 28
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 51
		}
	},
	{#State 29
		ACTIONS => {
			'NUM' => 56,
			'VAR' => 59,
			'STRING' => 55
		},
		GOTOS => {
			'parameter' => 58,
			'literal' => 57,
			'number' => 53,
			'variable' => 52,
			'string' => 54,
			'parameter_list' => 60
		}
	},
	{#State 30
		ACTIONS => {
			"sum" => 15,
			"max" => 11,
			"*" => 17,
			'VAR' => 18,
			"count" => 19,
			'IDENT' => 12,
			"min" => 23
		},
		GOTOS => {
			'symbol' => 10,
			'proc_call' => 13,
			'qualified_symbol' => 14,
			'pattern' => 16,
			'func' => 22,
			'aggregate' => 21,
			'pattern_list' => 61,
			'column' => 24
		}
	},
	{#State 31
		ACTIONS => {
			'IDENT' => 62
		}
	},
	{#State 32
		ACTIONS => {
			"(" => 66,
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'comparison' => 63,
			'symbol' => 10,
			'conjunction' => 64,
			'disjunction' => 65,
			'condition' => 68,
			'column' => 67,
			'qualified_symbol' => 14
		}
	},
	{#State 33
		DEFAULT => -50
	},
	{#State 34
		DEFAULT => -48
	},
	{#State 35
		DEFAULT => -9
	},
	{#State 36
		ACTIONS => {
			'NUM' => 56,
			'VAR' => 59,
			'STRING' => 55
		},
		GOTOS => {
			'literal' => 69,
			'number' => 53,
			'variable' => 52,
			'string' => 54
		}
	},
	{#State 37
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 10,
			'order_by_objects' => 71,
			'column' => 72,
			'qualified_symbol' => 14,
			'order_by_object' => 70
		}
	},
	{#State 38
		DEFAULT => -46
	},
	{#State 39
		DEFAULT => -47
	},
	{#State 40
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 10,
			'column_list' => 73,
			'column' => 74,
			'qualified_symbol' => 14
		}
	},
	{#State 41
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 12
		},
		GOTOS => {
			'models' => 75,
			'symbol' => 76,
			'model' => 77,
			'proc_call' => 78
		}
	},
	{#State 42
		DEFAULT => -51
	},
	{#State 43
		ACTIONS => {
			'NUM' => 56,
			'VAR' => 59,
			'STRING' => 55
		},
		GOTOS => {
			'literal' => 79,
			'number' => 53,
			'variable' => 52,
			'string' => 54
		}
	},
	{#State 44
		DEFAULT => -49
	},
	{#State 45
		ACTIONS => {
			"where" => 32,
			"order by" => 37,
			"limit" => 36,
			"group by" => 40,
			"from" => 41,
			"offset" => 43
		},
		DEFAULT => -45,
		GOTOS => {
			'postfix_clause_list' => 80,
			'order_by_clause' => 34,
			'offset_clause' => 33,
			'from_clause' => 42,
			'where_clause' => 38,
			'group_by_clause' => 39,
			'limit_clause' => 44,
			'postfix_clause' => 45
		}
	},
	{#State 46
		DEFAULT => -43
	},
	{#State 47
		DEFAULT => -40
	},
	{#State 48
		DEFAULT => -16
	},
	{#State 49
		ACTIONS => {
			"*" => 81,
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 10,
			'column' => 82,
			'qualified_symbol' => 14
		}
	},
	{#State 50
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 46,
			'alias' => 83
		}
	},
	{#State 51
		DEFAULT => -39
	},
	{#State 52
		DEFAULT => -72
	},
	{#State 53
		DEFAULT => -71
	},
	{#State 54
		DEFAULT => -70
	},
	{#State 55
		DEFAULT => -35
	},
	{#State 56
		DEFAULT => -33
	},
	{#State 57
		DEFAULT => -31
	},
	{#State 58
		ACTIONS => {
			"," => 84
		},
		DEFAULT => -30
	},
	{#State 59
		ACTIONS => {
			"|" => 85
		},
		DEFAULT => -32
	},
	{#State 60
		ACTIONS => {
			")" => 86
		}
	},
	{#State 61
		DEFAULT => -14
	},
	{#State 62
		DEFAULT => -41
	},
	{#State 63
		ACTIONS => {
			"and" => 87
		},
		DEFAULT => -59
	},
	{#State 64
		ACTIONS => {
			"or" => 88
		},
		DEFAULT => -57
	},
	{#State 65
		DEFAULT => -55
	},
	{#State 66
		ACTIONS => {
			"(" => 66,
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'comparison' => 63,
			'symbol' => 10,
			'conjunction' => 64,
			'disjunction' => 65,
			'condition' => 89,
			'column' => 67,
			'qualified_symbol' => 14
		}
	},
	{#State 67
		ACTIONS => {
			"<" => 90,
			"like" => 91,
			"<=" => 95,
			">" => 97,
			"<>" => 96,
			">=" => 93,
			"=" => 92
		},
		GOTOS => {
			'operator' => 94
		}
	},
	{#State 68
		DEFAULT => -54
	},
	{#State 69
		DEFAULT => -83
	},
	{#State 70
		ACTIONS => {
			"," => 98
		},
		DEFAULT => -78
	},
	{#State 71
		DEFAULT => -76
	},
	{#State 72
		ACTIONS => {
			"desc" => 99,
			"asc" => 100
		},
		DEFAULT => -80,
		GOTOS => {
			'order_by_modifier' => 101
		}
	},
	{#State 73
		DEFAULT => -73
	},
	{#State 74
		ACTIONS => {
			"," => 102
		},
		DEFAULT => -75
	},
	{#State 75
		DEFAULT => -52
	},
	{#State 76
		DEFAULT => -13
	},
	{#State 77
		ACTIONS => {
			"," => 103
		},
		DEFAULT => -12
	},
	{#State 78
		DEFAULT => -53
	},
	{#State 79
		DEFAULT => -84
	},
	{#State 80
		DEFAULT => -44
	},
	{#State 81
		ACTIONS => {
			")" => 104
		}
	},
	{#State 82
		ACTIONS => {
			")" => 105
		}
	},
	{#State 83
		DEFAULT => -19
	},
	{#State 84
		ACTIONS => {
			'NUM' => 56,
			'VAR' => 59,
			'STRING' => 55
		},
		GOTOS => {
			'parameter' => 58,
			'literal' => 57,
			'number' => 53,
			'variable' => 52,
			'string' => 54,
			'parameter_list' => 106
		}
	},
	{#State 85
		ACTIONS => {
			'NUM' => 108,
			'STRING' => 107
		}
	},
	{#State 86
		DEFAULT => -28
	},
	{#State 87
		ACTIONS => {
			"(" => 66,
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'comparison' => 109,
			'symbol' => 10,
			'column' => 67,
			'qualified_symbol' => 14
		}
	},
	{#State 88
		ACTIONS => {
			"(" => 66,
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'comparison' => 63,
			'conjunction' => 110,
			'symbol' => 10,
			'column' => 67,
			'qualified_symbol' => 14
		}
	},
	{#State 89
		ACTIONS => {
			")" => 111
		}
	},
	{#State 90
		DEFAULT => -66
	},
	{#State 91
		DEFAULT => -69
	},
	{#State 92
		DEFAULT => -68
	},
	{#State 93
		DEFAULT => -64
	},
	{#State 94
		ACTIONS => {
			'NUM' => 56,
			'VAR' => 113,
			'IDENT' => 47,
			'STRING' => 55
		},
		GOTOS => {
			'literal' => 112,
			'symbol' => 10,
			'number' => 53,
			'variable' => 52,
			'string' => 54,
			'column' => 114,
			'qualified_symbol' => 14
		}
	},
	{#State 95
		DEFAULT => -65
	},
	{#State 96
		DEFAULT => -67
	},
	{#State 97
		DEFAULT => -63
	},
	{#State 98
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 10,
			'order_by_objects' => 115,
			'column' => 72,
			'qualified_symbol' => 14,
			'order_by_object' => 70
		}
	},
	{#State 99
		DEFAULT => -82
	},
	{#State 100
		DEFAULT => -81
	},
	{#State 101
		DEFAULT => -79
	},
	{#State 102
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'symbol' => 10,
			'column_list' => 116,
			'column' => 74,
			'qualified_symbol' => 14
		}
	},
	{#State 103
		ACTIONS => {
			'VAR' => 18,
			'IDENT' => 47
		},
		GOTOS => {
			'models' => 117,
			'symbol' => 76,
			'model' => 77
		}
	},
	{#State 104
		DEFAULT => -23
	},
	{#State 105
		DEFAULT => -22
	},
	{#State 106
		DEFAULT => -29
	},
	{#State 107
		DEFAULT => -36
	},
	{#State 108
		DEFAULT => -34
	},
	{#State 109
		DEFAULT => -58
	},
	{#State 110
		DEFAULT => -56
	},
	{#State 111
		DEFAULT => -62
	},
	{#State 112
		DEFAULT => -60
	},
	{#State 113
		ACTIONS => {
			"|" => 118,
			"." => -42
		},
		DEFAULT => -32
	},
	{#State 114
		DEFAULT => -61
	},
	{#State 115
		DEFAULT => -77
	},
	{#State 116
		DEFAULT => -74
	},
	{#State 117
		DEFAULT => -11
	},
	{#State 118
		ACTIONS => {
			'NUM' => 108,
			'IDENT' => 62,
			'STRING' => 107
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
		 'compound_select_stmt', 3,
sub
#line 28 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 5
		 'compound_select_stmt', 1, undef
	],
	[#Rule 6
		 'set_operator', 1, undef
	],
	[#Rule 7
		 'set_operator', 1, undef
	],
	[#Rule 8
		 'set_operator', 1, undef
	],
	[#Rule 9
		 'select_stmt', 3,
sub
#line 36 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 10
		 'select_stmt', 2,
sub
#line 38 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 11
		 'models', 3,
sub
#line 42 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 12
		 'models', 1, undef
	],
	[#Rule 13
		 'model', 1,
sub
#line 46 "grammar/Select.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 14
		 'pattern_list', 3,
sub
#line 50 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 15
		 'pattern_list', 1, undef
	],
	[#Rule 16
		 'pattern', 2,
sub
#line 55 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'pattern', 1, undef
	],
	[#Rule 18
		 'pattern', 1, undef
	],
	[#Rule 19
		 'pattern', 3,
sub
#line 59 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 20
		 'pattern', 1, undef
	],
	[#Rule 21
		 'pattern', 1, undef
	],
	[#Rule 22
		 'aggregate', 4,
sub
#line 65 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'aggregate', 4,
sub
#line 67 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'func', 1, undef
	],
	[#Rule 25
		 'func', 1, undef
	],
	[#Rule 26
		 'func', 1, undef
	],
	[#Rule 27
		 'func', 1, undef
	],
	[#Rule 28
		 'proc_call', 4,
sub
#line 77 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'parameter_list', 3,
sub
#line 81 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'parameter_list', 1, undef
	],
	[#Rule 31
		 'parameter', 1, undef
	],
	[#Rule 32
		 'variable', 1,
sub
#line 89 "grammar/Select.yp"
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
	[#Rule 33
		 'number', 1, undef
	],
	[#Rule 34
		 'number', 3,
sub
#line 102 "grammar/Select.yp"
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
	[#Rule 35
		 'string', 1,
sub
#line 114 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 36
		 'string', 3,
sub
#line 116 "grammar/Select.yp"
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
	[#Rule 37
		 'column', 1, undef
	],
	[#Rule 38
		 'column', 1,
sub
#line 128 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 39
		 'qualified_symbol', 3,
sub
#line 132 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 40
		 'symbol', 1, undef
	],
	[#Rule 41
		 'symbol', 3,
sub
#line 141 "grammar/Select.yp"
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
	[#Rule 42
		 'symbol', 1,
sub
#line 153 "grammar/Select.yp"
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
	[#Rule 43
		 'alias', 1, undef
	],
	[#Rule 44
		 'postfix_clause_list', 2,
sub
#line 169 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 45
		 'postfix_clause_list', 1, undef
	],
	[#Rule 46
		 'postfix_clause', 1, undef
	],
	[#Rule 47
		 'postfix_clause', 1, undef
	],
	[#Rule 48
		 'postfix_clause', 1, undef
	],
	[#Rule 49
		 'postfix_clause', 1, undef
	],
	[#Rule 50
		 'postfix_clause', 1, undef
	],
	[#Rule 51
		 'postfix_clause', 1, undef
	],
	[#Rule 52
		 'from_clause', 2,
sub
#line 182 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'from_clause', 2,
sub
#line 184 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'where_clause', 2,
sub
#line 188 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'condition', 1, undef
	],
	[#Rule 56
		 'disjunction', 3,
sub
#line 195 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'disjunction', 1, undef
	],
	[#Rule 58
		 'conjunction', 3,
sub
#line 200 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'conjunction', 1, undef
	],
	[#Rule 60
		 'comparison', 3,
sub
#line 205 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'comparison', 3,
sub
#line 207 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'comparison', 3,
sub
#line 209 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'operator', 1, undef
	],
	[#Rule 64
		 'operator', 1, undef
	],
	[#Rule 65
		 'operator', 1, undef
	],
	[#Rule 66
		 'operator', 1, undef
	],
	[#Rule 67
		 'operator', 1, undef
	],
	[#Rule 68
		 'operator', 1, undef
	],
	[#Rule 69
		 'operator', 1, undef
	],
	[#Rule 70
		 'literal', 1, undef
	],
	[#Rule 71
		 'literal', 1, undef
	],
	[#Rule 72
		 'literal', 1, undef
	],
	[#Rule 73
		 'group_by_clause', 2,
sub
#line 227 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 74
		 'column_list', 3,
sub
#line 231 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 75
		 'column_list', 1, undef
	],
	[#Rule 76
		 'order_by_clause', 2,
sub
#line 236 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 77
		 'order_by_objects', 3,
sub
#line 240 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 78
		 'order_by_objects', 1, undef
	],
	[#Rule 79
		 'order_by_object', 2,
sub
#line 245 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 80
		 'order_by_object', 1, undef
	],
	[#Rule 81
		 'order_by_modifier', 1, undef
	],
	[#Rule 82
		 'order_by_modifier', 1, undef
	],
	[#Rule 83
		 'limit_clause', 2,
sub
#line 253 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 84
		 'offset_clause', 2,
sub
#line 257 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 260 "grammar/Select.yp"


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
        s/^\s*(\*|as|count|sum|max|min|select|and|or|from|where|delete|update|set|order by|asc|desc|group by|limit|offset|union|intersect|except)\b//is
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
