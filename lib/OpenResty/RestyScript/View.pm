####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package OpenResty::RestyScript::View;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 5 "grammar/restyscript-view.yp"


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
			'NUM' => 13,
			"(" => 23,
			"*" => 15,
			'VAR' => 25,
			"distinct" => 20,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'pattern' => 24,
			'expr' => 14,
			'atom' => 16,
			'pattern_list' => 26,
			'column' => 17
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
		DEFAULT => -112
	},
	{#State 9
		DEFAULT => -111
	},
	{#State 10
		ACTIONS => {
			"(" => 30
		},
		DEFAULT => -72
	},
	{#State 11
		DEFAULT => -69
	},
	{#State 12
		DEFAULT => -67
	},
	{#State 13
		DEFAULT => -64
	},
	{#State 14
		ACTIONS => {
			"-" => 31,
			"::" => 32,
			"+" => 33,
			"%" => 34,
			"^" => 35,
			"*" => 36,
			"||" => 37,
			"/" => 38,
			"as" => 39
		},
		DEFAULT => -22
	},
	{#State 15
		DEFAULT => -23
	},
	{#State 16
		DEFAULT => -33
	},
	{#State 17
		DEFAULT => -36
	},
	{#State 18
		ACTIONS => {
			"." => 40
		},
		DEFAULT => -70
	},
	{#State 19
		DEFAULT => -37
	},
	{#State 20
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			"*" => 15,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'pattern' => 24,
			'expr' => 14,
			'atom' => 16,
			'pattern_list' => 41,
			'column' => 17
		}
	},
	{#State 21
		DEFAULT => -35
	},
	{#State 22
		DEFAULT => -38
	},
	{#State 23
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 42,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 24
		ACTIONS => {
			"," => 43
		},
		DEFAULT => -20
	},
	{#State 25
		ACTIONS => {
			"|" => 44
		},
		DEFAULT => -74
	},
	{#State 26
		ACTIONS => {
			"where" => 56,
			"order by" => 48,
			"limit" => 47,
			"group by" => 51,
			"from" => 58,
			"offset" => 53
		},
		DEFAULT => -13,
		GOTOS => {
			'postfix_clause_list' => 57,
			'order_by_clause' => 46,
			'offset_clause' => 45,
			'where_clause' => 49,
			'group_by_clause' => 50,
			'from_clause' => 52,
			'limit_clause' => 54,
			'postfix_clause' => 55
		}
	},
	{#State 27
		DEFAULT => -2
	},
	{#State 28
		DEFAULT => 0
	},
	{#State 29
		ACTIONS => {
			"intersect" => 61,
			"union" => 59,
			"except" => 62,
			"union all" => 63
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 60
		}
	},
	{#State 30
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 68,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 64,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'parameter' => 74,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69,
			'parameter_list' => 70
		}
	},
	{#State 31
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 78,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 32
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 80,
			'type' => 82
		}
	},
	{#State 33
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 83,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 34
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 84,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 35
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 85,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 36
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 86,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 37
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 87,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 38
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'expr' => 88,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 39
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 89,
			'alias' => 90
		}
	},
	{#State 40
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 91
		}
	},
	{#State 41
		ACTIONS => {
			"where" => 56,
			"group by" => 51,
			"from" => 58,
			"order by" => 48,
			"limit" => 47,
			"offset" => 53
		},
		GOTOS => {
			'postfix_clause_list' => 92,
			'order_by_clause' => 46,
			'offset_clause' => 45,
			'where_clause' => 49,
			'group_by_clause' => 50,
			'from_clause' => 52,
			'limit_clause' => 54,
			'postfix_clause' => 55
		}
	},
	{#State 42
		ACTIONS => {
			"-" => 31,
			"::" => 32,
			"||" => 37,
			"+" => 33,
			"/" => 38,
			"%" => 34,
			"^" => 35,
			"*" => 36,
			")" => 93
		}
	},
	{#State 43
		ACTIONS => {
			'NUM' => 13,
			"(" => 23,
			"*" => 15,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'pattern' => 24,
			'expr' => 14,
			'atom' => 16,
			'pattern_list' => 94,
			'column' => 17
		}
	},
	{#State 44
		ACTIONS => {
			'NUM' => 97,
			'IDENT' => 95,
			'STRING' => 96
		}
	},
	{#State 45
		DEFAULT => -82
	},
	{#State 46
		DEFAULT => -80
	},
	{#State 47
		ACTIONS => {
			'NUM' => 98,
			'VAR' => 100,
			'STRING' => 12
		},
		GOTOS => {
			'literal' => 99,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'string' => 9
		}
	},
	{#State 48
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'order_by_objects' => 102,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 49
		DEFAULT => -78
	},
	{#State 50
		DEFAULT => -79
	},
	{#State 51
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 104,
			'column' => 105,
			'qualified_symbol' => 11
		}
	},
	{#State 52
		DEFAULT => -83
	},
	{#State 53
		ACTIONS => {
			'NUM' => 98,
			'VAR' => 100,
			'STRING' => 12
		},
		GOTOS => {
			'literal' => 106,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'string' => 9
		}
	},
	{#State 54
		DEFAULT => -81
	},
	{#State 55
		ACTIONS => {
			"where" => 56,
			"order by" => 48,
			"limit" => 47,
			"group by" => 51,
			"from" => 58,
			"offset" => 53
		},
		DEFAULT => -77,
		GOTOS => {
			'postfix_clause_list' => 107,
			'order_by_clause' => 46,
			'offset_clause' => 45,
			'where_clause' => 49,
			'group_by_clause' => 50,
			'from_clause' => 52,
			'limit_clause' => 54,
			'postfix_clause' => 55
		}
	},
	{#State 56
		ACTIONS => {
			'NUM' => 13,
			"(" => 113,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 108,
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 110,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'disjunction' => 111,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 112,
			'expr' => 109,
			'atom' => 16,
			'condition' => 114,
			'column' => 17
		}
	},
	{#State 57
		DEFAULT => -12
	},
	{#State 58
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 117,
			'symbol' => 118,
			'model_as' => 116,
			'model' => 115,
			'proc_call' => 119
		}
	},
	{#State 59
		DEFAULT => -8
	},
	{#State 60
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 120
		}
	},
	{#State 61
		DEFAULT => -9
	},
	{#State 62
		DEFAULT => -10
	},
	{#State 63
		DEFAULT => -7
	},
	{#State 64
		ACTIONS => {
			"-" => 121,
			"::" => 122,
			"||" => 127,
			"+" => 123,
			"/" => 128,
			"%" => 124,
			"^" => 125,
			"*" => 126
		},
		DEFAULT => -43
	},
	{#State 65
		DEFAULT => -114
	},
	{#State 66
		ACTIONS => {
			"(" => 129
		},
		DEFAULT => -72
	},
	{#State 67
		DEFAULT => -56
	},
	{#State 68
		ACTIONS => {
			")" => 130
		}
	},
	{#State 69
		DEFAULT => -55
	},
	{#State 70
		ACTIONS => {
			")" => 131
		}
	},
	{#State 71
		DEFAULT => -113
	},
	{#State 72
		DEFAULT => -53
	},
	{#State 73
		DEFAULT => -57
	},
	{#State 74
		ACTIONS => {
			"," => 132
		},
		DEFAULT => -42
	},
	{#State 75
		DEFAULT => -54
	},
	{#State 76
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 133,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 77
		ACTIONS => {
			"\@\@" => -74,
			"<" => -74,
			"like" => -74,
			">=" => -74,
			">>=" => -74,
			">>" => -74,
			"<>" => -74,
			"!=" => -74,
			"=" => -74,
			"<<=" => -74,
			"|" => 44,
			"<<" => -74,
			"<=" => -74,
			"." => -74,
			">" => -74
		},
		DEFAULT => -63
	},
	{#State 78
		ACTIONS => {
			"::" => 32,
			"%" => 34,
			"^" => 35,
			"*" => 36,
			"||" => 37,
			"/" => 38
		},
		DEFAULT => -29
	},
	{#State 79
		DEFAULT => -72
	},
	{#State 80
		DEFAULT => -34
	},
	{#State 81
		ACTIONS => {
			"|" => 134
		},
		DEFAULT => -74
	},
	{#State 82
		DEFAULT => -31
	},
	{#State 83
		ACTIONS => {
			"::" => 32,
			"%" => 34,
			"^" => 35,
			"*" => 36,
			"||" => 37,
			"/" => 38
		},
		DEFAULT => -28
	},
	{#State 84
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -27
	},
	{#State 85
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -30
	},
	{#State 86
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -25
	},
	{#State 87
		ACTIONS => {
			"::" => 32
		},
		DEFAULT => -24
	},
	{#State 88
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -26
	},
	{#State 89
		DEFAULT => -75
	},
	{#State 90
		DEFAULT => -21
	},
	{#State 91
		DEFAULT => -71
	},
	{#State 92
		DEFAULT => -11
	},
	{#State 93
		DEFAULT => -32
	},
	{#State 94
		DEFAULT => -19
	},
	{#State 95
		DEFAULT => -73
	},
	{#State 96
		DEFAULT => -68
	},
	{#State 97
		DEFAULT => -66
	},
	{#State 98
		DEFAULT => -65
	},
	{#State 99
		DEFAULT => -125
	},
	{#State 100
		ACTIONS => {
			"|" => 135
		},
		DEFAULT => -63
	},
	{#State 101
		ACTIONS => {
			"," => 136
		},
		DEFAULT => -120
	},
	{#State 102
		DEFAULT => -118
	},
	{#State 103
		ACTIONS => {
			"desc" => 137,
			"asc" => 138
		},
		DEFAULT => -122,
		GOTOS => {
			'order_by_modifier' => 139
		}
	},
	{#State 104
		DEFAULT => -115
	},
	{#State 105
		ACTIONS => {
			"," => 140
		},
		DEFAULT => -117
	},
	{#State 106
		DEFAULT => -126
	},
	{#State 107
		DEFAULT => -76
	},
	{#State 108
		DEFAULT => -91
	},
	{#State 109
		ACTIONS => {
			"-" => 31,
			"::" => 32,
			"+" => 33,
			"%" => 34,
			"^" => 35,
			"*" => 36,
			"||" => 37,
			"/" => 38
		},
		DEFAULT => -94
	},
	{#State 110
		ACTIONS => {
			"and" => 141
		},
		DEFAULT => -89
	},
	{#State 111
		ACTIONS => {
			"or" => 142
		},
		DEFAULT => -87
	},
	{#State 112
		ACTIONS => {
			"!=" => 151,
			"<" => 144,
			"\@\@" => 143,
			"like" => 145,
			"=" => 152,
			">=" => 146,
			"<<=" => 153,
			">>=" => 147,
			"<<" => 154,
			"<=" => 155,
			">" => 156,
			">>" => 149,
			"<>" => 150
		},
		GOTOS => {
			'operator' => 148
		}
	},
	{#State 113
		ACTIONS => {
			'NUM' => 13,
			"(" => 113,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 108,
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 110,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'disjunction' => 111,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 112,
			'expr' => 157,
			'atom' => 16,
			'condition' => 158,
			'column' => 17
		}
	},
	{#State 114
		DEFAULT => -86
	},
	{#State 115
		ACTIONS => {
			"as" => 159
		},
		DEFAULT => -17
	},
	{#State 116
		ACTIONS => {
			"," => 160
		},
		DEFAULT => -15
	},
	{#State 117
		DEFAULT => -84
	},
	{#State 118
		DEFAULT => -18
	},
	{#State 119
		DEFAULT => -85
	},
	{#State 120
		DEFAULT => -4
	},
	{#State 121
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 161,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 122
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 80,
			'type' => 162
		}
	},
	{#State 123
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 163,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 124
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 164,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 125
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 165,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 126
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 166,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 127
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 167,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 128
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 168,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 129
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 171,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 169,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 170,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 172,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 130
		DEFAULT => -40
	},
	{#State 131
		DEFAULT => -39
	},
	{#State 132
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 64,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'parameter' => 74,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69,
			'parameter_list' => 173
		}
	},
	{#State 133
		ACTIONS => {
			"-" => 121,
			"::" => 122,
			"||" => 127,
			"+" => 123,
			"/" => 128,
			"%" => 124,
			"^" => 125,
			"*" => 126,
			")" => 174
		}
	},
	{#State 134
		ACTIONS => {
			'IDENT' => 95
		}
	},
	{#State 135
		ACTIONS => {
			'NUM' => 97,
			'STRING' => 96
		}
	},
	{#State 136
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'order_by_objects' => 175,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 137
		DEFAULT => -124
	},
	{#State 138
		DEFAULT => -123
	},
	{#State 139
		DEFAULT => -121
	},
	{#State 140
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 176,
			'column' => 105,
			'qualified_symbol' => 11
		}
	},
	{#State 141
		ACTIONS => {
			'NUM' => 13,
			"(" => 113,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 108,
			'conjunction' => 177,
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 112,
			'expr' => 109,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 142
		ACTIONS => {
			'NUM' => 13,
			"(" => 113,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 108,
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 110,
			'number' => 8,
			'string' => 9,
			'disjunction' => 178,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 112,
			'expr' => 109,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 143
		DEFAULT => -106
	},
	{#State 144
		DEFAULT => -101
	},
	{#State 145
		DEFAULT => -105
	},
	{#State 146
		DEFAULT => -99
	},
	{#State 147
		DEFAULT => -109
	},
	{#State 148
		ACTIONS => {
			'NUM' => 13,
			"(" => 181,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 179,
			'symbol' => 18,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'rhs_atom' => 180,
			'column' => 69
		}
	},
	{#State 149
		DEFAULT => -110
	},
	{#State 150
		DEFAULT => -102
	},
	{#State 151
		DEFAULT => -103
	},
	{#State 152
		DEFAULT => -104
	},
	{#State 153
		DEFAULT => -107
	},
	{#State 154
		DEFAULT => -108
	},
	{#State 155
		DEFAULT => -100
	},
	{#State 156
		DEFAULT => -98
	},
	{#State 157
		ACTIONS => {
			"-" => 31,
			"::" => 32,
			"+" => 33,
			"%" => 34,
			"^" => 35,
			"*" => 36,
			")" => 93,
			"||" => 37,
			"/" => 38
		},
		DEFAULT => -94
	},
	{#State 158
		ACTIONS => {
			")" => 182
		}
	},
	{#State 159
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 183
		}
	},
	{#State 160
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'models' => 184,
			'symbol' => 118,
			'model_as' => 116,
			'model' => 115
		}
	},
	{#State 161
		ACTIONS => {
			"::" => 122,
			"%" => 124,
			"^" => 125,
			"*" => 126,
			"||" => 127,
			"/" => 128
		},
		DEFAULT => -49
	},
	{#State 162
		DEFAULT => -51
	},
	{#State 163
		ACTIONS => {
			"::" => 122,
			"%" => 124,
			"^" => 125,
			"*" => 126,
			"||" => 127,
			"/" => 128
		},
		DEFAULT => -48
	},
	{#State 164
		ACTIONS => {
			"::" => 122,
			"^" => 125,
			"||" => 127
		},
		DEFAULT => -47
	},
	{#State 165
		ACTIONS => {
			"::" => 122,
			"^" => 125,
			"||" => 127
		},
		DEFAULT => -50
	},
	{#State 166
		ACTIONS => {
			"::" => 122,
			"^" => 125,
			"||" => 127
		},
		DEFAULT => -45
	},
	{#State 167
		ACTIONS => {
			"::" => 122
		},
		DEFAULT => -44
	},
	{#State 168
		ACTIONS => {
			"::" => 122,
			"^" => 125,
			"||" => 127
		},
		DEFAULT => -46
	},
	{#State 169
		ACTIONS => {
			"-" => 121,
			"::" => 122,
			"||" => 127,
			"+" => 123,
			"/" => 128,
			"%" => 124,
			"^" => 125,
			"*" => 126
		},
		DEFAULT => -62
	},
	{#State 170
		ACTIONS => {
			"," => 185
		},
		DEFAULT => -61
	},
	{#State 171
		ACTIONS => {
			")" => 186
		}
	},
	{#State 172
		ACTIONS => {
			")" => 187
		}
	},
	{#State 173
		DEFAULT => -41
	},
	{#State 174
		DEFAULT => -52
	},
	{#State 175
		DEFAULT => -119
	},
	{#State 176
		DEFAULT => -116
	},
	{#State 177
		DEFAULT => -90
	},
	{#State 178
		DEFAULT => -88
	},
	{#State 179
		ACTIONS => {
			"-" => 121,
			"::" => 122,
			"+" => 123,
			"%" => 124,
			"^" => 125,
			"*" => 126,
			"||" => 127,
			"/" => 128
		},
		DEFAULT => -96
	},
	{#State 180
		DEFAULT => -92
	},
	{#State 181
		ACTIONS => {
			'NUM' => 13,
			"(" => 192,
			'VAR' => 77,
			'IDENT' => 188,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 133,
			'comparison' => 108,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 109,
			'atom' => 16,
			'column' => 189,
			'conjunction' => 110,
			'symbol' => 18,
			'true_literal' => 190,
			'atom2' => 72,
			'disjunction' => 111,
			'proc_call' => 21,
			'true_number' => 191,
			'proc_call2' => 75,
			'lhs_atom' => 112,
			'condition' => 193
		}
	},
	{#State 182
		ACTIONS => {
			'' => -93,
			"or" => -93,
			"order by" => -93,
			"limit" => -93,
			";" => -93,
			"group by" => -93,
			"offset" => -93,
			")" => -93,
			"where" => -93,
			"from" => -93,
			"and" => -93
		},
		DEFAULT => -95
	},
	{#State 183
		DEFAULT => -16
	},
	{#State 184
		DEFAULT => -14
	},
	{#State 185
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 169,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 170,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 194,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 186
		DEFAULT => -59
	},
	{#State 187
		DEFAULT => -58
	},
	{#State 188
		ACTIONS => {
			"(" => 195
		},
		DEFAULT => -72
	},
	{#State 189
		DEFAULT => -36
	},
	{#State 190
		DEFAULT => -37
	},
	{#State 191
		DEFAULT => -38
	},
	{#State 192
		ACTIONS => {
			'NUM' => 13,
			"(" => 192,
			'VAR' => 77,
			'IDENT' => 188,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 133,
			'comparison' => 108,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 157,
			'atom' => 16,
			'column' => 189,
			'conjunction' => 110,
			'symbol' => 18,
			'true_literal' => 190,
			'atom2' => 72,
			'disjunction' => 111,
			'proc_call' => 21,
			'true_number' => 191,
			'proc_call2' => 75,
			'lhs_atom' => 112,
			'condition' => 158
		}
	},
	{#State 193
		ACTIONS => {
			")" => 196
		}
	},
	{#State 194
		DEFAULT => -60
	},
	{#State 195
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 198,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 197,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 170,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 172,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'parameter' => 74,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'parameter_list' => 70,
			'column' => 69
		}
	},
	{#State 196
		DEFAULT => -97
	},
	{#State 197
		ACTIONS => {
			"-" => 121,
			"::" => 122,
			"||" => 127,
			"+" => 123,
			"/" => 128,
			"%" => 124,
			"^" => 125,
			"*" => 126
		},
		DEFAULT => -43
	},
	{#State 198
		ACTIONS => {
			")" => 199
		}
	},
	{#State 199
		DEFAULT => -40
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
#line 33 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 5
		 'compound_select_stmt', 3,
sub
#line 35 "grammar/restyscript-view.yp"
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
		 'select_stmt', 4,
sub
#line 43 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 12
		 'select_stmt', 3,
sub
#line 45 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 13
		 'select_stmt', 2,
sub
#line 47 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 14
		 'models', 3,
sub
#line 51 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 15
		 'models', 1, undef
	],
	[#Rule 16
		 'model_as', 3,
sub
#line 56 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'model_as', 1, undef
	],
	[#Rule 18
		 'model', 1,
sub
#line 60 "grammar/restyscript-view.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 19
		 'pattern_list', 3,
sub
#line 64 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 20
		 'pattern_list', 1, undef
	],
	[#Rule 21
		 'pattern', 3,
sub
#line 69 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 22
		 'pattern', 1, undef
	],
	[#Rule 23
		 'pattern', 1, undef
	],
	[#Rule 24
		 'expr', 3,
sub
#line 75 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'expr', 3,
sub
#line 77 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'expr', 3,
sub
#line 79 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 27
		 'expr', 3,
sub
#line 81 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'expr', 3,
sub
#line 83 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'expr', 3,
sub
#line 85 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'expr', 3,
sub
#line 87 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 31
		 'expr', 3,
sub
#line 89 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 32
		 'expr', 3,
sub
#line 91 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 33
		 'expr', 1, undef
	],
	[#Rule 34
		 'type', 1, undef
	],
	[#Rule 35
		 'atom', 1, undef
	],
	[#Rule 36
		 'atom', 1, undef
	],
	[#Rule 37
		 'atom', 1, undef
	],
	[#Rule 38
		 'atom', 1, undef
	],
	[#Rule 39
		 'proc_call', 4,
sub
#line 105 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 40
		 'proc_call', 4,
sub
#line 107 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 41
		 'parameter_list', 3,
sub
#line 111 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 42
		 'parameter_list', 1, undef
	],
	[#Rule 43
		 'parameter', 1, undef
	],
	[#Rule 44
		 'expr2', 3,
sub
#line 119 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 45
		 'expr2', 3,
sub
#line 121 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 46
		 'expr2', 3,
sub
#line 123 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'expr2', 3,
sub
#line 125 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'expr2', 3,
sub
#line 127 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'expr2', 3,
sub
#line 129 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'expr2', 3,
sub
#line 131 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'expr2', 3,
sub
#line 133 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'expr2', 3,
sub
#line 135 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'expr2', 1, undef
	],
	[#Rule 54
		 'atom2', 1, undef
	],
	[#Rule 55
		 'atom2', 1, undef
	],
	[#Rule 56
		 'atom2', 1, undef
	],
	[#Rule 57
		 'atom2', 1, undef
	],
	[#Rule 58
		 'proc_call2', 4,
sub
#line 146 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'proc_call2', 4,
sub
#line 148 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'parameter_list2', 3,
sub
#line 152 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'parameter_list2', 1, undef
	],
	[#Rule 62
		 'parameter2', 1, undef
	],
	[#Rule 63
		 'variable', 1,
sub
#line 161 "grammar/restyscript-view.yp"
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
	[#Rule 64
		 'true_number', 1, undef
	],
	[#Rule 65
		 'number', 1, undef
	],
	[#Rule 66
		 'number', 3,
sub
#line 177 "grammar/restyscript-view.yp"
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
	[#Rule 67
		 'string', 1,
sub
#line 189 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 68
		 'string', 3,
sub
#line 191 "grammar/restyscript-view.yp"
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
	[#Rule 69
		 'column', 1, undef
	],
	[#Rule 70
		 'column', 1,
sub
#line 203 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 71
		 'qualified_symbol', 3,
sub
#line 207 "grammar/restyscript-view.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 72
		 'symbol', 1, undef
	],
	[#Rule 73
		 'symbol', 3,
sub
#line 216 "grammar/restyscript-view.yp"
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
	[#Rule 74
		 'symbol', 1,
sub
#line 228 "grammar/restyscript-view.yp"
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
	[#Rule 75
		 'alias', 1, undef
	],
	[#Rule 76
		 'postfix_clause_list', 2,
sub
#line 244 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 77
		 'postfix_clause_list', 1, undef
	],
	[#Rule 78
		 'postfix_clause', 1, undef
	],
	[#Rule 79
		 'postfix_clause', 1, undef
	],
	[#Rule 80
		 'postfix_clause', 1, undef
	],
	[#Rule 81
		 'postfix_clause', 1, undef
	],
	[#Rule 82
		 'postfix_clause', 1, undef
	],
	[#Rule 83
		 'postfix_clause', 1, undef
	],
	[#Rule 84
		 'from_clause', 2,
sub
#line 257 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 85
		 'from_clause', 2,
sub
#line 259 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 86
		 'where_clause', 2,
sub
#line 263 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 87
		 'condition', 1, undef
	],
	[#Rule 88
		 'disjunction', 3,
sub
#line 270 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 89
		 'disjunction', 1, undef
	],
	[#Rule 90
		 'conjunction', 3,
sub
#line 275 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 91
		 'conjunction', 1, undef
	],
	[#Rule 92
		 'comparison', 3,
sub
#line 280 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 93
		 'comparison', 3,
sub
#line 282 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 94
		 'lhs_atom', 1, undef
	],
	[#Rule 95
		 'lhs_atom', 3, undef
	],
	[#Rule 96
		 'rhs_atom', 1, undef
	],
	[#Rule 97
		 'rhs_atom', 3, undef
	],
	[#Rule 98
		 'operator', 1, undef
	],
	[#Rule 99
		 'operator', 1, undef
	],
	[#Rule 100
		 'operator', 1, undef
	],
	[#Rule 101
		 'operator', 1, undef
	],
	[#Rule 102
		 'operator', 1, undef
	],
	[#Rule 103
		 'operator', 1, undef
	],
	[#Rule 104
		 'operator', 1, undef
	],
	[#Rule 105
		 'operator', 1, undef
	],
	[#Rule 106
		 'operator', 1, undef
	],
	[#Rule 107
		 'operator', 1, undef
	],
	[#Rule 108
		 'operator', 1, undef
	],
	[#Rule 109
		 'operator', 1, undef
	],
	[#Rule 110
		 'operator', 1, undef
	],
	[#Rule 111
		 'true_literal', 1, undef
	],
	[#Rule 112
		 'true_literal', 1, undef
	],
	[#Rule 113
		 'literal', 1, undef
	],
	[#Rule 114
		 'literal', 1, undef
	],
	[#Rule 115
		 'group_by_clause', 2,
sub
#line 319 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 116
		 'column_list', 3,
sub
#line 323 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 117
		 'column_list', 1, undef
	],
	[#Rule 118
		 'order_by_clause', 2,
sub
#line 328 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 119
		 'order_by_objects', 3,
sub
#line 332 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 120
		 'order_by_objects', 1, undef
	],
	[#Rule 121
		 'order_by_object', 2,
sub
#line 337 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 122
		 'order_by_object', 1, undef
	],
	[#Rule 123
		 'order_by_modifier', 1, undef
	],
	[#Rule 124
		 'order_by_modifier', 1, undef
	],
	[#Rule 125
		 'limit_clause', 2,
sub
#line 345 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 126
		 'offset_clause', 2,
sub
#line 349 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 352 "grammar/restyscript-view.yp"


#use Smart::Comments '####';

sub _Error {
    my ($value) = $_[0]->YYCurval;

    my $token = 1;
    ## $value
    my @expect = $_[0]->YYExpect;
    #### expect: @expect
    my ($what) = $value ? "input: \"$value\"" : "end of input";

    map { $_ = "'$_'" if $_ ne '' and !/^\w+$/ } @expect;
    my $expected = join " or ", @expect;
    my $yydata = $_[0]->YYData;
    #print substr($yydata->{input}, 0, 50);
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
        s/^\s*('(?:\\.|''|[^'])*')//s
                and return ('STRING', $1);
        s/^\s*[-+]?(\.\d+|\d+\.\d*|\d+)//s
                and return ('NUM', $1);
        s/^\s*"(\w*)"//s
                and return ('IDENT', $1);
        s/^\s*(\$(\w*)\$.*?\$\2\$)//s
                and return ('STRING', $1);
        if (s/^\s*(\*|as|select|distinct|and|or|from|where|delete|update|set|order\s+by|asc|desc|group\s+by|limit|offset|union\s+all|union|intersect|except)\b//is) {
            my $s = $1;
            (my $token = $s) =~ s/\s+/ /gs;
            return (lc($token), lc($s));
        }
        s/^\s*(<<=|<<|>>=|>>|<=|>=|<>|!=|\|\||::|like\b|\@\@)//s
                and return (lc($1), lc($1));
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
    $sql = $self->YYParse( yydebug => 0 & 0x1F, yylex => \&_Lexer, yyerror => \&_Error );
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
__END__

=head1 NAME

OpenResty::RestyScript::View - RestyScript (for Views) compiler in pure Perl

=head1 SYNOPSIS

    use OpenResty::RestyScript::View;

    my $restyscript = OpenResty::RestyScript::View->new;
    my $res = $restyscript->parse(
        'select * from Post where $col > $val',
        {
            quote => sub { $dbh->quote(@_) },
            quote_ident => sub { $dbh->quote_identifier(@_) },
        }
    );

=head1 DESCRIPTION

This compiler class is generated automatically by L<Parse::Yapp> from the grammar file F<grammar/restyscript-view.yp>.

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh at yahoo dot cn> >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty>.

=cut


1;
