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
			"as" => 28
		},
		DEFAULT => -19
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
			"," => 29
		},
		DEFAULT => -17
	},
	{#State 17
		DEFAULT => -22
	},
	{#State 18
		ACTIONS => {
			"|" => 30
		},
		DEFAULT => -44
	},
	{#State 19
		ACTIONS => {
			"where" => 31,
			"order by" => 36,
			"limit" => 35,
			"group by" => 39,
			"from" => 40,
			"offset" => 42
		},
		DEFAULT => -12,
		GOTOS => {
			'postfix_clause_list' => 34,
			'order_by_clause' => 33,
			'offset_clause' => 32,
			'from_clause' => 41,
			'where_clause' => 37,
			'group_by_clause' => 38,
			'limit_clause' => 43,
			'postfix_clause' => 44
		}
	},
	{#State 20
		ACTIONS => {
			"as" => 45
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
			"intersect" => 49,
			"union" => 46,
			"except" => 47,
			"union all" => 50
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 48
		}
	},
	{#State 24
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 51
		}
	},
	{#State 25
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 54,
			'alias' => 55
		}
	},
	{#State 26
		ACTIONS => {
			'NUM' => 15,
			"*" => 61,
			'VAR' => 62,
			'IDENT' => 52,
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
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 54,
			'alias' => 65
		}
	},
	{#State 28
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 54,
			'alias' => 66
		}
	},
	{#State 29
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
	{#State 30
		ACTIONS => {
			'NUM' => 70,
			'IDENT' => 68,
			'STRING' => 69
		}
	},
	{#State 31
		ACTIONS => {
			"(" => 75,
			'VAR' => 53,
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
	{#State 32
		DEFAULT => -52
	},
	{#State 33
		DEFAULT => -50
	},
	{#State 34
		DEFAULT => -11
	},
	{#State 35
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
	{#State 36
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 8,
			'order_by_objects' => 83,
			'column' => 84,
			'qualified_symbol' => 13,
			'order_by_object' => 82
		}
	},
	{#State 37
		DEFAULT => -48
	},
	{#State 38
		DEFAULT => -49
	},
	{#State 39
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 8,
			'column_list' => 85,
			'column' => 86,
			'qualified_symbol' => 13
		}
	},
	{#State 40
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 87,
			'symbol' => 88,
			'model' => 89,
			'proc_call' => 90
		}
	},
	{#State 41
		DEFAULT => -53
	},
	{#State 42
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
	{#State 43
		DEFAULT => -51
	},
	{#State 44
		ACTIONS => {
			"where" => 31,
			"order by" => 36,
			"limit" => 35,
			"group by" => 39,
			"from" => 40,
			"offset" => 42
		},
		DEFAULT => -47,
		GOTOS => {
			'postfix_clause_list' => 92,
			'order_by_clause' => 33,
			'offset_clause' => 32,
			'from_clause' => 41,
			'where_clause' => 37,
			'group_by_clause' => 38,
			'limit_clause' => 43,
			'postfix_clause' => 44
		}
	},
	{#State 45
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 54,
			'alias' => 93
		}
	},
	{#State 46
		DEFAULT => -8
	},
	{#State 47
		DEFAULT => -10
	},
	{#State 52
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 94
		}
	},
	{#State 53
		DEFAULT => -9
	},
	{#State 54
		DEFAULT => -7
	},
	{#State 55
		DEFAULT => -41
	},
	{#State 56
		DEFAULT => -42
	},
	{#State 57
		ACTIONS => {
			"|" => 95
		},
		DEFAULT => -44
	},
	{#State 58
		DEFAULT => -45
	},
	{#State 59
		DEFAULT => -23
	},
	{#State 60
		DEFAULT => -79
	},
	{#State 61
		DEFAULT => -31
	},
	{#State 62
		DEFAULT => -78
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
		DEFAULT => -30
	},
	{#State 60
		ACTIONS => {
			"," => 96
		},
		DEFAULT => -29
	},
	{#State 67
		DEFAULT => -68
	},
	{#State 68
		DEFAULT => -33
	},
	{#State 62
		ACTIONS => {
			"|" => 30,
			"." => -44
		},
		DEFAULT => -34
	},
	{#State 63
		DEFAULT => -32
	},
	{#State 70
		ACTIONS => {
			")" => 97
		}
	},
	{#State 71
		DEFAULT => -25
	},
	{#State 72
		DEFAULT => -18
	},
	{#State 67
		DEFAULT => -16
	},
	{#State 74
		DEFAULT => -43
	},
	{#State 75
		DEFAULT => -38
	},
	{#State 76
		DEFAULT => -36
	},
	{#State 77
		DEFAULT => -14
	},
	{#State 78
		ACTIONS => {
			"and" => 98
		},
		DEFAULT => -61
	},
	{#State 79
		ACTIONS => {
			"or" => 99
		},
		DEFAULT => -59
	},
	{#State 73
		DEFAULT => -66
	},
	{#State 81
		DEFAULT => -57
	},
	{#State 82
		ACTIONS => {
			"(" => 75,
			'VAR' => 53,
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
			'condition' => 100,
			'column' => 77
		}
	},
	{#State 83
		ACTIONS => {
			"<" => 101,
			"like" => 102,
			"<=" => 106,
			">" => 108,
			"<>" => 107,
			">=" => 104,
			"=" => 103
		},
		GOTOS => {
			'operator' => 105
		}
	},
	{#State 84
		DEFAULT => -64
	},
	{#State 85
		DEFAULT => -56
	},
	{#State 86
		DEFAULT => -80
	},
	{#State 87
		DEFAULT => -91
	},
	{#State 88
		ACTIONS => {
			"|" => 109
		},
		DEFAULT => -34
	},
	{#State 89
		ACTIONS => {
			"," => 110
		},
		DEFAULT => -86
	},
	{#State 90
		DEFAULT => -84
	},
	{#State 91
		ACTIONS => {
			"desc" => 111,
			"asc" => 112
		},
		DEFAULT => -88,
		GOTOS => {
			'order_by_modifier' => 113
		}
	},
	{#State 85
		DEFAULT => -81
	},
	{#State 86
		ACTIONS => {
			"," => 114
		},
		DEFAULT => -83
	},
	{#State 98
		DEFAULT => -18
	},
	{#State 99
		DEFAULT => -54
	},
	{#State 88
		DEFAULT => -15
	},
	{#State 89
		ACTIONS => {
			"," => 115
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
	{#State 104
		DEFAULT => -4
	},
	{#State 105
		ACTIONS => {
			'IDENT' => 68
		}
	},
	{#State 96
		ACTIONS => {
			'NUM' => 15,
			"*" => 61,
			'VAR' => 62,
			'IDENT' => 52,
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
			'parameter_list' => 116,
			'column' => 63
		}
	},
	{#State 97
		DEFAULT => -27
	},
	{#State 98
		ACTIONS => {
			"(" => 75,
			'VAR' => 53,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 117,
			'lhs_atom' => 76,
			'symbol' => 8,
			'proc_call' => 73,
			'column' => 77,
			'qualified_symbol' => 13
		}
	},
	{#State 107
		ACTIONS => {
			"(" => 75,
			'VAR' => 53,
			'IDENT' => 10
		},
		GOTOS => {
			'comparison' => 71,
			'lhs_atom' => 76,
			'conjunction' => 118,
			'symbol' => 8,
			'proc_call' => 73,
			'column' => 77,
			'qualified_symbol' => 13
		}
	},
	{#State 108
		ACTIONS => {
			")" => 119
		}
	},
	{#State 101
		DEFAULT => -74
	},
	{#State 110
		DEFAULT => -69
	},
	{#State 111
		DEFAULT => -77
	},
	{#State 112
		DEFAULT => -76
	},
	{#State 104
		DEFAULT => -72
	},
	{#State 105
		ACTIONS => {
			'NUM' => 15,
			"(" => 122,
			'VAR' => 62,
			'IDENT' => 10,
			'STRING' => 14
		},
		GOTOS => {
			'symbol' => 8,
			'number' => 56,
			'variable' => 79,
			'string' => 58,
			'proc_call' => 120,
			'qualified_symbol' => 13,
			'literal' => 121,
			'rhs_atom' => 123,
			'column' => 124
		}
	},
	{#State 106
		DEFAULT => -73
	},
	{#State 107
		DEFAULT => -75
	},
	{#State 108
		DEFAULT => -71
	},
	{#State 109
		ACTIONS => {
			'NUM' => 70,
			'STRING' => 69
		}
	},
	{#State 110
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 8,
			'order_by_objects' => 125,
			'column' => 84,
			'qualified_symbol' => 13,
			'order_by_object' => 82
		}
	},
	{#State 111
		DEFAULT => -90
	},
	{#State 112
		DEFAULT => -89
	},
	{#State 113
		DEFAULT => -87
	},
	{#State 114
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'symbol' => 8,
			'column_list' => 126,
			'column' => 86,
			'qualified_symbol' => 13
		}
	},
	{#State 115
		ACTIONS => {
			'VAR' => 53,
			'IDENT' => 52
		},
		GOTOS => {
			'models' => 127,
			'symbol' => 88,
			'model' => 89
		}
	},
	{#State 116
		DEFAULT => -28
	},
	{#State 117
		DEFAULT => -60
	},
	{#State 118
		DEFAULT => -58
	},
	{#State 119
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
	{#State 120
		DEFAULT => -70
	},
	{#State 121
		DEFAULT => -68
	},
	{#State 122
		ACTIONS => {
			"(" => 75,
			'VAR' => 53,
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
			'condition' => 128,
			'column' => 77
		}
	},
	{#State 123
		DEFAULT => -62
	},
	{#State 124
		DEFAULT => -67
	},
	{#State 125
		DEFAULT => -85
	},
	{#State 126
		DEFAULT => -82
	},
	{#State 127
		DEFAULT => -13
	},
	{#State 128
		ACTIONS => {
			")" => 129
		}
	},
	{#State 129
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
	[#Rule 18
		 'pattern_list', 1, undef
	],
	[#Rule 18
		 'pattern', 3,
sub
#line 57 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 19
		 'pattern', 1, undef
	],
	[#Rule 20
		 'pattern', 3,
sub
#line 60 "grammar/Select.yp"
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
#line 64 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'pattern', 1, undef
	],
	[#Rule 25
		 'pattern', 3,
sub
#line 67 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'pattern', 1, undef
	],
	[#Rule 27
		 'proc_call', 4,
sub
#line 72 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'parameter_list', 3,
sub
#line 76 "grammar/Select.yp"
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
#line 87 "grammar/Select.yp"
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
#line 100 "grammar/Select.yp"
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
#line 112 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 38
		 'string', 3,
sub
#line 114 "grammar/Select.yp"
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
#line 126 "grammar/Select.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 41
		 'qualified_symbol', 3,
sub
#line 130 "grammar/Select.yp"
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
#line 139 "grammar/Select.yp"
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
#line 151 "grammar/Select.yp"
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
#line 167 "grammar/Select.yp"
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
#line 180 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'from_clause', 2,
sub
#line 182 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'where_clause', 2,
sub
#line 186 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'condition', 1, undef
	],
	[#Rule 58
		 'disjunction', 3,
sub
#line 193 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'disjunction', 1, undef
	],
	[#Rule 60
		 'conjunction', 3,
sub
#line 198 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'conjunction', 1, undef
	],
	[#Rule 62
		 'comparison', 3,
sub
#line 203 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'comparison', 3,
sub
#line 205 "grammar/Select.yp"
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
		 'literal', 1, undef
	],
	[#Rule 68
		 'group_by_clause', 2,
sub
#line 234 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 82
		 'column_list', 3,
sub
#line 238 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 83
		 'column_list', 1, undef
	],
	[#Rule 84
		 'order_by_clause', 2,
sub
#line 243 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 85
		 'order_by_objects', 3,
sub
#line 247 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 86
		 'order_by_objects', 1, undef
	],
	[#Rule 87
		 'order_by_object', 2,
sub
#line 252 "grammar/Select.yp"
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
#line 260 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 92
		 'offset_clause', 2,
sub
#line 264 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 267 "grammar/Select.yp"


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
