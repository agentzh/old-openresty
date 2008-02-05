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
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'statement' => 3,
			'miniSQL' => 6,
			'compound_select_stmt' => 5
		}
	},
	{#State 1
		DEFAULT => -6
	},
	{#State 2
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 7
		}
	},
	{#State 3
		DEFAULT => -1
	},
	{#State 4
		ACTIONS => {
			"sum" => 13,
			"max" => 9,
			"*" => 15,
			'VAR' => 16,
			"count" => 17,
			'IDENT' => 10,
			"min" => 21
		},
		GOTOS => {
			'symbol' => 8,
			'proc_call' => 11,
			'qualified_symbol' => 12,
			'pattern' => 14,
			'pattern_list' => 18,
			'aggregate' => 19,
			'func' => 20,
			'column' => 22
		}
	},
	{#State 5
		ACTIONS => {
			";" => 23
		},
		DEFAULT => -3
	},
	{#State 6
		ACTIONS => {
			'' => 24
		}
	},
	{#State 7
		ACTIONS => {
			")" => 25
		}
	},
	{#State 8
		ACTIONS => {
			"." => 26
		},
		DEFAULT => -39
	},
	{#State 9
		DEFAULT => -25
	},
	{#State 10
		ACTIONS => {
			"(" => 27
		},
		DEFAULT => -41
	},
	{#State 11
		DEFAULT => -19
	},
	{#State 12
		DEFAULT => -38
	},
	{#State 13
		DEFAULT => -28
	},
	{#State 14
		ACTIONS => {
			"," => 28
		},
		DEFAULT => -16
	},
	{#State 15
		DEFAULT => -22
	},
	{#State 16
		ACTIONS => {
			"|" => 29
		},
		DEFAULT => -43
	},
	{#State 17
		DEFAULT => -27
	},
	{#State 18
		ACTIONS => {
			"where" => 30,
			"order by" => 35,
			"limit" => 34,
			"group by" => 38,
			"from" => 39,
			"offset" => 41
		},
		DEFAULT => -11,
		GOTOS => {
			'postfix_clause_list' => 33,
			'order_by_clause' => 32,
			'offset_clause' => 31,
			'from_clause' => 40,
			'where_clause' => 36,
			'group_by_clause' => 37,
			'limit_clause' => 42,
			'postfix_clause' => 43
		}
	},
	{#State 19
		ACTIONS => {
			'IDENT' => 45,
			'VAR' => 16
		},
		DEFAULT => -18,
		GOTOS => {
			'symbol' => 44,
			'alias' => 46
		}
	},
	{#State 20
		ACTIONS => {
			"(" => 47
		}
	},
	{#State 21
		DEFAULT => -26
	},
	{#State 22
		ACTIONS => {
			"as" => 48
		},
		DEFAULT => -21
	},
	{#State 23
		DEFAULT => -2
	},
	{#State 24
		DEFAULT => 0
	},
	{#State 25
		ACTIONS => {
			"intersect" => 52,
			"union" => 49,
			"except" => 50
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 51
		}
	},
	{#State 26
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 53
		}
	},
	{#State 27
		ACTIONS => {
			'NUM' => 58,
			'VAR' => 61,
			'STRING' => 57
		},
		GOTOS => {
			'parameter' => 60,
			'literal' => 59,
			'number' => 55,
			'variable' => 54,
			'string' => 56,
			'parameter_list' => 62
		}
	},
	{#State 28
		ACTIONS => {
			"sum" => 13,
			"max" => 9,
			"*" => 15,
			'VAR' => 16,
			"count" => 17,
			'IDENT' => 10,
			"min" => 21
		},
		GOTOS => {
			'symbol' => 8,
			'proc_call' => 11,
			'qualified_symbol' => 12,
			'pattern' => 14,
			'func' => 20,
			'aggregate' => 19,
			'pattern_list' => 63,
			'column' => 22
		}
	},
	{#State 29
		ACTIONS => {
			'IDENT' => 64
		}
	},
	{#State 30
		ACTIONS => {
			"(" => 68,
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'comparison' => 65,
			'symbol' => 8,
			'conjunction' => 66,
			'disjunction' => 67,
			'condition' => 70,
			'column' => 69,
			'qualified_symbol' => 12
		}
	},
	{#State 31
		DEFAULT => -51
	},
	{#State 32
		DEFAULT => -49
	},
	{#State 33
		DEFAULT => -10
	},
	{#State 34
		ACTIONS => {
			'NUM' => 58,
			'VAR' => 61,
			'STRING' => 57
		},
		GOTOS => {
			'literal' => 71,
			'number' => 55,
			'variable' => 54,
			'string' => 56
		}
	},
	{#State 35
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 8,
			'order_by_objects' => 73,
			'column' => 74,
			'qualified_symbol' => 12,
			'order_by_object' => 72
		}
	},
	{#State 36
		DEFAULT => -47
	},
	{#State 37
		DEFAULT => -48
	},
	{#State 38
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 8,
			'column_list' => 75,
			'column' => 76,
			'qualified_symbol' => 12
		}
	},
	{#State 39
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 77,
			'symbol' => 78,
			'model' => 79,
			'proc_call' => 80
		}
	},
	{#State 40
		DEFAULT => -52
	},
	{#State 41
		ACTIONS => {
			'NUM' => 58,
			'VAR' => 61,
			'STRING' => 57
		},
		GOTOS => {
			'literal' => 81,
			'number' => 55,
			'variable' => 54,
			'string' => 56
		}
	},
	{#State 42
		DEFAULT => -50
	},
	{#State 43
		ACTIONS => {
			"where" => 30,
			"order by" => 35,
			"limit" => 34,
			"group by" => 38,
			"from" => 39,
			"offset" => 41
		},
		DEFAULT => -46,
		GOTOS => {
			'postfix_clause_list' => 82,
			'order_by_clause' => 32,
			'offset_clause' => 31,
			'from_clause' => 40,
			'where_clause' => 36,
			'group_by_clause' => 37,
			'limit_clause' => 42,
			'postfix_clause' => 43
		}
	},
	{#State 44
		DEFAULT => -44
	},
	{#State 45
		DEFAULT => -41
	},
	{#State 46
		DEFAULT => -17
	},
	{#State 47
		ACTIONS => {
			"*" => 83,
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 8,
			'column' => 84,
			'qualified_symbol' => 12
		}
	},
	{#State 48
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 44,
			'alias' => 85
		}
	},
	{#State 49
		DEFAULT => -7
	},
	{#State 50
		DEFAULT => -9
	},
	{#State 51
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 86
		}
	},
	{#State 52
		DEFAULT => -8
	},
	{#State 53
		DEFAULT => -40
	},
	{#State 54
		DEFAULT => -73
	},
	{#State 55
		DEFAULT => -72
	},
	{#State 56
		DEFAULT => -71
	},
	{#State 57
		DEFAULT => -36
	},
	{#State 58
		DEFAULT => -34
	},
	{#State 59
		DEFAULT => -32
	},
	{#State 60
		ACTIONS => {
			"," => 87
		},
		DEFAULT => -31
	},
	{#State 61
		ACTIONS => {
			"|" => 88
		},
		DEFAULT => -33
	},
	{#State 62
		ACTIONS => {
			")" => 89
		}
	},
	{#State 63
		DEFAULT => -15
	},
	{#State 64
		DEFAULT => -42
	},
	{#State 65
		ACTIONS => {
			"and" => 90
		},
		DEFAULT => -60
	},
	{#State 66
		ACTIONS => {
			"or" => 91
		},
		DEFAULT => -58
	},
	{#State 67
		DEFAULT => -56
	},
	{#State 68
		ACTIONS => {
			"(" => 68,
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'comparison' => 65,
			'symbol' => 8,
			'conjunction' => 66,
			'disjunction' => 67,
			'condition' => 92,
			'column' => 69,
			'qualified_symbol' => 12
		}
	},
	{#State 69
		ACTIONS => {
			"<" => 93,
			"like" => 94,
			"<=" => 98,
			">" => 100,
			"<>" => 99,
			">=" => 96,
			"=" => 95
		},
		GOTOS => {
			'operator' => 97
		}
	},
	{#State 70
		DEFAULT => -55
	},
	{#State 71
		DEFAULT => -84
	},
	{#State 72
		ACTIONS => {
			"," => 101
		},
		DEFAULT => -79
	},
	{#State 73
		DEFAULT => -77
	},
	{#State 74
		ACTIONS => {
			"desc" => 102,
			"asc" => 103
		},
		DEFAULT => -81,
		GOTOS => {
			'order_by_modifier' => 104
		}
	},
	{#State 75
		DEFAULT => -74
	},
	{#State 76
		ACTIONS => {
			"," => 105
		},
		DEFAULT => -76
	},
	{#State 77
		DEFAULT => -53
	},
	{#State 78
		DEFAULT => -14
	},
	{#State 79
		ACTIONS => {
			"," => 106
		},
		DEFAULT => -13
	},
	{#State 80
		DEFAULT => -54
	},
	{#State 81
		DEFAULT => -85
	},
	{#State 82
		DEFAULT => -45
	},
	{#State 83
		ACTIONS => {
			")" => 107
		}
	},
	{#State 84
		ACTIONS => {
			")" => 108
		}
	},
	{#State 85
		DEFAULT => -20
	},
	{#State 86
		DEFAULT => -4
	},
	{#State 87
		ACTIONS => {
			'NUM' => 58,
			'VAR' => 61,
			'STRING' => 57
		},
		GOTOS => {
			'parameter' => 60,
			'literal' => 59,
			'number' => 55,
			'variable' => 54,
			'string' => 56,
			'parameter_list' => 109
		}
	},
	{#State 88
		ACTIONS => {
			'NUM' => 111,
			'STRING' => 110
		}
	},
	{#State 89
		DEFAULT => -29
	},
	{#State 90
		ACTIONS => {
			"(" => 68,
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'comparison' => 112,
			'symbol' => 8,
			'column' => 69,
			'qualified_symbol' => 12
		}
	},
	{#State 91
		ACTIONS => {
			"(" => 68,
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'comparison' => 65,
			'conjunction' => 113,
			'symbol' => 8,
			'column' => 69,
			'qualified_symbol' => 12
		}
	},
	{#State 92
		ACTIONS => {
			")" => 114
		}
	},
	{#State 93
		DEFAULT => -67
	},
	{#State 94
		DEFAULT => -70
	},
	{#State 95
		DEFAULT => -69
	},
	{#State 96
		DEFAULT => -65
	},
	{#State 97
		ACTIONS => {
			'NUM' => 58,
			'VAR' => 116,
			'IDENT' => 45,
			'STRING' => 57
		},
		GOTOS => {
			'literal' => 115,
			'symbol' => 8,
			'number' => 55,
			'variable' => 54,
			'string' => 56,
			'column' => 117,
			'qualified_symbol' => 12
		}
	},
	{#State 98
		DEFAULT => -66
	},
	{#State 99
		DEFAULT => -68
	},
	{#State 100
		DEFAULT => -64
	},
	{#State 101
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 8,
			'order_by_objects' => 118,
			'column' => 74,
			'qualified_symbol' => 12,
			'order_by_object' => 72
		}
	},
	{#State 102
		DEFAULT => -83
	},
	{#State 103
		DEFAULT => -82
	},
	{#State 104
		DEFAULT => -80
	},
	{#State 105
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'symbol' => 8,
			'column_list' => 119,
			'column' => 76,
			'qualified_symbol' => 12
		}
	},
	{#State 106
		ACTIONS => {
			'VAR' => 16,
			'IDENT' => 45
		},
		GOTOS => {
			'models' => 120,
			'symbol' => 78,
			'model' => 79
		}
	},
	{#State 107
		DEFAULT => -24
	},
	{#State 108
		DEFAULT => -23
	},
	{#State 109
		DEFAULT => -30
	},
	{#State 110
		DEFAULT => -37
	},
	{#State 111
		DEFAULT => -35
	},
	{#State 112
		DEFAULT => -59
	},
	{#State 113
		DEFAULT => -57
	},
	{#State 114
		DEFAULT => -63
	},
	{#State 115
		DEFAULT => -61
	},
	{#State 116
		ACTIONS => {
			"|" => 121,
			"." => -43
		},
		DEFAULT => -33
	},
	{#State 117
		DEFAULT => -62
	},
	{#State 118
		DEFAULT => -78
	},
	{#State 119
		DEFAULT => -75
	},
	{#State 120
		DEFAULT => -12
	},
	{#State 121
		ACTIONS => {
			'NUM' => 111,
			'IDENT' => 64,
			'STRING' => 110
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
		 'compound_select_stmt', 5,
sub
#line 28 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 5
		 'compound_select_stmt', 3,
sub
#line 30 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 6
		 'compound_select_stmt', 1, undef
	],
	[#Rule 7
		 'set_operator', 1, undef
	],
	[#Rule 8
		 'set_operator', 1, undef
	],
	[#Rule 9
		 'set_operator', 1, undef
	],
	[#Rule 10
		 'select_stmt', 3,
sub
#line 38 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 11
		 'select_stmt', 2,
sub
#line 40 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 12
		 'models', 3,
sub
#line 44 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 13
		 'models', 1, undef
	],
	[#Rule 14
		 'model', 1,
sub
#line 48 "grammar/Select.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 15
		 'pattern_list', 3,
sub
#line 52 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 16
		 'pattern_list', 1, undef
	],
	[#Rule 17
		 'pattern', 2,
sub
#line 57 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 18
		 'pattern', 1, undef
	],
	[#Rule 19
		 'pattern', 1, undef
	],
	[#Rule 20
		 'pattern', 3,
sub
#line 61 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 21
		 'pattern', 1, undef
	],
	[#Rule 22
		 'pattern', 1, undef
	],
	[#Rule 23
		 'aggregate', 4,
sub
#line 67 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'aggregate', 4,
sub
#line 69 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'func', 1, undef
	],
	[#Rule 29
		 'proc_call', 4,
sub
#line 79 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'parameter_list', 3,
sub
#line 83 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 31
		 'parameter_list', 1, undef
	],
	[#Rule 32
		 'parameter', 1, undef
	],
	[#Rule 33
		 'variable', 1,
sub
#line 91 "grammar/Select.yp"
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
	[#Rule 34
		 'number', 1, undef
	],
	[#Rule 35
		 'number', 3,
sub
#line 104 "grammar/Select.yp"
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
	[#Rule 36
		 'string', 1,
sub
#line 116 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 37
		 'string', 3,
sub
#line 118 "grammar/Select.yp"
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
	[#Rule 38
		 'column', 1, undef
	],
	[#Rule 39
		 'column', 1,
sub
#line 130 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 40
		 'qualified_symbol', 3,
sub
#line 134 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 41
		 'symbol', 1, undef
	],
	[#Rule 42
		 'symbol', 3,
sub
#line 143 "grammar/Select.yp"
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
	[#Rule 43
		 'symbol', 1,
sub
#line 155 "grammar/Select.yp"
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
	[#Rule 44
		 'alias', 1, undef
	],
	[#Rule 45
		 'postfix_clause_list', 2,
sub
#line 171 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 46
		 'postfix_clause_list', 1, undef
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
		 'postfix_clause', 1, undef
	],
	[#Rule 53
		 'from_clause', 2,
sub
#line 184 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'from_clause', 2,
sub
#line 186 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'where_clause', 2,
sub
#line 190 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'condition', 1, undef
	],
	[#Rule 57
		 'disjunction', 3,
sub
#line 197 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'disjunction', 1, undef
	],
	[#Rule 59
		 'conjunction', 3,
sub
#line 202 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'conjunction', 1, undef
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
		 'comparison', 3,
sub
#line 211 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'operator', 1, undef
	],
	[#Rule 71
		 'literal', 1, undef
	],
	[#Rule 72
		 'literal', 1, undef
	],
	[#Rule 73
		 'literal', 1, undef
	],
	[#Rule 74
		 'group_by_clause', 2,
sub
#line 229 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 75
		 'column_list', 3,
sub
#line 233 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 76
		 'column_list', 1, undef
	],
	[#Rule 77
		 'order_by_clause', 2,
sub
#line 238 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 78
		 'order_by_objects', 3,
sub
#line 242 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 79
		 'order_by_objects', 1, undef
	],
	[#Rule 80
		 'order_by_object', 2,
sub
#line 247 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 81
		 'order_by_object', 1, undef
	],
	[#Rule 82
		 'order_by_modifier', 1, undef
	],
	[#Rule 83
		 'order_by_modifier', 1, undef
	],
	[#Rule 84
		 'limit_clause', 2,
sub
#line 255 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 85
		 'offset_clause', 2,
sub
#line 259 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 262 "grammar/Select.yp"


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
