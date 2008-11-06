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
			'NUM' => 14,
			"(" => 24,
			"*" => 16,
			'VAR' => 26,
			"distinct" => 21,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'pattern' => 25,
			'expr' => 15,
			'atom' => 17,
			'pattern_list' => 27,
			'column' => 18
		}
	},
	{#State 5
		ACTIONS => {
			";" => 28
		},
		DEFAULT => -3
	},
	{#State 6
		ACTIONS => {
			'' => 29
		}
	},
	{#State 7
		ACTIONS => {
			")" => 30
		}
	},
	{#State 8
		DEFAULT => -134
	},
	{#State 9
		DEFAULT => -43
	},
	{#State 10
		DEFAULT => -133
	},
	{#State 11
		ACTIONS => {
			"(" => 31
		},
		DEFAULT => -86
	},
	{#State 12
		DEFAULT => -83
	},
	{#State 13
		DEFAULT => -81
	},
	{#State 14
		DEFAULT => -78
	},
	{#State 15
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"+" => 34,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"||" => 38,
			"/" => 39,
			"as" => 40
		},
		DEFAULT => -29
	},
	{#State 16
		DEFAULT => -30
	},
	{#State 17
		DEFAULT => -40
	},
	{#State 18
		ACTIONS => {
			"[" => 41
		},
		DEFAULT => -44
	},
	{#State 19
		ACTIONS => {
			"." => 42
		},
		DEFAULT => -84
	},
	{#State 20
		DEFAULT => -45
	},
	{#State 21
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			"*" => 16,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'pattern' => 25,
			'expr' => 15,
			'atom' => 17,
			'pattern_list' => 43,
			'column' => 18
		}
	},
	{#State 22
		DEFAULT => -42
	},
	{#State 23
		DEFAULT => -46
	},
	{#State 24
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 44,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 25
		ACTIONS => {
			"," => 45
		},
		DEFAULT => -27
	},
	{#State 26
		ACTIONS => {
			"|" => 46
		},
		DEFAULT => -88
	},
	{#State 27
		ACTIONS => {
			"where" => 58,
			"order by" => 50,
			"limit" => 49,
			"group by" => 53,
			"from" => 60,
			"offset" => 55
		},
		DEFAULT => -13,
		GOTOS => {
			'postfix_clause_list' => 59,
			'order_by_clause' => 48,
			'offset_clause' => 47,
			'where_clause' => 51,
			'group_by_clause' => 52,
			'from_clause' => 54,
			'limit_clause' => 56,
			'postfix_clause' => 57
		}
	},
	{#State 28
		DEFAULT => -2
	},
	{#State 29
		DEFAULT => 0
	},
	{#State 30
		ACTIONS => {
			"intersect" => 63,
			"union" => 61,
			"except" => 64,
			"union all" => 65
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 62
		}
	},
	{#State 31
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			"*" => 70,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 66,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 77,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71,
			'parameter_list' => 72
		}
	},
	{#State 32
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 81,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 33
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 83,
			'type' => 85
		}
	},
	{#State 34
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 86,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 35
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 87,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 36
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 88,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 37
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 89,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 38
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 90,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 39
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 91,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 40
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 92,
			'alias' => 93
		}
	},
	{#State 41
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 94,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 42
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 95
		}
	},
	{#State 43
		ACTIONS => {
			"where" => 58,
			"group by" => 53,
			"from" => 60,
			"order by" => 50,
			"limit" => 49,
			"offset" => 55
		},
		GOTOS => {
			'postfix_clause_list' => 96,
			'order_by_clause' => 48,
			'offset_clause' => 47,
			'where_clause' => 51,
			'group_by_clause' => 52,
			'from_clause' => 54,
			'limit_clause' => 56,
			'postfix_clause' => 57
		}
	},
	{#State 44
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			")" => 97
		}
	},
	{#State 45
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			"*" => 16,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'pattern' => 25,
			'expr' => 15,
			'atom' => 17,
			'pattern_list' => 98,
			'column' => 18
		}
	},
	{#State 46
		ACTIONS => {
			'NUM' => 101,
			'IDENT' => 99,
			'STRING' => 100
		}
	},
	{#State 47
		DEFAULT => -96
	},
	{#State 48
		DEFAULT => -94
	},
	{#State 49
		ACTIONS => {
			'NUM' => 102,
			'VAR' => 104,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 103,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'string' => 10
		}
	},
	{#State 50
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 68
		},
		GOTOS => {
			'proc_call2' => 108,
			'symbol' => 19,
			'order_by_atom' => 109,
			'order_by_objects' => 106,
			'column' => 107,
			'qualified_symbol' => 12,
			'order_by_object' => 105
		}
	},
	{#State 51
		DEFAULT => -92
	},
	{#State 52
		DEFAULT => -93
	},
	{#State 53
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 110,
			'column' => 111,
			'qualified_symbol' => 12
		}
	},
	{#State 54
		DEFAULT => -97
	},
	{#State 55
		ACTIONS => {
			'NUM' => 102,
			'VAR' => 104,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 112,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'string' => 10
		}
	},
	{#State 56
		DEFAULT => -95
	},
	{#State 57
		ACTIONS => {
			"where" => 58,
			"order by" => 50,
			"limit" => 49,
			"group by" => 53,
			"from" => 60,
			"offset" => 55
		},
		DEFAULT => -91,
		GOTOS => {
			'postfix_clause_list' => 113,
			'order_by_clause' => 48,
			'offset_clause' => 47,
			'where_clause' => 51,
			'group_by_clause' => 52,
			'from_clause' => 54,
			'limit_clause' => 56,
			'postfix_clause' => 57
		}
	},
	{#State 58
		ACTIONS => {
			'NUM' => 14,
			"(" => 119,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 114,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'qualified_symbol' => 12,
			'expr' => 115,
			'atom' => 17,
			'column' => 18,
			'conjunction' => 116,
			'symbol' => 19,
			'true_literal' => 20,
			'disjunction' => 117,
			'proc_call' => 22,
			'true_number' => 23,
			'lhs_atom' => 118,
			'condition' => 120
		}
	},
	{#State 59
		DEFAULT => -12
	},
	{#State 60
		ACTIONS => {
			"(" => 126,
			'VAR' => 84,
			'IDENT' => 11
		},
		GOTOS => {
			'symbol' => 123,
			'subquery' => 122,
			'model' => 121,
			'proc_call' => 124,
			'joined_obj' => 127,
			'joined_obj_list' => 125
		}
	},
	{#State 61
		DEFAULT => -8
	},
	{#State 62
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 128
		}
	},
	{#State 63
		DEFAULT => -9
	},
	{#State 64
		DEFAULT => -10
	},
	{#State 65
		DEFAULT => -7
	},
	{#State 66
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"||" => 135,
			"+" => 131,
			"/" => 136,
			"%" => 132,
			"^" => 133,
			"*" => 134
		},
		DEFAULT => -55
	},
	{#State 67
		DEFAULT => -136
	},
	{#State 68
		ACTIONS => {
			"(" => 137
		},
		DEFAULT => -86
	},
	{#State 69
		DEFAULT => -68
	},
	{#State 70
		ACTIONS => {
			")" => 138
		}
	},
	{#State 71
		ACTIONS => {
			"[" => 139
		},
		DEFAULT => -67
	},
	{#State 72
		ACTIONS => {
			")" => 140
		}
	},
	{#State 73
		DEFAULT => -70
	},
	{#State 74
		DEFAULT => -135
	},
	{#State 75
		DEFAULT => -65
	},
	{#State 76
		DEFAULT => -69
	},
	{#State 77
		ACTIONS => {
			"," => 141
		},
		DEFAULT => -54
	},
	{#State 78
		DEFAULT => -66
	},
	{#State 79
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 142,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 80
		ACTIONS => {
			"\@>" => -88,
			"\@" => -88,
			"\@\@" => -88,
			"<" => -88,
			"~" => -88,
			"like" => -88,
			">=" => -88,
			"[" => -88,
			">>" => -88,
			"<>" => -88,
			"<<=" => -88,
			"|" => 46,
			"<=" => -88,
			"." => -88,
			">" => -88,
			">>=" => -88,
			"in" => -88,
			"!=" => -88,
			"is" => -88,
			"=" => -88,
			"<<" => -88
		},
		DEFAULT => -77
	},
	{#State 81
		ACTIONS => {
			"%" => 35,
			"*" => 37,
			"||" => 38,
			"::" => 33,
			"^" => 36,
			"/" => 39
		},
		DEFAULT => -36
	},
	{#State 82
		DEFAULT => -86
	},
	{#State 83
		DEFAULT => -41
	},
	{#State 84
		ACTIONS => {
			"|" => 143
		},
		DEFAULT => -88
	},
	{#State 85
		DEFAULT => -38
	},
	{#State 86
		ACTIONS => {
			"%" => 35,
			"*" => 37,
			"||" => 38,
			"::" => 33,
			"^" => 36,
			"/" => 39
		},
		DEFAULT => -35
	},
	{#State 87
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -34
	},
	{#State 88
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -37
	},
	{#State 89
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -32
	},
	{#State 90
		ACTIONS => {
			"::" => 33
		},
		DEFAULT => -31
	},
	{#State 91
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -33
	},
	{#State 92
		DEFAULT => -89
	},
	{#State 93
		DEFAULT => -28
	},
	{#State 94
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"]" => 144
		}
	},
	{#State 95
		DEFAULT => -85
	},
	{#State 96
		DEFAULT => -11
	},
	{#State 97
		ACTIONS => {
			"[" => 145
		},
		DEFAULT => -39
	},
	{#State 98
		DEFAULT => -26
	},
	{#State 99
		DEFAULT => -87
	},
	{#State 100
		DEFAULT => -82
	},
	{#State 101
		DEFAULT => -80
	},
	{#State 102
		DEFAULT => -79
	},
	{#State 103
		DEFAULT => -149
	},
	{#State 104
		ACTIONS => {
			"|" => 146
		},
		DEFAULT => -77
	},
	{#State 105
		ACTIONS => {
			"," => 147
		},
		DEFAULT => -142
	},
	{#State 106
		DEFAULT => -140
	},
	{#State 107
		DEFAULT => -145
	},
	{#State 108
		DEFAULT => -146
	},
	{#State 109
		ACTIONS => {
			"desc" => 148,
			"asc" => 149
		},
		DEFAULT => -144,
		GOTOS => {
			'order_by_modifier' => 150
		}
	},
	{#State 110
		DEFAULT => -137
	},
	{#State 111
		ACTIONS => {
			"," => 151
		},
		DEFAULT => -139
	},
	{#State 112
		DEFAULT => -150
	},
	{#State 113
		DEFAULT => -90
	},
	{#State 114
		DEFAULT => -105
	},
	{#State 115
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"+" => 34,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"||" => 38,
			"/" => 39
		},
		DEFAULT => -108
	},
	{#State 116
		ACTIONS => {
			"and" => 152
		},
		DEFAULT => -103
	},
	{#State 117
		ACTIONS => {
			"or" => 153
		},
		DEFAULT => -101
	},
	{#State 118
		ACTIONS => {
			"\@>" => 154,
			"<" => 157,
			"\@\@" => 156,
			"\@" => 155,
			"~" => 158,
			"like" => 159,
			">=" => 160,
			">>=" => 161,
			"in" => 163,
			"<>" => 165,
			">>" => 164,
			"!=" => 166,
			"is" => 167,
			"=" => 168,
			"<<=" => 169,
			"<<" => 170,
			"<=" => 171,
			">" => 172
		},
		GOTOS => {
			'operator' => 162
		}
	},
	{#State 119
		ACTIONS => {
			'NUM' => 14,
			"(" => 119,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 114,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'qualified_symbol' => 12,
			'expr' => 173,
			'atom' => 17,
			'column' => 18,
			'conjunction' => 116,
			'symbol' => 19,
			'true_literal' => 20,
			'disjunction' => 117,
			'proc_call' => 22,
			'true_number' => 23,
			'lhs_atom' => 118,
			'condition' => 174
		}
	},
	{#State 120
		DEFAULT => -100
	},
	{#State 121
		ACTIONS => {
			"as" => 175
		},
		DEFAULT => -19
	},
	{#State 122
		ACTIONS => {
			"as" => 176
		}
	},
	{#State 123
		DEFAULT => -25
	},
	{#State 124
		ACTIONS => {
			"as" => 177
		},
		DEFAULT => -99
	},
	{#State 125
		DEFAULT => -98
	},
	{#State 126
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 178
		}
	},
	{#State 127
		ACTIONS => {
			"," => 179
		},
		DEFAULT => -15
	},
	{#State 128
		DEFAULT => -4
	},
	{#State 129
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 180,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 130
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 83,
			'type' => 181
		}
	},
	{#State 131
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 182,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 132
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 183,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 133
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 184,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 134
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 185,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 135
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 186,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 136
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 187,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 137
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			"*" => 190,
			'VAR' => 80,
			'IDENT' => 68,
			")" => 191,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 188,
			'symbol' => 19,
			'true_literal' => 74,
			'parameter2' => 189,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 192,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 138
		DEFAULT => -52
	},
	{#State 139
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 193,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 140
		DEFAULT => -51
	},
	{#State 141
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 66,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 77,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71,
			'parameter_list' => 194
		}
	},
	{#State 142
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"||" => 135,
			"+" => 131,
			"/" => 136,
			"%" => 132,
			"^" => 133,
			"*" => 134,
			")" => 195
		}
	},
	{#State 143
		ACTIONS => {
			'IDENT' => 99
		}
	},
	{#State 144
		DEFAULT => -47
	},
	{#State 145
		ACTIONS => {
			'NUM' => 14,
			"(" => 24,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'expr' => 196,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 146
		ACTIONS => {
			'NUM' => 101,
			'STRING' => 100
		}
	},
	{#State 147
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 68
		},
		GOTOS => {
			'proc_call2' => 108,
			'symbol' => 19,
			'order_by_atom' => 109,
			'order_by_objects' => 197,
			'column' => 107,
			'qualified_symbol' => 12,
			'order_by_object' => 105
		}
	},
	{#State 148
		DEFAULT => -148
	},
	{#State 149
		DEFAULT => -147
	},
	{#State 150
		DEFAULT => -143
	},
	{#State 151
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 198,
			'column' => 111,
			'qualified_symbol' => 12
		}
	},
	{#State 152
		ACTIONS => {
			'NUM' => 14,
			"(" => 119,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 114,
			'conjunction' => 199,
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'lhs_atom' => 118,
			'expr' => 115,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 153
		ACTIONS => {
			'NUM' => 14,
			"(" => 119,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 114,
			'true_literal' => 20,
			'symbol' => 19,
			'conjunction' => 116,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'disjunction' => 200,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'lhs_atom' => 118,
			'expr' => 115,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 154
		DEFAULT => -123
	},
	{#State 155
		DEFAULT => -128
	},
	{#State 156
		DEFAULT => -122
	},
	{#State 157
		DEFAULT => -117
	},
	{#State 158
		DEFAULT => -129
	},
	{#State 159
		DEFAULT => -121
	},
	{#State 160
		DEFAULT => -115
	},
	{#State 161
		DEFAULT => -126
	},
	{#State 162
		ACTIONS => {
			'NUM' => 14,
			"(" => 205,
			"null" => 204,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 201,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'rhs_atom' => 202,
			'subquery' => 203,
			'column' => 71
		}
	},
	{#State 163
		DEFAULT => -130
	},
	{#State 164
		DEFAULT => -127
	},
	{#State 165
		DEFAULT => -118
	},
	{#State 166
		DEFAULT => -119
	},
	{#State 167
		ACTIONS => {
			"not" => 206
		},
		DEFAULT => -132
	},
	{#State 168
		DEFAULT => -120
	},
	{#State 169
		DEFAULT => -124
	},
	{#State 170
		DEFAULT => -125
	},
	{#State 171
		DEFAULT => -116
	},
	{#State 172
		DEFAULT => -114
	},
	{#State 173
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"+" => 34,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			")" => 97,
			"||" => 38,
			"/" => 39
		},
		DEFAULT => -108
	},
	{#State 174
		ACTIONS => {
			")" => 207
		}
	},
	{#State 175
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 208
		}
	},
	{#State 176
		ACTIONS => {
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 209
		}
	},
	{#State 177
		ACTIONS => {
			"(" => 211,
			'VAR' => 84,
			'IDENT' => 82
		},
		GOTOS => {
			'symbol' => 210
		}
	},
	{#State 178
		ACTIONS => {
			")" => 212
		}
	},
	{#State 179
		ACTIONS => {
			"(" => 126,
			'VAR' => 84,
			'IDENT' => 11
		},
		GOTOS => {
			'symbol' => 123,
			'subquery' => 122,
			'model' => 121,
			'proc_call' => 213,
			'joined_obj' => 127,
			'joined_obj_list' => 214
		}
	},
	{#State 180
		ACTIONS => {
			"::" => 130,
			"%" => 132,
			"^" => 133,
			"*" => 134,
			"||" => 135,
			"/" => 136
		},
		DEFAULT => -61
	},
	{#State 181
		DEFAULT => -63
	},
	{#State 182
		ACTIONS => {
			"::" => 130,
			"%" => 132,
			"^" => 133,
			"*" => 134,
			"||" => 135,
			"/" => 136
		},
		DEFAULT => -60
	},
	{#State 183
		ACTIONS => {
			"::" => 130,
			"^" => 133,
			"||" => 135
		},
		DEFAULT => -59
	},
	{#State 184
		ACTIONS => {
			"::" => 130,
			"^" => 133,
			"||" => 135
		},
		DEFAULT => -62
	},
	{#State 185
		ACTIONS => {
			"::" => 130,
			"^" => 133,
			"||" => 135
		},
		DEFAULT => -57
	},
	{#State 186
		ACTIONS => {
			"::" => 130
		},
		DEFAULT => -56
	},
	{#State 187
		ACTIONS => {
			"::" => 130,
			"^" => 133,
			"||" => 135
		},
		DEFAULT => -58
	},
	{#State 188
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"||" => 135,
			"+" => 131,
			"/" => 136,
			"%" => 132,
			"^" => 133,
			"*" => 134
		},
		DEFAULT => -76
	},
	{#State 189
		ACTIONS => {
			"," => 215
		},
		DEFAULT => -75
	},
	{#State 190
		ACTIONS => {
			")" => 216
		}
	},
	{#State 191
		DEFAULT => -71
	},
	{#State 192
		ACTIONS => {
			")" => 217
		}
	},
	{#State 193
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"||" => 135,
			"+" => 131,
			"/" => 136,
			"%" => 132,
			"^" => 133,
			"*" => 134,
			"]" => 218
		}
	},
	{#State 194
		DEFAULT => -53
	},
	{#State 195
		ACTIONS => {
			"[" => 219
		},
		DEFAULT => -64
	},
	{#State 196
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"]" => 220
		}
	},
	{#State 197
		DEFAULT => -141
	},
	{#State 198
		DEFAULT => -138
	},
	{#State 199
		DEFAULT => -104
	},
	{#State 200
		DEFAULT => -102
	},
	{#State 201
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"+" => 131,
			"%" => 132,
			"^" => 133,
			"*" => 134,
			"||" => 135,
			"/" => 136
		},
		DEFAULT => -111
	},
	{#State 202
		DEFAULT => -106
	},
	{#State 203
		DEFAULT => -113
	},
	{#State 204
		DEFAULT => -110
	},
	{#State 205
		ACTIONS => {
			'NUM' => 14,
			"(" => 225,
			'VAR' => 80,
			"select" => 4,
			'IDENT' => 221,
			'STRING' => 13
		},
		GOTOS => {
			'select_stmt' => 178,
			'expr2' => 142,
			'comparison' => 114,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 115,
			'atom' => 17,
			'column' => 222,
			'array_index2' => 73,
			'conjunction' => 116,
			'symbol' => 19,
			'true_literal' => 223,
			'atom2' => 75,
			'proc_call' => 22,
			'disjunction' => 117,
			'true_number' => 224,
			'proc_call2' => 78,
			'lhs_atom' => 118,
			'condition' => 226
		}
	},
	{#State 206
		DEFAULT => -131
	},
	{#State 207
		ACTIONS => {
			'' => -107,
			"or" => -107,
			"limit" => -107,
			"order by" => -107,
			";" => -107,
			"group by" => -107,
			"offset" => -107,
			")" => -107,
			"where" => -107,
			"from" => -107,
			"and" => -107
		},
		DEFAULT => -109
	},
	{#State 208
		DEFAULT => -16
	},
	{#State 209
		DEFAULT => -20
	},
	{#State 210
		DEFAULT => -18
	},
	{#State 211
		ACTIONS => {
			'IDENT' => 227
		},
		GOTOS => {
			'col_decl' => 228,
			'col_decl_list' => 229
		}
	},
	{#State 212
		DEFAULT => -24
	},
	{#State 213
		ACTIONS => {
			"as" => 177
		}
	},
	{#State 214
		DEFAULT => -14
	},
	{#State 215
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 188,
			'symbol' => 19,
			'true_literal' => 74,
			'parameter2' => 189,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 230,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 216
		DEFAULT => -73
	},
	{#State 217
		DEFAULT => -72
	},
	{#State 218
		DEFAULT => -49
	},
	{#State 219
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			'VAR' => 80,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 73,
			'expr2' => 231,
			'symbol' => 19,
			'true_literal' => 74,
			'number' => 8,
			'variable' => 67,
			'atom2' => 75,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 76,
			'literal' => 69,
			'proc_call2' => 78,
			'column' => 71
		}
	},
	{#State 220
		DEFAULT => -48
	},
	{#State 221
		ACTIONS => {
			"(" => 232
		},
		DEFAULT => -86
	},
	{#State 222
		ACTIONS => {
			"[" => 233
		},
		DEFAULT => -44
	},
	{#State 223
		DEFAULT => -45
	},
	{#State 224
		DEFAULT => -46
	},
	{#State 225
		ACTIONS => {
			'NUM' => 14,
			"(" => 225,
			'VAR' => 80,
			'IDENT' => 221,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 142,
			'comparison' => 114,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 173,
			'atom' => 17,
			'column' => 222,
			'array_index2' => 73,
			'conjunction' => 116,
			'symbol' => 19,
			'true_literal' => 223,
			'atom2' => 75,
			'proc_call' => 22,
			'disjunction' => 117,
			'true_number' => 224,
			'proc_call2' => 78,
			'lhs_atom' => 118,
			'condition' => 174
		}
	},
	{#State 226
		ACTIONS => {
			")" => 234
		}
	},
	{#State 227
		ACTIONS => {
			'IDENT' => 235
		}
	},
	{#State 228
		ACTIONS => {
			"," => 236
		},
		DEFAULT => -22
	},
	{#State 229
		ACTIONS => {
			")" => 237
		}
	},
	{#State 230
		DEFAULT => -74
	},
	{#State 231
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"||" => 135,
			"+" => 131,
			"/" => 136,
			"%" => 132,
			"^" => 133,
			"*" => 134,
			"]" => 238
		}
	},
	{#State 232
		ACTIONS => {
			'NUM' => 14,
			"(" => 79,
			"*" => 240,
			'VAR' => 80,
			'IDENT' => 68,
			")" => 191,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 239,
			'parameter2' => 189,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'parameter_list' => 72,
			'column' => 71,
			'array_index2' => 73,
			'true_literal' => 74,
			'symbol' => 19,
			'parameter_list2' => 192,
			'atom2' => 75,
			'true_number' => 76,
			'parameter' => 77,
			'proc_call2' => 78
		}
	},
	{#State 233
		ACTIONS => {
			'NUM' => 14,
			"(" => 241,
			'VAR' => 80,
			'IDENT' => 221,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 193,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 94,
			'atom' => 17,
			'column' => 222,
			'array_index2' => 73,
			'symbol' => 19,
			'true_literal' => 223,
			'atom2' => 75,
			'proc_call' => 22,
			'true_number' => 224,
			'proc_call2' => 78
		}
	},
	{#State 234
		DEFAULT => -112
	},
	{#State 235
		DEFAULT => -23
	},
	{#State 236
		ACTIONS => {
			'IDENT' => 227
		},
		GOTOS => {
			'col_decl' => 228,
			'col_decl_list' => 242
		}
	},
	{#State 237
		DEFAULT => -17
	},
	{#State 238
		DEFAULT => -50
	},
	{#State 239
		ACTIONS => {
			"-" => 129,
			"::" => 130,
			"||" => 135,
			"+" => 131,
			"/" => 136,
			"%" => 132,
			"^" => 133,
			"*" => 134
		},
		DEFAULT => -55
	},
	{#State 240
		ACTIONS => {
			")" => 243
		}
	},
	{#State 241
		ACTIONS => {
			'NUM' => 14,
			"(" => 241,
			'VAR' => 80,
			'IDENT' => 221,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 142,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 44,
			'atom' => 17,
			'column' => 222,
			'array_index2' => 73,
			'symbol' => 19,
			'true_literal' => 223,
			'atom2' => 75,
			'proc_call' => 22,
			'true_number' => 224,
			'proc_call2' => 78
		}
	},
	{#State 242
		DEFAULT => -21
	},
	{#State 243
		DEFAULT => -52
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
		 'joined_obj_list', 3,
sub
#line 51 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 15
		 'joined_obj_list', 1, undef
	],
	[#Rule 16
		 'joined_obj', 3,
sub
#line 56 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'joined_obj', 5,
sub
#line 58 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 18
		 'joined_obj', 3,
sub
#line 60 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 19
		 'joined_obj', 1, undef
	],
	[#Rule 20
		 'joined_obj', 3,
sub
#line 63 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 21
		 'col_decl_list', 3,
sub
#line 67 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 22
		 'col_decl_list', 1, undef
	],
	[#Rule 23
		 'col_decl', 2,
sub
#line 72 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'subquery', 3,
sub
#line 76 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'model', 1,
sub
#line 79 "grammar/restyscript-view.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 26
		 'pattern_list', 3,
sub
#line 83 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 27
		 'pattern_list', 1, undef
	],
	[#Rule 28
		 'pattern', 3,
sub
#line 88 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'pattern', 1, undef
	],
	[#Rule 30
		 'pattern', 1, undef
	],
	[#Rule 31
		 'expr', 3,
sub
#line 94 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 32
		 'expr', 3,
sub
#line 96 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 33
		 'expr', 3,
sub
#line 98 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 34
		 'expr', 3,
sub
#line 100 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 35
		 'expr', 3,
sub
#line 102 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 36
		 'expr', 3,
sub
#line 104 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 37
		 'expr', 3,
sub
#line 106 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 38
		 'expr', 3,
sub
#line 108 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 39
		 'expr', 3,
sub
#line 110 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 40
		 'expr', 1, undef
	],
	[#Rule 41
		 'type', 1, undef
	],
	[#Rule 42
		 'atom', 1, undef
	],
	[#Rule 43
		 'atom', 1, undef
	],
	[#Rule 44
		 'atom', 1, undef
	],
	[#Rule 45
		 'atom', 1, undef
	],
	[#Rule 46
		 'atom', 1, undef
	],
	[#Rule 47
		 'array_index', 4,
sub
#line 125 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'array_index', 6,
sub
#line 127 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'array_index2', 4,
sub
#line 131 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'array_index2', 6,
sub
#line 133 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'proc_call', 4,
sub
#line 137 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'proc_call', 4,
sub
#line 139 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'parameter_list', 3,
sub
#line 143 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'parameter_list', 1, undef
	],
	[#Rule 55
		 'parameter', 1, undef
	],
	[#Rule 56
		 'expr2', 3,
sub
#line 151 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'expr2', 3,
sub
#line 153 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'expr2', 3,
sub
#line 155 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'expr2', 3,
sub
#line 157 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'expr2', 3,
sub
#line 159 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'expr2', 3,
sub
#line 161 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'expr2', 3,
sub
#line 163 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'expr2', 3,
sub
#line 165 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 64
		 'expr2', 3,
sub
#line 167 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 65
		 'expr2', 1, undef
	],
	[#Rule 66
		 'atom2', 1, undef
	],
	[#Rule 67
		 'atom2', 1, undef
	],
	[#Rule 68
		 'atom2', 1, undef
	],
	[#Rule 69
		 'atom2', 1, undef
	],
	[#Rule 70
		 'atom2', 1, undef
	],
	[#Rule 71
		 'proc_call2', 3,
sub
#line 179 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 72
		 'proc_call2', 4,
sub
#line 181 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 73
		 'proc_call2', 4,
sub
#line 183 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 74
		 'parameter_list2', 3,
sub
#line 187 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 75
		 'parameter_list2', 1, undef
	],
	[#Rule 76
		 'parameter2', 1, undef
	],
	[#Rule 77
		 'variable', 1,
sub
#line 196 "grammar/restyscript-view.yp"
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
	[#Rule 78
		 'true_number', 1, undef
	],
	[#Rule 79
		 'number', 1, undef
	],
	[#Rule 80
		 'number', 3,
sub
#line 212 "grammar/restyscript-view.yp"
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
	[#Rule 81
		 'string', 1,
sub
#line 224 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 82
		 'string', 3,
sub
#line 226 "grammar/restyscript-view.yp"
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
	[#Rule 83
		 'column', 1, undef
	],
	[#Rule 84
		 'column', 1,
sub
#line 238 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 85
		 'qualified_symbol', 3,
sub
#line 242 "grammar/restyscript-view.yp"
{
                      #push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 86
		 'symbol', 1, undef
	],
	[#Rule 87
		 'symbol', 3,
sub
#line 251 "grammar/restyscript-view.yp"
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
	[#Rule 88
		 'symbol', 1,
sub
#line 263 "grammar/restyscript-view.yp"
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
	[#Rule 89
		 'alias', 1, undef
	],
	[#Rule 90
		 'postfix_clause_list', 2,
sub
#line 279 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 91
		 'postfix_clause_list', 1, undef
	],
	[#Rule 92
		 'postfix_clause', 1, undef
	],
	[#Rule 93
		 'postfix_clause', 1, undef
	],
	[#Rule 94
		 'postfix_clause', 1, undef
	],
	[#Rule 95
		 'postfix_clause', 1, undef
	],
	[#Rule 96
		 'postfix_clause', 1, undef
	],
	[#Rule 97
		 'postfix_clause', 1, undef
	],
	[#Rule 98
		 'from_clause', 2,
sub
#line 292 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 99
		 'from_clause', 2,
sub
#line 294 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 100
		 'where_clause', 2,
sub
#line 298 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 101
		 'condition', 1, undef
	],
	[#Rule 102
		 'disjunction', 3,
sub
#line 305 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 103
		 'disjunction', 1, undef
	],
	[#Rule 104
		 'conjunction', 3,
sub
#line 310 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 105
		 'conjunction', 1, undef
	],
	[#Rule 106
		 'comparison', 3,
sub
#line 315 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 107
		 'comparison', 3,
sub
#line 317 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 108
		 'lhs_atom', 1, undef
	],
	[#Rule 109
		 'lhs_atom', 3,
sub
#line 322 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 110
		 'rhs_atom', 1, undef
	],
	[#Rule 111
		 'rhs_atom', 1, undef
	],
	[#Rule 112
		 'rhs_atom', 3,
sub
#line 328 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 113
		 'rhs_atom', 1, undef
	],
	[#Rule 114
		 'operator', 1, undef
	],
	[#Rule 115
		 'operator', 1, undef
	],
	[#Rule 116
		 'operator', 1, undef
	],
	[#Rule 117
		 'operator', 1, undef
	],
	[#Rule 118
		 'operator', 1, undef
	],
	[#Rule 119
		 'operator', 1, undef
	],
	[#Rule 120
		 'operator', 1, undef
	],
	[#Rule 121
		 'operator', 1, undef
	],
	[#Rule 122
		 'operator', 1, undef
	],
	[#Rule 123
		 'operator', 1, undef
	],
	[#Rule 124
		 'operator', 1, undef
	],
	[#Rule 125
		 'operator', 1, undef
	],
	[#Rule 126
		 'operator', 1, undef
	],
	[#Rule 127
		 'operator', 1, undef
	],
	[#Rule 128
		 'operator', 1, undef
	],
	[#Rule 129
		 'operator', 1, undef
	],
	[#Rule 130
		 'operator', 1, undef
	],
	[#Rule 131
		 'operator', 2,
sub
#line 350 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 132
		 'operator', 1, undef
	],
	[#Rule 133
		 'true_literal', 1, undef
	],
	[#Rule 134
		 'true_literal', 1, undef
	],
	[#Rule 135
		 'literal', 1, undef
	],
	[#Rule 136
		 'literal', 1, undef
	],
	[#Rule 137
		 'group_by_clause', 2,
sub
#line 364 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 138
		 'column_list', 3,
sub
#line 368 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 139
		 'column_list', 1, undef
	],
	[#Rule 140
		 'order_by_clause', 2,
sub
#line 373 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 141
		 'order_by_objects', 3,
sub
#line 377 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 142
		 'order_by_objects', 1, undef
	],
	[#Rule 143
		 'order_by_object', 2,
sub
#line 382 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 144
		 'order_by_object', 1, undef
	],
	[#Rule 145
		 'order_by_atom', 1, undef
	],
	[#Rule 146
		 'order_by_atom', 1, undef
	],
	[#Rule 147
		 'order_by_modifier', 1, undef
	],
	[#Rule 148
		 'order_by_modifier', 1, undef
	],
	[#Rule 149
		 'limit_clause', 2,
sub
#line 394 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 150
		 'offset_clause', 2,
sub
#line 398 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 401 "grammar/restyscript-view.yp"


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
        if (s/^\s*(\*|as|is|not|null|select|distinct|and|or|from|where|delete|update|set|order\s+by|asc|desc|group\s+by|limit|offset|union\s+all|union|intersect|except)\b//is) {
            my $s = $1;
            (my $token = $s) =~ s/\s+/ /gs;
            return (lc($token), lc($s));
        }
        s/^\s*(<<=|<<|>>=|>>|<=|>=|<>|!=|\|\||::|\blike\b|\bin\b|\@[>\@]|\@\b|~\b)//s
                and return (lc($1), lc($1));
        s/^\s*([A-Za-z][A-Za-z0-9_]*)\b//s
                and return ('IDENT', $1);
        s/^\$([A-Za-z]\w*|_ACCOUNT|_ROLE)\b//s
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
