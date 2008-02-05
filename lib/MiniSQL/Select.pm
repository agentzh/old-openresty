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
		DEFAULT => -29
	},
	{#State 9
		ACTIONS => {
			"as" => 30
		},
		DEFAULT => -24
	},
	{#State 10
		ACTIONS => {
			"(" => 31
		},
		DEFAULT => -45
	},
	{#State 11
		ACTIONS => {
			"as" => 32
		},
		DEFAULT => -26
	},
	{#State 12
		DEFAULT => -42
	},
	{#State 13
		DEFAULT => -40
	},
	{#State 14
		DEFAULT => -38
	},
	{#State 15
		DEFAULT => -22
	},
	{#State 16
		DEFAULT => -31
	},
	{#State 17
		ACTIONS => {
			'IDENT' => 33,
			'VAR' => 35
		},
		DEFAULT => -18,
		GOTOS => {
			'symbol' => 34,
			'alias' => 36
		}
	},
	{#State 18
		ACTIONS => {
			"as" => 37
		},
		DEFAULT => -21
	},
	{#State 19
		ACTIONS => {
			"." => 38
		},
		DEFAULT => -43
	},
	{#State 20
		DEFAULT => -19
	},
	{#State 21
		DEFAULT => -32
	},
	{#State 22
		ACTIONS => {
			"," => 39
		},
		DEFAULT => -16
	},
	{#State 23
		ACTIONS => {
			"|" => 40
		},
		DEFAULT => -47
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
		DEFAULT => -11,
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
		DEFAULT => -30
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
			"except" => 59
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
			'alias' => 60
		}
	},
	{#State 31
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 67,
			'STRING' => 13
		},
		GOTOS => {
			'parameter' => 66,
			'literal' => 64,
			'number' => 62,
			'variable' => 61,
			'string' => 63,
			'parameter_list' => 65
		}
	},
	{#State 32
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 34,
			'alias' => 68
		}
	},
	{#State 33
		DEFAULT => -45
	},
	{#State 34
		DEFAULT => -48
	},
	{#State 35
		ACTIONS => {
			"|" => 69
		},
		DEFAULT => -47
	},
	{#State 36
		DEFAULT => -17
	},
	{#State 37
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 34,
			'alias' => 70
		}
	},
	{#State 38
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 71
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
			'pattern_list' => 72,
			'func' => 25,
			'aggregate' => 17,
			'column' => 18
		}
	},
	{#State 40
		ACTIONS => {
			'NUM' => 75,
			'IDENT' => 73,
			'STRING' => 74
		}
	},
	{#State 41
		DEFAULT => -55
	},
	{#State 42
		DEFAULT => -53
	},
	{#State 43
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 67,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 76,
			'number' => 62,
			'variable' => 61,
			'string' => 63
		}
	},
	{#State 44
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'order_by_objects' => 78,
			'column' => 79,
			'qualified_symbol' => 12,
			'order_by_object' => 77
		}
	},
	{#State 45
		DEFAULT => -51
	},
	{#State 46
		DEFAULT => -52
	},
	{#State 47
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 80,
			'column' => 81,
			'qualified_symbol' => 12
		}
	},
	{#State 48
		DEFAULT => -56
	},
	{#State 49
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 67,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 82,
			'number' => 62,
			'variable' => 61,
			'string' => 63
		}
	},
	{#State 50
		DEFAULT => -54
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
		DEFAULT => -50,
		GOTOS => {
			'postfix_clause_list' => 83,
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
			"(" => 88,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 84,
			'symbol' => 19,
			'conjunction' => 86,
			'disjunction' => 87,
			'condition' => 89,
			'column' => 85,
			'qualified_symbol' => 12
		}
	},
	{#State 53
		DEFAULT => -10
	},
	{#State 54
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 91,
			'symbol' => 92,
			'model' => 90,
			'proc_call' => 93
		}
	},
	{#State 55
		ACTIONS => {
			"*" => 94,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'column' => 95,
			'qualified_symbol' => 12
		}
	},
	{#State 56
		DEFAULT => -7
	},
	{#State 57
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 96
		}
	},
	{#State 58
		DEFAULT => -8
	},
	{#State 59
		DEFAULT => -9
	},
	{#State 60
		DEFAULT => -23
	},
	{#State 61
		DEFAULT => -77
	},
	{#State 62
		DEFAULT => -76
	},
	{#State 63
		DEFAULT => -75
	},
	{#State 64
		DEFAULT => -36
	},
	{#State 65
		ACTIONS => {
			")" => 97
		}
	},
	{#State 66
		ACTIONS => {
			"," => 98
		},
		DEFAULT => -35
	},
	{#State 67
		ACTIONS => {
			"|" => 99
		},
		DEFAULT => -37
	},
	{#State 68
		DEFAULT => -25
	},
	{#State 69
		ACTIONS => {
			'IDENT' => 73
		}
	},
	{#State 70
		DEFAULT => -20
	},
	{#State 71
		DEFAULT => -44
	},
	{#State 72
		DEFAULT => -15
	},
	{#State 73
		DEFAULT => -46
	},
	{#State 74
		DEFAULT => -41
	},
	{#State 75
		DEFAULT => -39
	},
	{#State 76
		DEFAULT => -88
	},
	{#State 77
		ACTIONS => {
			"," => 100
		},
		DEFAULT => -83
	},
	{#State 78
		DEFAULT => -81
	},
	{#State 79
		ACTIONS => {
			"desc" => 101,
			"asc" => 102
		},
		DEFAULT => -85,
		GOTOS => {
			'order_by_modifier' => 103
		}
	},
	{#State 80
		DEFAULT => -78
	},
	{#State 81
		ACTIONS => {
			"," => 104
		},
		DEFAULT => -80
	},
	{#State 82
		DEFAULT => -89
	},
	{#State 83
		DEFAULT => -49
	},
	{#State 84
		ACTIONS => {
			"and" => 105
		},
		DEFAULT => -64
	},
	{#State 85
		ACTIONS => {
			"<" => 106,
			"like" => 107,
			"<=" => 112,
			">" => 113,
			"=" => 111,
			"<>" => 110,
			">=" => 108
		},
		GOTOS => {
			'operator' => 109
		}
	},
	{#State 86
		ACTIONS => {
			"or" => 114
		},
		DEFAULT => -62
	},
	{#State 87
		DEFAULT => -60
	},
	{#State 88
		ACTIONS => {
			"(" => 88,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 84,
			'symbol' => 19,
			'conjunction' => 86,
			'disjunction' => 87,
			'condition' => 115,
			'column' => 85,
			'qualified_symbol' => 12
		}
	},
	{#State 89
		DEFAULT => -59
	},
	{#State 90
		ACTIONS => {
			"," => 116
		},
		DEFAULT => -13
	},
	{#State 91
		DEFAULT => -57
	},
	{#State 92
		DEFAULT => -14
	},
	{#State 93
		DEFAULT => -58
	},
	{#State 94
		ACTIONS => {
			")" => 117
		}
	},
	{#State 95
		ACTIONS => {
			")" => 118
		}
	},
	{#State 96
		DEFAULT => -4
	},
	{#State 97
		DEFAULT => -33
	},
	{#State 98
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 67,
			'STRING' => 13
		},
		GOTOS => {
			'parameter' => 66,
			'literal' => 64,
			'number' => 62,
			'variable' => 61,
			'string' => 63,
			'parameter_list' => 119
		}
	},
	{#State 99
		ACTIONS => {
			'NUM' => 75,
			'STRING' => 74
		}
	},
	{#State 100
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'order_by_objects' => 120,
			'column' => 79,
			'qualified_symbol' => 12,
			'order_by_object' => 77
		}
	},
	{#State 101
		DEFAULT => -87
	},
	{#State 102
		DEFAULT => -86
	},
	{#State 103
		DEFAULT => -84
	},
	{#State 104
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 121,
			'column' => 81,
			'qualified_symbol' => 12
		}
	},
	{#State 105
		ACTIONS => {
			"(" => 88,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 122,
			'symbol' => 19,
			'column' => 85,
			'qualified_symbol' => 12
		}
	},
	{#State 106
		DEFAULT => -71
	},
	{#State 107
		DEFAULT => -74
	},
	{#State 108
		DEFAULT => -69
	},
	{#State 109
		ACTIONS => {
			'NUM' => 14,
			'VAR' => 125,
			'IDENT' => 33,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 123,
			'symbol' => 19,
			'number' => 62,
			'variable' => 61,
			'string' => 63,
			'column' => 124,
			'qualified_symbol' => 12
		}
	},
	{#State 110
		DEFAULT => -72
	},
	{#State 111
		DEFAULT => -73
	},
	{#State 112
		DEFAULT => -70
	},
	{#State 113
		DEFAULT => -68
	},
	{#State 114
		ACTIONS => {
			"(" => 88,
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'comparison' => 84,
			'conjunction' => 126,
			'symbol' => 19,
			'column' => 85,
			'qualified_symbol' => 12
		}
	},
	{#State 115
		ACTIONS => {
			")" => 127
		}
	},
	{#State 116
		ACTIONS => {
			'VAR' => 35,
			'IDENT' => 33
		},
		GOTOS => {
			'models' => 128,
			'symbol' => 92,
			'model' => 90
		}
	},
	{#State 117
		DEFAULT => -28
	},
	{#State 118
		DEFAULT => -27
	},
	{#State 119
		DEFAULT => -34
	},
	{#State 120
		DEFAULT => -82
	},
	{#State 121
		DEFAULT => -79
	},
	{#State 122
		DEFAULT => -63
	},
	{#State 123
		DEFAULT => -65
	},
	{#State 124
		DEFAULT => -66
	},
	{#State 125
		ACTIONS => {
			"|" => 40,
			"." => -47
		},
		DEFAULT => -37
	},
	{#State 126
		DEFAULT => -61
	},
	{#State 127
		DEFAULT => -67
	},
	{#State 128
		DEFAULT => -12
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
		 'pattern', 3,
sub
#line 65 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'pattern', 1, undef
	],
	[#Rule 25
		 'pattern', 3,
sub
#line 68 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'pattern', 1, undef
	],
	[#Rule 27
		 'aggregate', 4,
sub
#line 74 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'aggregate', 4,
sub
#line 76 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'func', 1, undef
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
		 'proc_call', 4,
sub
#line 86 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 34
		 'parameter_list', 3,
sub
#line 90 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 35
		 'parameter_list', 1, undef
	],
	[#Rule 36
		 'parameter', 1, undef
	],
	[#Rule 37
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
	[#Rule 38
		 'number', 1, undef
	],
	[#Rule 39
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
	[#Rule 40
		 'string', 1,
sub
#line 123 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 41
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
	[#Rule 42
		 'column', 1, undef
	],
	[#Rule 43
		 'column', 1,
sub
#line 137 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 44
		 'qualified_symbol', 3,
sub
#line 141 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 45
		 'symbol', 1, undef
	],
	[#Rule 46
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
	[#Rule 47
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
	[#Rule 48
		 'alias', 1, undef
	],
	[#Rule 49
		 'postfix_clause_list', 2,
sub
#line 178 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'postfix_clause_list', 1, undef
	],
	[#Rule 51
		 'postfix_clause', 1, undef
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
		 'from_clause', 2,
sub
#line 191 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'from_clause', 2,
sub
#line 193 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'where_clause', 2,
sub
#line 197 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'condition', 1, undef
	],
	[#Rule 61
		 'disjunction', 3,
sub
#line 204 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'disjunction', 1, undef
	],
	[#Rule 63
		 'conjunction', 3,
sub
#line 209 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 64
		 'conjunction', 1, undef
	],
	[#Rule 65
		 'comparison', 3,
sub
#line 214 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 66
		 'comparison', 3,
sub
#line 216 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 67
		 'comparison', 3,
sub
#line 218 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'literal', 1, undef
	],
	[#Rule 76
		 'literal', 1, undef
	],
	[#Rule 77
		 'literal', 1, undef
	],
	[#Rule 78
		 'group_by_clause', 2,
sub
#line 236 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 79
		 'column_list', 3,
sub
#line 240 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 80
		 'column_list', 1, undef
	],
	[#Rule 81
		 'order_by_clause', 2,
sub
#line 245 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 82
		 'order_by_objects', 3,
sub
#line 249 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 83
		 'order_by_objects', 1, undef
	],
	[#Rule 84
		 'order_by_object', 2,
sub
#line 254 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 85
		 'order_by_object', 1, undef
	],
	[#Rule 86
		 'order_by_modifier', 1, undef
	],
	[#Rule 87
		 'order_by_modifier', 1, undef
	],
	[#Rule 88
		 'limit_clause', 2,
sub
#line 262 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 89
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
