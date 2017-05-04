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
		DEFAULT => -136
	},
	{#State 9
		DEFAULT => -44
	},
	{#State 10
		DEFAULT => -135
	},
	{#State 11
		ACTIONS => {
			"(" => 31
		},
		DEFAULT => -88
	},
	{#State 12
		DEFAULT => -85
	},
	{#State 13
		DEFAULT => -83
	},
	{#State 14
		DEFAULT => -80
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
		DEFAULT => -30
	},
	{#State 16
		DEFAULT => -31
	},
	{#State 17
		DEFAULT => -41
	},
	{#State 18
		ACTIONS => {
			"[" => 41
		},
		DEFAULT => -45
	},
	{#State 19
		ACTIONS => {
			"." => 42
		},
		DEFAULT => -86
	},
	{#State 20
		DEFAULT => -46
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
		DEFAULT => -43
	},
	{#State 23
		DEFAULT => -47
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
		DEFAULT => -28
	},
	{#State 26
		ACTIONS => {
			"|" => 46
		},
		DEFAULT => -90
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
			"(" => 80,
			"*" => 70,
			'VAR' => 81,
			'IDENT' => 68,
			")" => 71,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 66,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 78,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72,
			'parameter_list' => 73
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
			'expr' => 82,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 33
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 84,
			'type' => 86
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
			'expr' => 87,
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
			'expr' => 88,
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
			'expr' => 89,
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
			'expr' => 90,
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
			'expr' => 91,
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
			'expr' => 92,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 40
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 93,
			'alias' => 94
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
			'expr' => 95,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 42
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 96
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
			'postfix_clause_list' => 97,
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
			")" => 98
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
			'pattern_list' => 99,
			'column' => 18
		}
	},
	{#State 46
		ACTIONS => {
			'NUM' => 102,
			'IDENT' => 100,
			'STRING' => 101
		}
	},
	{#State 47
		DEFAULT => -98
	},
	{#State 48
		DEFAULT => -96
	},
	{#State 49
		ACTIONS => {
			'NUM' => 103,
			'VAR' => 105,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 104,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'string' => 10
		}
	},
	{#State 50
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 68
		},
		GOTOS => {
			'proc_call2' => 109,
			'symbol' => 19,
			'order_by_atom' => 110,
			'order_by_objects' => 107,
			'column' => 108,
			'qualified_symbol' => 12,
			'order_by_object' => 106
		}
	},
	{#State 51
		DEFAULT => -94
	},
	{#State 52
		DEFAULT => -95
	},
	{#State 53
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 111,
			'column' => 112,
			'qualified_symbol' => 12
		}
	},
	{#State 54
		DEFAULT => -99
	},
	{#State 55
		ACTIONS => {
			'NUM' => 103,
			'VAR' => 105,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 113,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'string' => 10
		}
	},
	{#State 56
		DEFAULT => -97
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
		DEFAULT => -93,
		GOTOS => {
			'postfix_clause_list' => 114,
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
			"(" => 120,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 115,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'qualified_symbol' => 12,
			'expr' => 116,
			'atom' => 17,
			'column' => 18,
			'conjunction' => 117,
			'symbol' => 19,
			'true_literal' => 20,
			'disjunction' => 118,
			'proc_call' => 22,
			'true_number' => 23,
			'lhs_atom' => 119,
			'condition' => 121
		}
	},
	{#State 59
		DEFAULT => -12
	},
	{#State 60
		ACTIONS => {
			"(" => 127,
			'VAR' => 85,
			'IDENT' => 11
		},
		GOTOS => {
			'symbol' => 124,
			'subquery' => 123,
			'model' => 122,
			'proc_call' => 125,
			'joined_obj' => 128,
			'joined_obj_list' => 126
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
			'compound_select_stmt' => 129
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
			"-" => 130,
			"::" => 131,
			"||" => 136,
			"+" => 132,
			"/" => 137,
			"%" => 133,
			"^" => 134,
			"*" => 135
		},
		DEFAULT => -57
	},
	{#State 67
		DEFAULT => -138
	},
	{#State 68
		ACTIONS => {
			"(" => 138
		},
		DEFAULT => -88
	},
	{#State 69
		DEFAULT => -70
	},
	{#State 70
		ACTIONS => {
			")" => 139
		}
	},
	{#State 71
		DEFAULT => -52
	},
	{#State 72
		ACTIONS => {
			"[" => 140
		},
		DEFAULT => -69
	},
	{#State 73
		ACTIONS => {
			")" => 141
		}
	},
	{#State 74
		DEFAULT => -72
	},
	{#State 75
		DEFAULT => -137
	},
	{#State 76
		DEFAULT => -67
	},
	{#State 77
		DEFAULT => -71
	},
	{#State 78
		ACTIONS => {
			"," => 142
		},
		DEFAULT => -56
	},
	{#State 79
		DEFAULT => -68
	},
	{#State 80
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 143,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 81
		ACTIONS => {
			"\@>" => -90,
			"\@" => -90,
			"\@\@" => -90,
			"<" => -90,
			"~" => -90,
			"like" => -90,
			">=" => -90,
			"[" => -90,
			">>" => -90,
			"<>" => -90,
			"<<=" => -90,
			"|" => 46,
			"<=" => -90,
			"." => -90,
			">" => -90,
			">>=" => -90,
			"in" => -90,
			"!=" => -90,
			"is" => -90,
			"=" => -90,
			"<<" => -90
		},
		DEFAULT => -79
	},
	{#State 82
		ACTIONS => {
			"%" => 35,
			"*" => 37,
			"||" => 38,
			"::" => 33,
			"^" => 36,
			"/" => 39
		},
		DEFAULT => -37
	},
	{#State 83
		DEFAULT => -88
	},
	{#State 84
		DEFAULT => -42
	},
	{#State 85
		ACTIONS => {
			"|" => 144
		},
		DEFAULT => -90
	},
	{#State 86
		DEFAULT => -39
	},
	{#State 87
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
	{#State 88
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -35
	},
	{#State 89
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -38
	},
	{#State 90
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -33
	},
	{#State 91
		ACTIONS => {
			"::" => 33
		},
		DEFAULT => -32
	},
	{#State 92
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -34
	},
	{#State 93
		DEFAULT => -91
	},
	{#State 94
		DEFAULT => -29
	},
	{#State 95
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"]" => 145
		}
	},
	{#State 96
		DEFAULT => -87
	},
	{#State 97
		DEFAULT => -11
	},
	{#State 98
		ACTIONS => {
			"[" => 146
		},
		DEFAULT => -40
	},
	{#State 99
		DEFAULT => -27
	},
	{#State 100
		DEFAULT => -89
	},
	{#State 101
		DEFAULT => -84
	},
	{#State 102
		DEFAULT => -82
	},
	{#State 103
		DEFAULT => -81
	},
	{#State 104
		DEFAULT => -151
	},
	{#State 105
		ACTIONS => {
			"|" => 147
		},
		DEFAULT => -79
	},
	{#State 106
		ACTIONS => {
			"," => 148
		},
		DEFAULT => -144
	},
	{#State 107
		DEFAULT => -142
	},
	{#State 108
		DEFAULT => -147
	},
	{#State 109
		DEFAULT => -148
	},
	{#State 110
		ACTIONS => {
			"desc" => 149,
			"asc" => 150
		},
		DEFAULT => -146,
		GOTOS => {
			'order_by_modifier' => 151
		}
	},
	{#State 111
		DEFAULT => -139
	},
	{#State 112
		ACTIONS => {
			"," => 152
		},
		DEFAULT => -141
	},
	{#State 113
		DEFAULT => -152
	},
	{#State 114
		DEFAULT => -92
	},
	{#State 115
		DEFAULT => -107
	},
	{#State 116
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
		DEFAULT => -110
	},
	{#State 117
		ACTIONS => {
			"and" => 153
		},
		DEFAULT => -105
	},
	{#State 118
		ACTIONS => {
			"or" => 154
		},
		DEFAULT => -103
	},
	{#State 119
		ACTIONS => {
			"\@>" => 155,
			"<" => 158,
			"\@\@" => 157,
			"\@" => 156,
			"~" => 159,
			"like" => 160,
			">=" => 161,
			">>=" => 162,
			"in" => 164,
			"<>" => 166,
			">>" => 165,
			"!=" => 167,
			"is" => 168,
			"=" => 169,
			"<<=" => 170,
			"<<" => 171,
			"<=" => 172,
			">" => 173
		},
		GOTOS => {
			'operator' => 163
		}
	},
	{#State 120
		ACTIONS => {
			'NUM' => 14,
			"(" => 120,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 115,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'qualified_symbol' => 12,
			'expr' => 174,
			'atom' => 17,
			'column' => 18,
			'conjunction' => 117,
			'symbol' => 19,
			'true_literal' => 20,
			'disjunction' => 118,
			'proc_call' => 22,
			'true_number' => 23,
			'lhs_atom' => 119,
			'condition' => 175
		}
	},
	{#State 121
		DEFAULT => -102
	},
	{#State 122
		ACTIONS => {
			"as" => 176
		},
		DEFAULT => -20
	},
	{#State 123
		ACTIONS => {
			"as" => 177
		}
	},
	{#State 124
		DEFAULT => -26
	},
	{#State 125
		ACTIONS => {
			"as" => 178
		},
		DEFAULT => -19
	},
	{#State 126
		DEFAULT => -100
	},
	{#State 127
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 179
		}
	},
	{#State 128
		ACTIONS => {
			"," => 180
		},
		DEFAULT => -15
	},
	{#State 129
		DEFAULT => -4
	},
	{#State 130
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 181,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 131
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 84,
			'type' => 182
		}
	},
	{#State 132
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 183,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 133
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 184,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 134
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 185,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 135
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 186,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 136
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 187,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 137
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 188,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 138
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			"*" => 191,
			'VAR' => 81,
			'IDENT' => 68,
			")" => 192,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 189,
			'symbol' => 19,
			'true_literal' => 75,
			'parameter2' => 190,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 193,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 139
		DEFAULT => -54
	},
	{#State 140
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 194,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 141
		DEFAULT => -53
	},
	{#State 142
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 66,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 78,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72,
			'parameter_list' => 195
		}
	},
	{#State 143
		ACTIONS => {
			"-" => 130,
			"::" => 131,
			"||" => 136,
			"+" => 132,
			"/" => 137,
			"%" => 133,
			"^" => 134,
			"*" => 135,
			")" => 196
		}
	},
	{#State 144
		ACTIONS => {
			'IDENT' => 100
		}
	},
	{#State 145
		DEFAULT => -48
	},
	{#State 146
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
			'expr' => 197,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 147
		ACTIONS => {
			'NUM' => 102,
			'STRING' => 101
		}
	},
	{#State 148
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 68
		},
		GOTOS => {
			'proc_call2' => 109,
			'symbol' => 19,
			'order_by_atom' => 110,
			'order_by_objects' => 198,
			'column' => 108,
			'qualified_symbol' => 12,
			'order_by_object' => 106
		}
	},
	{#State 149
		DEFAULT => -150
	},
	{#State 150
		DEFAULT => -149
	},
	{#State 151
		DEFAULT => -145
	},
	{#State 152
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 199,
			'column' => 112,
			'qualified_symbol' => 12
		}
	},
	{#State 153
		ACTIONS => {
			'NUM' => 14,
			"(" => 120,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 115,
			'conjunction' => 200,
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'lhs_atom' => 119,
			'expr' => 116,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 154
		ACTIONS => {
			'NUM' => 14,
			"(" => 120,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 115,
			'true_literal' => 20,
			'symbol' => 19,
			'conjunction' => 117,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'disjunction' => 201,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'lhs_atom' => 119,
			'expr' => 116,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 155
		DEFAULT => -125
	},
	{#State 156
		DEFAULT => -130
	},
	{#State 157
		DEFAULT => -124
	},
	{#State 158
		DEFAULT => -119
	},
	{#State 159
		DEFAULT => -131
	},
	{#State 160
		DEFAULT => -123
	},
	{#State 161
		DEFAULT => -117
	},
	{#State 162
		DEFAULT => -128
	},
	{#State 163
		ACTIONS => {
			'NUM' => 14,
			"(" => 206,
			"null" => 205,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 202,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'rhs_atom' => 203,
			'subquery' => 204,
			'column' => 72
		}
	},
	{#State 164
		DEFAULT => -132
	},
	{#State 165
		DEFAULT => -129
	},
	{#State 166
		DEFAULT => -120
	},
	{#State 167
		DEFAULT => -121
	},
	{#State 168
		ACTIONS => {
			"not" => 207
		},
		DEFAULT => -134
	},
	{#State 169
		DEFAULT => -122
	},
	{#State 170
		DEFAULT => -126
	},
	{#State 171
		DEFAULT => -127
	},
	{#State 172
		DEFAULT => -118
	},
	{#State 173
		DEFAULT => -116
	},
	{#State 174
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"+" => 34,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			")" => 98,
			"||" => 38,
			"/" => 39
		},
		DEFAULT => -110
	},
	{#State 175
		ACTIONS => {
			")" => 208
		}
	},
	{#State 176
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 209
		}
	},
	{#State 177
		ACTIONS => {
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 210
		}
	},
	{#State 178
		ACTIONS => {
			"(" => 212,
			'VAR' => 85,
			'IDENT' => 83
		},
		GOTOS => {
			'symbol' => 211
		}
	},
	{#State 179
		ACTIONS => {
			")" => 213
		}
	},
	{#State 180
		ACTIONS => {
			"(" => 127,
			'VAR' => 85,
			'IDENT' => 11
		},
		GOTOS => {
			'symbol' => 124,
			'subquery' => 123,
			'model' => 122,
			'proc_call' => 214,
			'joined_obj' => 128,
			'joined_obj_list' => 215
		}
	},
	{#State 181
		ACTIONS => {
			"::" => 131,
			"%" => 133,
			"^" => 134,
			"*" => 135,
			"||" => 136,
			"/" => 137
		},
		DEFAULT => -63
	},
	{#State 182
		DEFAULT => -65
	},
	{#State 183
		ACTIONS => {
			"::" => 131,
			"%" => 133,
			"^" => 134,
			"*" => 135,
			"||" => 136,
			"/" => 137
		},
		DEFAULT => -62
	},
	{#State 184
		ACTIONS => {
			"::" => 131,
			"^" => 134,
			"||" => 136
		},
		DEFAULT => -61
	},
	{#State 185
		ACTIONS => {
			"::" => 131,
			"^" => 134,
			"||" => 136
		},
		DEFAULT => -64
	},
	{#State 186
		ACTIONS => {
			"::" => 131,
			"^" => 134,
			"||" => 136
		},
		DEFAULT => -59
	},
	{#State 187
		ACTIONS => {
			"::" => 131
		},
		DEFAULT => -58
	},
	{#State 188
		ACTIONS => {
			"::" => 131,
			"^" => 134,
			"||" => 136
		},
		DEFAULT => -60
	},
	{#State 189
		ACTIONS => {
			"-" => 130,
			"::" => 131,
			"||" => 136,
			"+" => 132,
			"/" => 137,
			"%" => 133,
			"^" => 134,
			"*" => 135
		},
		DEFAULT => -78
	},
	{#State 190
		ACTIONS => {
			"," => 216
		},
		DEFAULT => -77
	},
	{#State 191
		ACTIONS => {
			")" => 217
		}
	},
	{#State 192
		DEFAULT => -73
	},
	{#State 193
		ACTIONS => {
			")" => 218
		}
	},
	{#State 194
		ACTIONS => {
			"-" => 130,
			"::" => 131,
			"||" => 136,
			"+" => 132,
			"/" => 137,
			"%" => 133,
			"^" => 134,
			"*" => 135,
			"]" => 219
		}
	},
	{#State 195
		DEFAULT => -55
	},
	{#State 196
		ACTIONS => {
			"[" => 220
		},
		DEFAULT => -66
	},
	{#State 197
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"]" => 221
		}
	},
	{#State 198
		DEFAULT => -143
	},
	{#State 199
		DEFAULT => -140
	},
	{#State 200
		DEFAULT => -106
	},
	{#State 201
		DEFAULT => -104
	},
	{#State 202
		ACTIONS => {
			"-" => 130,
			"::" => 131,
			"+" => 132,
			"%" => 133,
			"^" => 134,
			"*" => 135,
			"||" => 136,
			"/" => 137
		},
		DEFAULT => -113
	},
	{#State 203
		DEFAULT => -108
	},
	{#State 204
		DEFAULT => -115
	},
	{#State 205
		DEFAULT => -112
	},
	{#State 206
		ACTIONS => {
			'NUM' => 14,
			"(" => 226,
			'VAR' => 81,
			"select" => 4,
			'IDENT' => 222,
			'STRING' => 13
		},
		GOTOS => {
			'select_stmt' => 179,
			'expr2' => 143,
			'comparison' => 115,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 116,
			'atom' => 17,
			'column' => 223,
			'array_index2' => 74,
			'conjunction' => 117,
			'symbol' => 19,
			'true_literal' => 224,
			'atom2' => 76,
			'proc_call' => 22,
			'disjunction' => 118,
			'true_number' => 225,
			'proc_call2' => 79,
			'lhs_atom' => 119,
			'condition' => 227
		}
	},
	{#State 207
		DEFAULT => -133
	},
	{#State 208
		ACTIONS => {
			'' => -109,
			"or" => -109,
			"limit" => -109,
			"order by" => -109,
			";" => -109,
			"group by" => -109,
			"offset" => -109,
			")" => -109,
			"where" => -109,
			"from" => -109,
			"and" => -109
		},
		DEFAULT => -111
	},
	{#State 209
		DEFAULT => -16
	},
	{#State 210
		DEFAULT => -21
	},
	{#State 211
		DEFAULT => -18
	},
	{#State 212
		ACTIONS => {
			'IDENT' => 228
		},
		GOTOS => {
			'col_decl' => 229,
			'col_decl_list' => 230
		}
	},
	{#State 213
		DEFAULT => -25
	},
	{#State 214
		ACTIONS => {
			"as" => 178
		},
		DEFAULT => -19
	},
	{#State 215
		DEFAULT => -14
	},
	{#State 216
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 189,
			'symbol' => 19,
			'true_literal' => 75,
			'parameter2' => 190,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 231,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 217
		DEFAULT => -75
	},
	{#State 218
		DEFAULT => -74
	},
	{#State 219
		DEFAULT => -50
	},
	{#State 220
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			'VAR' => 81,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'array_index2' => 74,
			'expr2' => 232,
			'symbol' => 19,
			'true_literal' => 75,
			'number' => 8,
			'variable' => 67,
			'atom2' => 76,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 77,
			'literal' => 69,
			'proc_call2' => 79,
			'column' => 72
		}
	},
	{#State 221
		DEFAULT => -49
	},
	{#State 222
		ACTIONS => {
			"(" => 233
		},
		DEFAULT => -88
	},
	{#State 223
		ACTIONS => {
			"[" => 234
		},
		DEFAULT => -45
	},
	{#State 224
		DEFAULT => -46
	},
	{#State 225
		DEFAULT => -47
	},
	{#State 226
		ACTIONS => {
			'NUM' => 14,
			"(" => 226,
			'VAR' => 81,
			'IDENT' => 222,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 143,
			'comparison' => 115,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 174,
			'atom' => 17,
			'column' => 223,
			'array_index2' => 74,
			'conjunction' => 117,
			'symbol' => 19,
			'true_literal' => 224,
			'atom2' => 76,
			'proc_call' => 22,
			'disjunction' => 118,
			'true_number' => 225,
			'proc_call2' => 79,
			'lhs_atom' => 119,
			'condition' => 175
		}
	},
	{#State 227
		ACTIONS => {
			")" => 235
		}
	},
	{#State 228
		ACTIONS => {
			'IDENT' => 236
		}
	},
	{#State 229
		ACTIONS => {
			"," => 237
		},
		DEFAULT => -23
	},
	{#State 230
		ACTIONS => {
			")" => 238
		}
	},
	{#State 231
		DEFAULT => -76
	},
	{#State 232
		ACTIONS => {
			"-" => 130,
			"::" => 131,
			"||" => 136,
			"+" => 132,
			"/" => 137,
			"%" => 133,
			"^" => 134,
			"*" => 135,
			"]" => 239
		}
	},
	{#State 233
		ACTIONS => {
			'NUM' => 14,
			"(" => 80,
			"*" => 241,
			'VAR' => 81,
			'IDENT' => 68,
			")" => 242,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 240,
			'parameter2' => 190,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'parameter_list' => 73,
			'column' => 72,
			'array_index2' => 74,
			'true_literal' => 75,
			'symbol' => 19,
			'parameter_list2' => 193,
			'atom2' => 76,
			'true_number' => 77,
			'parameter' => 78,
			'proc_call2' => 79
		}
	},
	{#State 234
		ACTIONS => {
			'NUM' => 14,
			"(" => 243,
			'VAR' => 81,
			'IDENT' => 222,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 194,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 95,
			'atom' => 17,
			'column' => 223,
			'array_index2' => 74,
			'symbol' => 19,
			'true_literal' => 224,
			'atom2' => 76,
			'proc_call' => 22,
			'true_number' => 225,
			'proc_call2' => 79
		}
	},
	{#State 235
		DEFAULT => -114
	},
	{#State 236
		DEFAULT => -24
	},
	{#State 237
		ACTIONS => {
			'IDENT' => 228
		},
		GOTOS => {
			'col_decl' => 229,
			'col_decl_list' => 244
		}
	},
	{#State 238
		DEFAULT => -17
	},
	{#State 239
		DEFAULT => -51
	},
	{#State 240
		ACTIONS => {
			"-" => 130,
			"::" => 131,
			"||" => 136,
			"+" => 132,
			"/" => 137,
			"%" => 133,
			"^" => 134,
			"*" => 135
		},
		DEFAULT => -57
	},
	{#State 241
		ACTIONS => {
			")" => 245
		}
	},
	{#State 242
		DEFAULT => -52
	},
	{#State 243
		ACTIONS => {
			'NUM' => 14,
			"(" => 243,
			'VAR' => 81,
			'IDENT' => 222,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 143,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 44,
			'atom' => 17,
			'column' => 223,
			'array_index2' => 74,
			'symbol' => 19,
			'true_literal' => 224,
			'atom2' => 76,
			'proc_call' => 22,
			'true_number' => 225,
			'proc_call2' => 79
		}
	},
	{#State 244
		DEFAULT => -22
	},
	{#State 245
		DEFAULT => -54
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
		 'joined_obj', 1,
sub
#line 62 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 20
		 'joined_obj', 1, undef
	],
	[#Rule 21
		 'joined_obj', 3,
sub
#line 65 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 22
		 'col_decl_list', 3,
sub
#line 69 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'col_decl_list', 1, undef
	],
	[#Rule 24
		 'col_decl', 2,
sub
#line 74 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'subquery', 3,
sub
#line 78 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'model', 1,
sub
#line 81 "grammar/restyscript-view.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 27
		 'pattern_list', 3,
sub
#line 85 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'pattern_list', 1, undef
	],
	[#Rule 29
		 'pattern', 3,
sub
#line 90 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'pattern', 1, undef
	],
	[#Rule 31
		 'pattern', 1, undef
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
		 'expr', 3,
sub
#line 112 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 41
		 'expr', 1, undef
	],
	[#Rule 42
		 'type', 1, undef
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
		 'atom', 1, undef
	],
	[#Rule 48
		 'array_index', 4,
sub
#line 127 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'array_index', 6,
sub
#line 129 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'array_index2', 4,
sub
#line 133 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'array_index2', 6,
sub
#line 135 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'proc_call', 3,
sub
#line 139 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'proc_call', 4,
sub
#line 141 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'proc_call', 4,
sub
#line 143 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'parameter_list', 3,
sub
#line 147 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'parameter_list', 1, undef
	],
	[#Rule 57
		 'parameter', 1, undef
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
		 'expr2', 3,
sub
#line 169 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 66
		 'expr2', 3,
sub
#line 171 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 67
		 'expr2', 1, undef
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
		 'atom2', 1, undef
	],
	[#Rule 72
		 'atom2', 1, undef
	],
	[#Rule 73
		 'proc_call2', 3,
sub
#line 183 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 74
		 'proc_call2', 4,
sub
#line 185 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 75
		 'proc_call2', 4,
sub
#line 187 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 76
		 'parameter_list2', 3,
sub
#line 191 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 77
		 'parameter_list2', 1, undef
	],
	[#Rule 78
		 'parameter2', 1, undef
	],
	[#Rule 79
		 'variable', 1,
sub
#line 200 "grammar/restyscript-view.yp"
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
	[#Rule 80
		 'true_number', 1, undef
	],
	[#Rule 81
		 'number', 1, undef
	],
	[#Rule 82
		 'number', 3,
sub
#line 216 "grammar/restyscript-view.yp"
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
	[#Rule 83
		 'string', 1,
sub
#line 228 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 84
		 'string', 3,
sub
#line 230 "grammar/restyscript-view.yp"
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
	[#Rule 85
		 'column', 1, undef
	],
	[#Rule 86
		 'column', 1,
sub
#line 242 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 87
		 'qualified_symbol', 3,
sub
#line 246 "grammar/restyscript-view.yp"
{
                      #push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 88
		 'symbol', 1, undef
	],
	[#Rule 89
		 'symbol', 3,
sub
#line 255 "grammar/restyscript-view.yp"
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
	[#Rule 90
		 'symbol', 1,
sub
#line 267 "grammar/restyscript-view.yp"
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
	[#Rule 91
		 'alias', 1, undef
	],
	[#Rule 92
		 'postfix_clause_list', 2,
sub
#line 283 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 93
		 'postfix_clause_list', 1, undef
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
		 'postfix_clause', 1, undef
	],
	[#Rule 99
		 'postfix_clause', 1, undef
	],
	[#Rule 100
		 'from_clause', 2,
sub
#line 296 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 101
		 'from_clause', 2,
sub
#line 298 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 102
		 'where_clause', 2,
sub
#line 302 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 103
		 'condition', 1, undef
	],
	[#Rule 104
		 'disjunction', 3,
sub
#line 309 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 105
		 'disjunction', 1, undef
	],
	[#Rule 106
		 'conjunction', 3,
sub
#line 314 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 107
		 'conjunction', 1, undef
	],
	[#Rule 108
		 'comparison', 3,
sub
#line 319 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 109
		 'comparison', 3,
sub
#line 321 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 110
		 'lhs_atom', 1, undef
	],
	[#Rule 111
		 'lhs_atom', 3,
sub
#line 326 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 112
		 'rhs_atom', 1, undef
	],
	[#Rule 113
		 'rhs_atom', 1, undef
	],
	[#Rule 114
		 'rhs_atom', 3,
sub
#line 332 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 115
		 'rhs_atom', 1, undef
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
		 'operator', 1, undef
	],
	[#Rule 132
		 'operator', 1, undef
	],
	[#Rule 133
		 'operator', 2,
sub
#line 354 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 134
		 'operator', 1, undef
	],
	[#Rule 135
		 'true_literal', 1, undef
	],
	[#Rule 136
		 'true_literal', 1, undef
	],
	[#Rule 137
		 'literal', 1, undef
	],
	[#Rule 138
		 'literal', 1, undef
	],
	[#Rule 139
		 'group_by_clause', 2,
sub
#line 368 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 140
		 'column_list', 3,
sub
#line 372 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 141
		 'column_list', 1, undef
	],
	[#Rule 142
		 'order_by_clause', 2,
sub
#line 377 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 143
		 'order_by_objects', 3,
sub
#line 381 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 144
		 'order_by_objects', 1, undef
	],
	[#Rule 145
		 'order_by_object', 2,
sub
#line 386 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 146
		 'order_by_object', 1, undef
	],
	[#Rule 147
		 'order_by_atom', 1, undef
	],
	[#Rule 148
		 'order_by_atom', 1, undef
	],
	[#Rule 149
		 'order_by_modifier', 1, undef
	],
	[#Rule 150
		 'order_by_modifier', 1, undef
	],
	[#Rule 151
		 'limit_clause', 2,
sub
#line 398 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 152
		 'offset_clause', 2,
sub
#line 402 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 405 "grammar/restyscript-view.yp"


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

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty>.

=cut


1;
