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
			"max" => 8,
			'IDENT' => 10,
			'STRING' => 13,
			'NUM' => 14,
			"sum" => 21,
			"*" => 15,
			'VAR' => 23,
			"count" => 16,
			"min" => 26
		},
		GOTOS => {
			'symbol' => 19,
			'number' => 9,
			'string' => 11,
			'proc_call' => 20,
			'qualified_symbol' => 12,
			'pattern' => 22,
			'func' => 25,
			'pattern_list' => 24,
			'aggregate' => 17,
			'column' => 18
		}
	},
	{#State 5
		ACTIONS => {
			";" => 27
		},
		DEFAULT => -3
	},
	{#State 6
		ACTIONS => {
			'' => 28
		}
	},
	{#State 7
		ACTIONS => {
			")" => 29
		}
	},
	{#State 8
		DEFAULT => -30
	},
	{#State 9
		ACTIONS => {
			"as" => 30
		},
		DEFAULT => -25
	},
	{#State 10
		ACTIONS => {
			"(" => 31
		},
		DEFAULT => -46
	},
	{#State 11
		ACTIONS => {
			"as" => 32
		},
		DEFAULT => -27
	},
	{#State 12
		DEFAULT => -43
	},
	{#State 13
		DEFAULT => -41
	},
	{#State 14
		DEFAULT => -39
	},
	{#State 15
		DEFAULT => -23
	},
	{#State 16
		DEFAULT => -32
	},
	{#State 17
		ACTIONS => {
			'IDENT' => 33,
			'VAR' => 35
		},
		DEFAULT => -19,
		GOTOS => {
			'symbol' => 34,
			'alias' => 36
		}
	},
	{#State 18
		ACTIONS => {
			"as" => 37
		},
		DEFAULT => -22
	},
	{#State 19
		ACTIONS => {
			"." => 38
		},
		DEFAULT => -44
	},
	{#State 20
		DEFAULT => -20
	},
	{#State 21
		DEFAULT => -33
	},
	{#State 22
		ACTIONS => {
			"," => 39
		},
		DEFAULT => -17
	},
	{#State 23
		ACTIONS => {
			"|" => 40
		},
		DEFAULT => -48
	},
	{#State 24
		ACTIONS => {
			"where" => 52,
			"order by" => 44,
			"limit" => 43,
			"group by" => 47,
			"from" => 54,
			"offset" => 49
		},
		DEFAULT => -12,
		GOTOS => {
			'postfix_clause_list' => 53,
			'order_by_clause' => 42,
			'offset_clause' => 41,
			'where_clause' => 45,
			'group_by_clause' => 46,
			'from_clause' => 48,
			'limit_clause' => 50,
			'postfix_clause' => 51
		}
	},
	{#State 25
		ACTIONS => {
			"(" => 55
		}
	},
	{#State 26
		DEFAULT => -31
	},
	{#State 27
		DEFAULT => -2
	},
	{#State 28
		DEFAULT => 0
	},
	{#State 29
		ACTIONS => {
			"intersect" => 58,
			"union" => 56,
			"except" => 59,
			"union all" => 60
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 57
		}
	},
	{#State 30
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 34,
			'alias' => 61
		}
	},
	{#State 31
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'parameter' => 67,
			'literal' => 65,
			'number' => 63,
			'variable' => 62,
			'string' => 64,
			'parameter_list' => 66
		}
	},
	{#State 32
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 34,
			'alias' => 69
		}
	},
	{#State 33
		DEFAULT => -46
	},
	{#State 34
		DEFAULT => -49
	},
	{#State 35
		ACTIONS => {
			"|" => 70
		},
		DEFAULT => -48
	},
	{#State 36
		DEFAULT => -18
	},
	{#State 37
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 34,
			'alias' => 71
		}
	},
	{#State 38
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 72
		}
	},
	{#State 39
		ACTIONS => {
			"max" => 8,
			'IDENT' => 10,
			'STRING' => 13,
			'NUM' => 14,
			"sum" => 21,
			"*" => 15,
			'VAR' => 23,
			"count" => 16,
			"min" => 26
		},
		GOTOS => {
			'symbol' => 19,
			'number' => 9,
			'string' => 11,
			'proc_call' => 20,
			'qualified_symbol' => 12,
			'pattern' => 22,
			'pattern_list' => 73,
			'func' => 25,
			'aggregate' => 17,
			'column' => 18
		}
	},
	{#State 40
		ACTIONS => {
			'NUM' => 76,
			'IDENT' => 74,
			'STRING' => 75
		}
	},
	{#State 41
		DEFAULT => -56
	},
	{#State 42
		DEFAULT => -54
	},
	{#State 43
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 77,
			'number' => 63,
			'variable' => 62,
			'string' => 64
		}
	},
	{#State 44
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'order_by_objects' => 79,
			'column' => 80,
			'qualified_symbol' => 12,
			'order_by_object' => 78
		}
	},
	{#State 45
		DEFAULT => -52
	},
	{#State 46
		DEFAULT => -53
	},
	{#State 47
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 81,
			'column' => 82,
			'qualified_symbol' => 12
		}
	},
	{#State 48
		DEFAULT => -57
	},
	{#State 49
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 83,
			'number' => 63,
			'variable' => 62,
			'string' => 64
		}
	},
	{#State 50
		DEFAULT => -55
	},
	{#State 51
		ACTIONS => {
			"where" => 52,
			"order by" => 44,
			"limit" => 43,
			"group by" => 47,
			"from" => 54,
			"offset" => 49
		},
		DEFAULT => -51,
		GOTOS => {
			'postfix_clause_list' => 84,
			'order_by_clause' => 42,
			'offset_clause' => 41,
			'where_clause' => 45,
			'group_by_clause' => 46,
			'from_clause' => 48,
			'limit_clause' => 50,
			'postfix_clause' => 51
		}
	},
	{#State 52
		ACTIONS => {
			"(" => 89,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 85,
			'symbol' => 19,
			'conjunction' => 87,
			'disjunction' => 88,
			'condition' => 90,
			'column' => 86,
			'qualified_symbol' => 12
		}
	},
	{#State 53
		DEFAULT => -11
	},
	{#State 54
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 92,
			'symbol' => 93,
			'model' => 91,
			'proc_call' => 94
		}
	},
	{#State 55
		ACTIONS => {
			"*" => 95,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'column' => 96,
			'qualified_symbol' => 12
		}
	},
	{#State 56
		DEFAULT => -8
	},
	{#State 57
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 97
		}
	},
	{#State 58
		DEFAULT => -9
	},
	{#State 59
		DEFAULT => -10
	},
	{#State 60
		DEFAULT => -7
	},
	{#State 61
		DEFAULT => -24
	},
	{#State 62
		DEFAULT => -78
	},
	{#State 63
		DEFAULT => -77
	},
	{#State 64
		DEFAULT => -76
	},
	{#State 65
		DEFAULT => -37
	},
	{#State 66
		ACTIONS => {
			")" => 98
		}
	},
	{#State 67
		ACTIONS => {
			"," => 99
		},
		DEFAULT => -36
	},
	{#State 68
		ACTIONS => {
			"|" => 100
		},
		DEFAULT => -38
	},
	{#State 69
		DEFAULT => -26
	},
	{#State 70
		ACTIONS => {
			'IDENT' => 74
		}
	},
	{#State 71
		DEFAULT => -21
	},
	{#State 72
		DEFAULT => -45
	},
	{#State 73
		DEFAULT => -16
	},
	{#State 74
		DEFAULT => -47
	},
	{#State 75
		DEFAULT => -42
	},
	{#State 76
		DEFAULT => -40
	},
	{#State 77
		DEFAULT => -89
	},
	{#State 78
		ACTIONS => {
			"," => 101
		},
		DEFAULT => -84
	},
	{#State 79
		DEFAULT => -82
	},
	{#State 80
		ACTIONS => {
			"desc" => 102,
			"asc" => 103
		},
		DEFAULT => -86,
		GOTOS => {
			'order_by_modifier' => 104
		}
	},
	{#State 81
		DEFAULT => -79
	},
	{#State 82
		ACTIONS => {
			"," => 105
		},
		DEFAULT => -81
	},
	{#State 83
		DEFAULT => -90
	},
	{#State 84
		DEFAULT => -50
	},
	{#State 85
		ACTIONS => {
			"and" => 106
		},
		DEFAULT => -65
	},
	{#State 86
		ACTIONS => {
			"<" => 107,
			"like" => 108,
			"<=" => 113,
			">" => 114,
			"=" => 112,
			"<>" => 111,
			">=" => 109
		},
		GOTOS => {
			'operator' => 110
		}
	},
	{#State 87
		ACTIONS => {
			"or" => 115
		},
		DEFAULT => -63
	},
	{#State 88
		DEFAULT => -61
	},
	{#State 89
		ACTIONS => {
			"(" => 89,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 85,
			'symbol' => 19,
			'conjunction' => 87,
			'disjunction' => 88,
			'condition' => 116,
			'column' => 86,
			'qualified_symbol' => 12
		}
	},
	{#State 90
		DEFAULT => -60
	},
	{#State 91
		ACTIONS => {
			"," => 117
		},
		DEFAULT => -14
	},
	{#State 92
		DEFAULT => -58
	},
	{#State 93
		DEFAULT => -15
	},
	{#State 94
		DEFAULT => -59
	},
	{#State 95
		ACTIONS => {
			")" => 118
		}
	},
	{#State 96
		ACTIONS => {
			")" => 119
		}
	},
	{#State 97
		DEFAULT => -4
	},
	{#State 98
		DEFAULT => -34
	},
	{#State 99
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'parameter' => 67,
			'literal' => 65,
			'number' => 63,
			'variable' => 62,
			'string' => 64,
			'parameter_list' => 120
		}
	},
	{#State 100
		ACTIONS => {
			'NUM' => 76,
			'STRING' => 75
		}
	},
	{#State 101
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'order_by_objects' => 121,
			'column' => 80,
			'qualified_symbol' => 12,
			'order_by_object' => 78
		}
	},
	{#State 102
		DEFAULT => -88
	},
	{#State 103
		DEFAULT => -87
	},
	{#State 104
		DEFAULT => -85
	},
	{#State 105
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 122,
			'column' => 82,
			'qualified_symbol' => 12
		}
	},
	{#State 106
		ACTIONS => {
			"(" => 89,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 123,
			'symbol' => 19,
			'column' => 86,
			'qualified_symbol' => 12
		}
	},
	{#State 107
		DEFAULT => -72
	},
	{#State 108
		DEFAULT => -75
	},
	{#State 109
		DEFAULT => -70
	},
	{#State 110
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 126,
			'IDENT' => 33,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 124,
			'symbol' => 19,
			'number' => 63,
			'variable' => 62,
			'string' => 64,
			'column' => 125,
			'qualified_symbol' => 12
		}
	},
	{#State 111
		DEFAULT => -73
	},
	{#State 112
		DEFAULT => -74
	},
	{#State 113
		DEFAULT => -71
	},
	{#State 114
		DEFAULT => -69
	},
	{#State 115
		ACTIONS => {
			"(" => 89,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 85,
			'conjunction' => 127,
			'symbol' => 19,
			'column' => 86,
			'qualified_symbol' => 12
		}
	},
	{#State 116
		ACTIONS => {
			")" => 128
		}
	},
	{#State 117
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'models' => 129,
			'symbol' => 93,
			'model' => 91
		}
	},
	{#State 118
		DEFAULT => -29
	},
	{#State 119
		DEFAULT => -28
	},
	{#State 120
		DEFAULT => -35
	},
	{#State 121
		DEFAULT => -83
	},
	{#State 122
		DEFAULT => -80
	},
	{#State 123
		DEFAULT => -64
	},
	{#State 124
		DEFAULT => -66
	},
	{#State 125
		DEFAULT => -67
	},
	{#State 126
		ACTIONS => {
			"|" => 40,
			"." => -48
		},
		DEFAULT => -38
	},
	{#State 127
		DEFAULT => -62
	},
	{#State 128
		DEFAULT => -68
	},
	{#State 129
		DEFAULT => -13
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
		 'set_operator', 1, undef
	],
	[#Rule 11
		 'select_stmt', 3,
sub
#line 38 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 12
		 'select_stmt', 2,
sub
#line 40 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 13
		 'models', 3,
sub
#line 44 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 14
		 'models', 1, undef
	],
	[#Rule 15
		 'model', 1,
sub
#line 48 "grammar/Select.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 16
		 'pattern_list', 3,
sub
#line 52 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'pattern_list', 1, undef
	],
	[#Rule 18
		 'pattern', 2,
sub
#line 57 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 19
		 'pattern', 1, undef
	],
	[#Rule 20
		 'pattern', 1, undef
	],
	[#Rule 21
		 'pattern', 3,
sub
#line 61 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 22
		 'pattern', 1, undef
	],
	[#Rule 23
		 'pattern', 1, undef
	],
	[#Rule 24
		 'pattern', 3,
sub
#line 65 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'pattern', 1, undef
	],
	[#Rule 26
		 'pattern', 3,
sub
#line 68 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 27
		 'pattern', 1, undef
	],
	[#Rule 28
		 'aggregate', 4,
sub
#line 74 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'aggregate', 4,
sub
#line 76 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'func', 1, undef
	],
	[#Rule 31
		 'func', 1, undef
	],
	[#Rule 32
		 'func', 1, undef
	],
	[#Rule 33
		 'func', 1, undef
	],
	[#Rule 34
		 'proc_call', 4,
sub
#line 86 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 35
		 'parameter_list', 3,
sub
#line 90 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 36
		 'parameter_list', 1, undef
	],
	[#Rule 37
		 'parameter', 1, undef
	],
	[#Rule 38
		 'variable', 1,
sub
#line 98 "grammar/Select.yp"
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
	[#Rule 39
		 'number', 1, undef
	],
	[#Rule 40
		 'number', 3,
sub
#line 111 "grammar/Select.yp"
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
	[#Rule 41
		 'string', 1,
sub
#line 123 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 42
		 'string', 3,
sub
#line 125 "grammar/Select.yp"
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
	[#Rule 43
		 'column', 1, undef
	],
	[#Rule 44
		 'column', 1,
sub
#line 137 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 45
		 'qualified_symbol', 3,
sub
#line 141 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 46
		 'symbol', 1, undef
	],
	[#Rule 47
		 'symbol', 3,
sub
#line 150 "grammar/Select.yp"
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
	[#Rule 48
		 'symbol', 1,
sub
#line 162 "grammar/Select.yp"
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
	[#Rule 49
		 'alias', 1, undef
	],
	[#Rule 50
		 'postfix_clause_list', 2,
sub
#line 178 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'postfix_clause_list', 1, undef
	],
	[#Rule 52
		 'postfix_clause', 1, undef
	],
	[#Rule 53
		 'postfix_clause', 1, undef
	],
	[#Rule 54
		 'postfix_clause', 1, undef
	],
	[#Rule 55
		 'postfix_clause', 1, undef
	],
	[#Rule 56
		 'postfix_clause', 1, undef
	],
	[#Rule 57
		 'postfix_clause', 1, undef
	],
	[#Rule 58
		 'from_clause', 2,
sub
#line 191 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'from_clause', 2,
sub
#line 193 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'where_clause', 2,
sub
#line 197 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'condition', 1, undef
	],
	[#Rule 62
		 'disjunction', 3,
sub
#line 204 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'disjunction', 1, undef
	],
	[#Rule 64
		 'conjunction', 3,
sub
#line 209 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 65
		 'conjunction', 1, undef
	],
	[#Rule 66
		 'comparison', 3,
sub
#line 214 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 67
		 'comparison', 3,
sub
#line 216 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 68
		 'comparison', 3,
sub
#line 218 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 69
		 'operator', 1, undef
	],
	[#Rule 70
		 'operator', 1, undef
	],
	[#Rule 71
		 'operator', 1, undef
	],
	[#Rule 72
		 'operator', 1, undef
	],
	[#Rule 73
		 'operator', 1, undef
	],
	[#Rule 74
		 'operator', 1, undef
	],
	[#Rule 75
		 'operator', 1, undef
	],
	[#Rule 76
		 'literal', 1, undef
	],
	[#Rule 77
		 'literal', 1, undef
	],
	[#Rule 78
		 'literal', 1, undef
	],
	[#Rule 79
		 'group_by_clause', 2,
sub
#line 236 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 80
		 'column_list', 3,
sub
#line 240 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 81
		 'column_list', 1, undef
	],
	[#Rule 82
		 'order_by_clause', 2,
sub
#line 245 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 83
		 'order_by_objects', 3,
sub
#line 249 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 84
		 'order_by_objects', 1, undef
	],
	[#Rule 85
		 'order_by_object', 2,
sub
#line 254 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 86
		 'order_by_object', 1, undef
	],
	[#Rule 87
		 'order_by_modifier', 1, undef
	],
	[#Rule 88
		 'order_by_modifier', 1, undef
	],
	[#Rule 89
		 'limit_clause', 2,
sub
#line 262 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 90
		 'offset_clause', 2,
sub
#line 266 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 269 "grammar/Select.yp"


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
        if (s/^\s*(\*|as|count|sum|max|min|select|and|or|from|where|delete|update|set|order\s+by|asc|desc|group\s+by|limit|offset|union\s+all|union|intersect|except)\b//is) {
            my $s = $1;
            (my $token = $s) =~ s/\s+/ /g;
            return (lc($token), lc($s));
        }
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
