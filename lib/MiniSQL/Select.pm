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
			'NUM' => 15,
			"*" => 17,
			'VAR' => 18,
			'IDENT' => 10,
			'STRING' => 14
		},
		GOTOS => {
			'symbol' => 8,
			'number' => 9,
			'string' => 11,
			'proc_call' => 12,
			'qualified_symbol' => 13,
			'pattern' => 16,
			'pattern_list' => 19,
			'column' => 20
		}
	},
	{#State 5
		ACTIONS => {
			";" => 21
		},
		DEFAULT => -3
	},
	{#State 6
		ACTIONS => {
			'' => 22
		}
	},
	{#State 7
		ACTIONS => {
			")" => 23
		}
	},
	{#State 8
		ACTIONS => {
			"." => 24
		},
		DEFAULT => -40
	},
	{#State 9
		ACTIONS => {
			"as" => 25
		},
		DEFAULT => -24
	},
	{#State 10
		ACTIONS => {
			"(" => 26
		},
		DEFAULT => -42
	},
	{#State 11
		ACTIONS => {
			"as" => 27
		},
		DEFAULT => -26
	},
	{#State 12
		ACTIONS => {
			'IDENT' => 29,
			'VAR' => 30
		},
		DEFAULT => -19,
		GOTOS => {
			'symbol' => 28,
			'alias' => 31
		}
	},
	{#State 13
		DEFAULT => -39
	},
	{#State 14
		DEFAULT => -37
	},
	{#State 15
		DEFAULT => -35
	},
	{#State 16
		ACTIONS => {
			"," => 32
		},
		DEFAULT => -17
	},
	{#State 17
		DEFAULT => -22
	},
	{#State 18
		ACTIONS => {
			"|" => 33
		},
		DEFAULT => -44
	},
	{#State 19
		ACTIONS => {
			"where" => 34,
			"order by" => 39,
			"limit" => 38,
			"group by" => 42,
			"from" => 43,
			"offset" => 45
		},
		DEFAULT => -12,
		GOTOS => {
			'postfix_clause_list' => 37,
			'order_by_clause' => 36,
			'offset_clause' => 35,
			'from_clause' => 44,
			'where_clause' => 40,
			'group_by_clause' => 41,
			'limit_clause' => 46,
			'postfix_clause' => 47
		}
	},
	{#State 20
		ACTIONS => {
			"as" => 48
		},
		DEFAULT => -21
	},
	{#State 21
		DEFAULT => -2
	},
	{#State 22
		DEFAULT => 0
	},
	{#State 23
		ACTIONS => {
			"intersect" => 52,
			"union" => 49,
			"except" => 50,
			"union all" => 53
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 51
		}
	},
	{#State 24
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 54
		}
	},
	{#State 25
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 28,
			'alias' => 55
		}
	},
	{#State 26
		ACTIONS => {
			'NUM' => 15,
			"*" => 61,
			'VAR' => 62,
			'IDENT' => 29,
			'STRING' => 14
		},
		GOTOS => {
			'symbol' => 8,
			'variable' => 57,
			'number' => 56,
			'string' => 58,
			'qualified_symbol' => 13,
			'literal' => 59,
			'parameter' => 60,
			'parameter_list' => 64,
			'column' => 63
		}
	},
	{#State 27
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 28,
			'alias' => 65
		}
	},
	{#State 28
		DEFAULT => -45
	},
	{#State 29
		DEFAULT => -42
	},
	{#State 30
		ACTIONS => {
			"|" => 66
		},
		DEFAULT => -44
	},
	{#State 31
		DEFAULT => -18
	},
	{#State 32
		ACTIONS => {
			'NUM' => 15,
			"*" => 17,
			'VAR' => 18,
			'IDENT' => 10,
			'STRING' => 14
		},
		GOTOS => {
			'symbol' => 8,
			'number' => 9,
			'string' => 11,
			'proc_call' => 12,
			'qualified_symbol' => 13,
			'pattern' => 16,
			'pattern_list' => 67,
			'column' => 20
		}
	},
	{#State 33
		ACTIONS => {
			'NUM' => 70,
			'IDENT' => 68,
			'STRING' => 69
		}
	},
	{#State 34
		ACTIONS => {
			"(" => 75,
			'VAR' => 30,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 71,
			'symbol' => 8,
			'conjunction' => 72,
			'disjunction' => 74,
			'proc_call' => 73,
			'qualified_symbol' => 13,
			'lhs_atom' => 76,
			'condition' => 78,
			'column' => 77
		}
	},
	{#State 35
		DEFAULT => -52
	},
	{#State 36
		DEFAULT => -50
	},
	{#State 37
		DEFAULT => -11
	},
	{#State 38
		ACTIONS => {
			'NUM' => 15,
			'VAR' => 81,
			'STRING' => 14
		},
		GOTOS => {
			'literal' => 80,
			'number' => 56,
			'variable' => 79,
			'string' => 58
		}
	},
	{#State 39
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 8,
			'order_by_objects' => 83,
			'column' => 84,
			'qualified_symbol' => 13,
			'order_by_object' => 82
		}
	},
	{#State 40
		DEFAULT => -48
	},
	{#State 41
		DEFAULT => -49
	},
	{#State 42
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 8,
			'column_list' => 85,
			'column' => 86,
			'qualified_symbol' => 13
		}
	},
	{#State 43
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 87,
			'symbol' => 88,
			'model' => 89,
			'proc_call' => 90
		}
	},
	{#State 44
		DEFAULT => -53
	},
	{#State 45
		ACTIONS => {
			'NUM' => 15,
			'VAR' => 81,
			'STRING' => 14
		},
		GOTOS => {
			'literal' => 91,
			'number' => 56,
			'variable' => 79,
			'string' => 58
		}
	},
	{#State 46
		DEFAULT => -51
	},
	{#State 47
		ACTIONS => {
			"where" => 34,
			"order by" => 39,
			"limit" => 38,
			"group by" => 42,
			"from" => 43,
			"offset" => 45
		},
		DEFAULT => -47,
		GOTOS => {
			'postfix_clause_list' => 92,
			'order_by_clause' => 36,
			'offset_clause' => 35,
			'from_clause' => 44,
			'where_clause' => 40,
			'group_by_clause' => 41,
			'limit_clause' => 46,
			'postfix_clause' => 47
		}
	},
	{#State 48
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 28,
			'alias' => 93
		}
	},
	{#State 49
		DEFAULT => -8
	},
	{#State 50
		DEFAULT => -10
	},
	{#State 51
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 94
		}
	},
	{#State 52
		DEFAULT => -9
	},
	{#State 53
		DEFAULT => -7
	},
	{#State 54
		DEFAULT => -41
	},
	{#State 55
		DEFAULT => -23
	},
	{#State 56
		DEFAULT => -79
	},
	{#State 57
		DEFAULT => -31
	},
	{#State 58
		DEFAULT => -78
	},
	{#State 59
		DEFAULT => -30
	},
	{#State 60
		ACTIONS => {
			"," => 95
		},
		DEFAULT => -29
	},
	{#State 61
		DEFAULT => -33
	},
	{#State 62
		ACTIONS => {
			"|" => 33,
			"." => -44
		},
		DEFAULT => -34
	},
	{#State 63
		DEFAULT => -32
	},
	{#State 64
		ACTIONS => {
			")" => 96
		}
	},
	{#State 65
		DEFAULT => -25
	},
	{#State 66
		ACTIONS => {
			'IDENT' => 68
		}
	},
	{#State 67
		DEFAULT => -16
	},
	{#State 68
		DEFAULT => -43
	},
	{#State 69
		DEFAULT => -38
	},
	{#State 70
		DEFAULT => -36
	},
	{#State 71
		ACTIONS => {
			"and" => 97
		},
		DEFAULT => -61
	},
	{#State 72
		ACTIONS => {
			"or" => 98
		},
		DEFAULT => -59
	},
	{#State 73
		DEFAULT => -66
	},
	{#State 74
		DEFAULT => -57
	},
	{#State 75
		ACTIONS => {
			"(" => 75,
			'VAR' => 30,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 71,
			'symbol' => 8,
			'conjunction' => 72,
			'disjunction' => 74,
			'proc_call' => 73,
			'qualified_symbol' => 13,
			'lhs_atom' => 76,
			'condition' => 99,
			'column' => 77
		}
	},
	{#State 76
		ACTIONS => {
			"<" => 100,
			"like" => 101,
			"<=" => 105,
			">" => 107,
			"<>" => 106,
			">=" => 103,
			"=" => 102
		},
		GOTOS => {
			'operator' => 104
		}
	},
	{#State 77
		DEFAULT => -64
	},
	{#State 78
		DEFAULT => -56
	},
	{#State 79
		DEFAULT => -80
	},
	{#State 80
		DEFAULT => -91
	},
	{#State 81
		ACTIONS => {
			"|" => 108
		},
		DEFAULT => -34
	},
	{#State 82
		ACTIONS => {
			"," => 109
		},
		DEFAULT => -86
	},
	{#State 83
		DEFAULT => -84
	},
	{#State 84
		ACTIONS => {
			"desc" => 110,
			"asc" => 111
		},
		DEFAULT => -88,
		GOTOS => {
			'order_by_modifier' => 112
		}
	},
	{#State 85
		DEFAULT => -81
	},
	{#State 86
		ACTIONS => {
			"," => 113
		},
		DEFAULT => -83
	},
	{#State 87
		DEFAULT => -54
	},
	{#State 88
		DEFAULT => -15
	},
	{#State 89
		ACTIONS => {
			"," => 114
		},
		DEFAULT => -14
	},
	{#State 90
		DEFAULT => -55
	},
	{#State 91
		DEFAULT => -92
	},
	{#State 92
		DEFAULT => -46
	},
	{#State 93
		DEFAULT => -20
	},
	{#State 94
		DEFAULT => -4
	},
	{#State 95
		ACTIONS => {
			'NUM' => 15,
			"*" => 61,
			'VAR' => 62,
			'IDENT' => 29,
			'STRING' => 14
		},
		GOTOS => {
			'symbol' => 8,
			'variable' => 57,
			'number' => 56,
			'string' => 58,
			'qualified_symbol' => 13,
			'literal' => 59,
			'parameter' => 60,
			'parameter_list' => 115,
			'column' => 63
		}
	},
	{#State 96
		DEFAULT => -27
	},
	{#State 97
		ACTIONS => {
			"(" => 75,
			'VAR' => 30,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 116,
			'lhs_atom' => 76,
			'symbol' => 8,
			'proc_call' => 73,
			'column' => 77,
			'qualified_symbol' => 13
		}
	},
	{#State 98
		ACTIONS => {
			"(" => 75,
			'VAR' => 30,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 71,
			'lhs_atom' => 76,
			'conjunction' => 117,
			'symbol' => 8,
			'proc_call' => 73,
			'column' => 77,
			'qualified_symbol' => 13
		}
	},
	{#State 99
		ACTIONS => {
			")" => 118
		}
	},
	{#State 100
		DEFAULT => -74
	},
	{#State 101
		DEFAULT => -77
	},
	{#State 102
		DEFAULT => -76
	},
	{#State 103
		DEFAULT => -72
	},
	{#State 104
		ACTIONS => {
			'NUM' => 15,
			"(" => 121,
			'VAR' => 62,
			'IDENT' => 10,
			'STRING' => 14
		},
		GOTOS => {
			'symbol' => 8,
			'number' => 56,
			'variable' => 79,
			'string' => 58,
			'proc_call' => 119,
			'qualified_symbol' => 13,
			'literal' => 120,
			'rhs_atom' => 122,
			'column' => 123
		}
	},
	{#State 105
		DEFAULT => -73
	},
	{#State 106
		DEFAULT => -75
	},
	{#State 107
		DEFAULT => -71
	},
	{#State 108
		ACTIONS => {
			'NUM' => 70,
			'STRING' => 69
		}
	},
	{#State 109
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 8,
			'order_by_objects' => 124,
			'column' => 84,
			'qualified_symbol' => 13,
			'order_by_object' => 82
		}
	},
	{#State 110
		DEFAULT => -90
	},
	{#State 111
		DEFAULT => -89
	},
	{#State 112
		DEFAULT => -87
	},
	{#State 113
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'symbol' => 8,
			'column_list' => 125,
			'column' => 86,
			'qualified_symbol' => 13
		}
	},
	{#State 114
		ACTIONS => {
			'VAR' => 30,
			'IDENT' => 29
		},
		GOTOS => {
			'models' => 126,
			'symbol' => 88,
			'model' => 89
		}
	},
	{#State 115
		DEFAULT => -28
	},
	{#State 116
		DEFAULT => -60
	},
	{#State 117
		DEFAULT => -58
	},
	{#State 118
		ACTIONS => {
			"<" => -65,
			"like" => -65,
			">=" => -65,
			"<>" => -65,
			"=" => -65,
			"<=" => -65,
			">" => -65
		},
		DEFAULT => -63
	},
	{#State 119
		DEFAULT => -70
	},
	{#State 120
		DEFAULT => -68
	},
	{#State 121
		ACTIONS => {
			"(" => 75,
			'VAR' => 30,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 71,
			'symbol' => 8,
			'conjunction' => 72,
			'disjunction' => 74,
			'proc_call' => 73,
			'qualified_symbol' => 13,
			'lhs_atom' => 76,
			'condition' => 127,
			'column' => 77
		}
	},
	{#State 122
		DEFAULT => -62
	},
	{#State 123
		DEFAULT => -67
	},
	{#State 124
		DEFAULT => -85
	},
	{#State 125
		DEFAULT => -82
	},
	{#State 126
		DEFAULT => -13
	},
	{#State 127
		ACTIONS => {
			")" => 128
		}
	},
	{#State 128
		DEFAULT => -69
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
		 'pattern', 2, undef
	],
	[#Rule 19
		 'pattern', 1, undef
	],
	[#Rule 20
		 'pattern', 3,
sub
#line 59 "grammar/Select.yp"
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
#line 63 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'pattern', 1, undef
	],
	[#Rule 25
		 'pattern', 3,
sub
#line 66 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'pattern', 1, undef
	],
	[#Rule 27
		 'proc_call', 4,
sub
#line 71 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'parameter_list', 3,
sub
#line 75 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'parameter_list', 1, undef
	],
	[#Rule 30
		 'parameter', 1, undef
	],
	[#Rule 31
		 'parameter', 1, undef
	],
	[#Rule 32
		 'parameter', 1, undef
	],
	[#Rule 33
		 'parameter', 1, undef
	],
	[#Rule 34
		 'variable', 1,
sub
#line 86 "grammar/Select.yp"
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
	[#Rule 35
		 'number', 1, undef
	],
	[#Rule 36
		 'number', 3,
sub
#line 99 "grammar/Select.yp"
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
	[#Rule 37
		 'string', 1,
sub
#line 111 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 38
		 'string', 3,
sub
#line 113 "grammar/Select.yp"
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
	[#Rule 39
		 'column', 1, undef
	],
	[#Rule 40
		 'column', 1,
sub
#line 125 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 41
		 'qualified_symbol', 3,
sub
#line 129 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 42
		 'symbol', 1, undef
	],
	[#Rule 43
		 'symbol', 3,
sub
#line 138 "grammar/Select.yp"
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
	[#Rule 44
		 'symbol', 1,
sub
#line 150 "grammar/Select.yp"
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
	[#Rule 45
		 'alias', 1, undef
	],
	[#Rule 46
		 'postfix_clause_list', 2,
sub
#line 166 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'postfix_clause_list', 1, undef
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
		 'postfix_clause', 1, undef
	],
	[#Rule 54
		 'from_clause', 2,
sub
#line 179 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'from_clause', 2,
sub
#line 181 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'where_clause', 2,
sub
#line 185 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'condition', 1, undef
	],
	[#Rule 58
		 'disjunction', 3,
sub
#line 192 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'disjunction', 1, undef
	],
	[#Rule 60
		 'conjunction', 3,
sub
#line 197 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'conjunction', 1, undef
	],
	[#Rule 62
		 'comparison', 3,
sub
#line 202 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'comparison', 3,
sub
#line 204 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 64
		 'lhs_atom', 1, undef
	],
	[#Rule 65
		 'lhs_atom', 3, undef
	],
	[#Rule 66
		 'lhs_atom', 1, undef
	],
	[#Rule 67
		 'rhs_atom', 1, undef
	],
	[#Rule 68
		 'rhs_atom', 1, undef
	],
	[#Rule 69
		 'rhs_atom', 3, undef
	],
	[#Rule 70
		 'rhs_atom', 1, undef
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
		 'operator', 1, undef
	],
	[#Rule 77
		 'operator', 1, undef
	],
	[#Rule 78
		 'literal', 1, undef
	],
	[#Rule 79
		 'literal', 1, undef
	],
	[#Rule 80
		 'literal', 1, undef
	],
	[#Rule 81
		 'group_by_clause', 2,
sub
#line 233 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 82
		 'column_list', 3,
sub
#line 237 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 83
		 'column_list', 1, undef
	],
	[#Rule 84
		 'order_by_clause', 2,
sub
#line 242 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 85
		 'order_by_objects', 3,
sub
#line 246 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 86
		 'order_by_objects', 1, undef
	],
	[#Rule 87
		 'order_by_object', 2,
sub
#line 251 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 88
		 'order_by_object', 1, undef
	],
	[#Rule 89
		 'order_by_modifier', 1, undef
	],
	[#Rule 90
		 'order_by_modifier', 1, undef
	],
	[#Rule 91
		 'limit_clause', 2,
sub
#line 259 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 92
		 'offset_clause', 2,
sub
#line 263 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 266 "grammar/Select.yp"


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
        if (s/^\s*(\*|as|select|and|or|from|where|delete|update|set|order\s+by|asc|desc|group\s+by|limit|offset|union\s+all|union|intersect|except)\b//is) {
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
