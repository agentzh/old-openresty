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
		DEFAULT => -131
	},
	{#State 9
		DEFAULT => -43
	},
	{#State 10
		DEFAULT => -130
	},
	{#State 11
		ACTIONS => {
			"(" => 31
		},
		DEFAULT => -83
	},
	{#State 12
		DEFAULT => -80
	},
	{#State 13
		DEFAULT => -78
	},
	{#State 14
		DEFAULT => -75
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
		DEFAULT => -81
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
		DEFAULT => -85
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
			"(" => 78,
			"*" => 70,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 66,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 76,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
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
			'expr' => 80,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 33
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 82,
			'type' => 84
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
			'expr' => 85,
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
			'expr' => 86,
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
			'expr' => 87,
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
			'expr' => 88,
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
			'expr' => 89,
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
			'expr' => 90,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 40
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 91,
			'alias' => 92
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
			'expr' => 93,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 42
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 94
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
			'postfix_clause_list' => 95,
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
			")" => 96
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
			'pattern_list' => 97,
			'column' => 18
		}
	},
	{#State 46
		ACTIONS => {
			'NUM' => 100,
			'IDENT' => 98,
			'STRING' => 99
		}
	},
	{#State 47
		DEFAULT => -93
	},
	{#State 48
		DEFAULT => -91
	},
	{#State 49
		ACTIONS => {
			'NUM' => 101,
			'VAR' => 103,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 102,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'string' => 10
		}
	},
	{#State 50
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 68
		},
		GOTOS => {
			'proc_call2' => 107,
			'symbol' => 19,
			'order_by_atom' => 108,
			'order_by_objects' => 105,
			'column' => 106,
			'qualified_symbol' => 12,
			'order_by_object' => 104
		}
	},
	{#State 51
		DEFAULT => -89
	},
	{#State 52
		DEFAULT => -90
	},
	{#State 53
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 109,
			'column' => 110,
			'qualified_symbol' => 12
		}
	},
	{#State 54
		DEFAULT => -94
	},
	{#State 55
		ACTIONS => {
			'NUM' => 101,
			'VAR' => 103,
			'STRING' => 13
		},
		GOTOS => {
			'literal' => 111,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'string' => 10
		}
	},
	{#State 56
		DEFAULT => -92
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
		DEFAULT => -88,
		GOTOS => {
			'postfix_clause_list' => 112,
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
			"(" => 118,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 113,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'qualified_symbol' => 12,
			'expr' => 114,
			'atom' => 17,
			'column' => 18,
			'conjunction' => 115,
			'symbol' => 19,
			'true_literal' => 20,
			'disjunction' => 116,
			'proc_call' => 22,
			'true_number' => 23,
			'lhs_atom' => 117,
			'condition' => 119
		}
	},
	{#State 59
		DEFAULT => -12
	},
	{#State 60
		ACTIONS => {
			"(" => 125,
			'VAR' => 83,
			'IDENT' => 11
		},
		GOTOS => {
			'symbol' => 122,
			'subquery' => 121,
			'model' => 120,
			'proc_call' => 123,
			'joined_obj' => 126,
			'joined_obj_list' => 124
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
			'compound_select_stmt' => 127
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
			"-" => 128,
			"::" => 129,
			"||" => 134,
			"+" => 130,
			"/" => 135,
			"%" => 131,
			"^" => 132,
			"*" => 133
		},
		DEFAULT => -53
	},
	{#State 67
		DEFAULT => -133
	},
	{#State 68
		ACTIONS => {
			"(" => 136
		},
		DEFAULT => -83
	},
	{#State 69
		DEFAULT => -66
	},
	{#State 70
		ACTIONS => {
			")" => 137
		}
	},
	{#State 71
		DEFAULT => -65
	},
	{#State 72
		ACTIONS => {
			")" => 138
		}
	},
	{#State 73
		DEFAULT => -132
	},
	{#State 74
		DEFAULT => -63
	},
	{#State 75
		DEFAULT => -67
	},
	{#State 76
		ACTIONS => {
			"," => 139
		},
		DEFAULT => -52
	},
	{#State 77
		DEFAULT => -64
	},
	{#State 78
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 140,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 79
		ACTIONS => {
			"\@>" => -85,
			"\@" => -85,
			"\@\@" => -85,
			"<" => -85,
			"~" => -85,
			"like" => -85,
			">=" => -85,
			"[" => -85,
			">>" => -85,
			"<>" => -85,
			"<<=" => -85,
			"|" => 46,
			"<=" => -85,
			"." => -85,
			">" => -85,
			">>=" => -85,
			"in" => -85,
			"!=" => -85,
			"is" => -85,
			"=" => -85,
			"<<" => -85
		},
		DEFAULT => -74
	},
	{#State 80
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
	{#State 81
		DEFAULT => -83
	},
	{#State 82
		DEFAULT => -41
	},
	{#State 83
		ACTIONS => {
			"|" => 141
		},
		DEFAULT => -85
	},
	{#State 84
		DEFAULT => -38
	},
	{#State 85
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
	{#State 86
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -34
	},
	{#State 87
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -37
	},
	{#State 88
		ACTIONS => {
			"||" => 38,
			"::" => 33,
			"^" => 36
		},
		DEFAULT => -32
	},
	{#State 89
		ACTIONS => {
			"::" => 33
		},
		DEFAULT => -31
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
		DEFAULT => -86
	},
	{#State 92
		DEFAULT => -28
	},
	{#State 93
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"]" => 142
		}
	},
	{#State 94
		DEFAULT => -82
	},
	{#State 95
		DEFAULT => -11
	},
	{#State 96
		ACTIONS => {
			"[" => 143
		},
		DEFAULT => -39
	},
	{#State 97
		DEFAULT => -26
	},
	{#State 98
		DEFAULT => -84
	},
	{#State 99
		DEFAULT => -79
	},
	{#State 100
		DEFAULT => -77
	},
	{#State 101
		DEFAULT => -76
	},
	{#State 102
		DEFAULT => -146
	},
	{#State 103
		ACTIONS => {
			"|" => 144
		},
		DEFAULT => -74
	},
	{#State 104
		ACTIONS => {
			"," => 145
		},
		DEFAULT => -139
	},
	{#State 105
		DEFAULT => -137
	},
	{#State 106
		DEFAULT => -142
	},
	{#State 107
		DEFAULT => -143
	},
	{#State 108
		ACTIONS => {
			"desc" => 146,
			"asc" => 147
		},
		DEFAULT => -141,
		GOTOS => {
			'order_by_modifier' => 148
		}
	},
	{#State 109
		DEFAULT => -134
	},
	{#State 110
		ACTIONS => {
			"," => 149
		},
		DEFAULT => -136
	},
	{#State 111
		DEFAULT => -147
	},
	{#State 112
		DEFAULT => -87
	},
	{#State 113
		DEFAULT => -102
	},
	{#State 114
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
		DEFAULT => -105
	},
	{#State 115
		ACTIONS => {
			"and" => 150
		},
		DEFAULT => -100
	},
	{#State 116
		ACTIONS => {
			"or" => 151
		},
		DEFAULT => -98
	},
	{#State 117
		ACTIONS => {
			"\@>" => 152,
			"<" => 155,
			"\@\@" => 154,
			"\@" => 153,
			"~" => 156,
			"like" => 157,
			">=" => 158,
			">>=" => 159,
			"in" => 161,
			"<>" => 163,
			">>" => 162,
			"!=" => 164,
			"is" => 165,
			"=" => 166,
			"<<=" => 167,
			"<<" => 168,
			"<=" => 169,
			">" => 170
		},
		GOTOS => {
			'operator' => 160
		}
	},
	{#State 118
		ACTIONS => {
			'NUM' => 14,
			"(" => 118,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 113,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'qualified_symbol' => 12,
			'expr' => 171,
			'atom' => 17,
			'column' => 18,
			'conjunction' => 115,
			'symbol' => 19,
			'true_literal' => 20,
			'disjunction' => 116,
			'proc_call' => 22,
			'true_number' => 23,
			'lhs_atom' => 117,
			'condition' => 172
		}
	},
	{#State 119
		DEFAULT => -97
	},
	{#State 120
		ACTIONS => {
			"as" => 173
		},
		DEFAULT => -19
	},
	{#State 121
		ACTIONS => {
			"as" => 174
		}
	},
	{#State 122
		DEFAULT => -25
	},
	{#State 123
		ACTIONS => {
			"as" => 175
		},
		DEFAULT => -96
	},
	{#State 124
		DEFAULT => -95
	},
	{#State 125
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 176
		}
	},
	{#State 126
		ACTIONS => {
			"," => 177
		},
		DEFAULT => -15
	},
	{#State 127
		DEFAULT => -4
	},
	{#State 128
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 178,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 129
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 82,
			'type' => 179
		}
	},
	{#State 130
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 180,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 131
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 181,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 132
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 182,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 133
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 183,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 134
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 184,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 135
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 185,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 136
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			"*" => 188,
			'VAR' => 79,
			'IDENT' => 68,
			")" => 189,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 186,
			'symbol' => 19,
			'true_literal' => 73,
			'parameter2' => 187,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 190,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 137
		DEFAULT => -50
	},
	{#State 138
		DEFAULT => -49
	},
	{#State 139
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 66,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 76,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71,
			'parameter_list' => 191
		}
	},
	{#State 140
		ACTIONS => {
			"-" => 128,
			"::" => 129,
			"||" => 134,
			"+" => 130,
			"/" => 135,
			"%" => 131,
			"^" => 132,
			"*" => 133,
			")" => 192
		}
	},
	{#State 141
		ACTIONS => {
			'IDENT' => 98
		}
	},
	{#State 142
		DEFAULT => -47
	},
	{#State 143
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
			'expr' => 193,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 144
		ACTIONS => {
			'NUM' => 100,
			'STRING' => 99
		}
	},
	{#State 145
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 68
		},
		GOTOS => {
			'proc_call2' => 107,
			'symbol' => 19,
			'order_by_atom' => 108,
			'order_by_objects' => 194,
			'column' => 106,
			'qualified_symbol' => 12,
			'order_by_object' => 104
		}
	},
	{#State 146
		DEFAULT => -145
	},
	{#State 147
		DEFAULT => -144
	},
	{#State 148
		DEFAULT => -140
	},
	{#State 149
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 195,
			'column' => 110,
			'qualified_symbol' => 12
		}
	},
	{#State 150
		ACTIONS => {
			'NUM' => 14,
			"(" => 118,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 113,
			'conjunction' => 196,
			'true_literal' => 20,
			'symbol' => 19,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'lhs_atom' => 117,
			'expr' => 114,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 151
		ACTIONS => {
			'NUM' => 14,
			"(" => 118,
			'VAR' => 26,
			'IDENT' => 11,
			'STRING' => 13
		},
		GOTOS => {
			'comparison' => 113,
			'true_literal' => 20,
			'symbol' => 19,
			'conjunction' => 115,
			'array_index' => 9,
			'number' => 8,
			'string' => 10,
			'disjunction' => 197,
			'proc_call' => 22,
			'qualified_symbol' => 12,
			'true_number' => 23,
			'lhs_atom' => 117,
			'expr' => 114,
			'atom' => 17,
			'column' => 18
		}
	},
	{#State 152
		DEFAULT => -120
	},
	{#State 153
		DEFAULT => -125
	},
	{#State 154
		DEFAULT => -119
	},
	{#State 155
		DEFAULT => -114
	},
	{#State 156
		DEFAULT => -126
	},
	{#State 157
		DEFAULT => -118
	},
	{#State 158
		DEFAULT => -112
	},
	{#State 159
		DEFAULT => -123
	},
	{#State 160
		ACTIONS => {
			'NUM' => 14,
			"(" => 202,
			"null" => 201,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 198,
			'symbol' => 19,
			'true_literal' => 73,
			'number' => 8,
			'variable' => 67,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'rhs_atom' => 199,
			'subquery' => 200,
			'column' => 71
		}
	},
	{#State 161
		DEFAULT => -127
	},
	{#State 162
		DEFAULT => -124
	},
	{#State 163
		DEFAULT => -115
	},
	{#State 164
		DEFAULT => -116
	},
	{#State 165
		ACTIONS => {
			"not" => 203
		},
		DEFAULT => -129
	},
	{#State 166
		DEFAULT => -117
	},
	{#State 167
		DEFAULT => -121
	},
	{#State 168
		DEFAULT => -122
	},
	{#State 169
		DEFAULT => -113
	},
	{#State 170
		DEFAULT => -111
	},
	{#State 171
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"+" => 34,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			")" => 96,
			"||" => 38,
			"/" => 39
		},
		DEFAULT => -105
	},
	{#State 172
		ACTIONS => {
			")" => 204
		}
	},
	{#State 173
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 205
		}
	},
	{#State 174
		ACTIONS => {
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 206
		}
	},
	{#State 175
		ACTIONS => {
			"(" => 208,
			'VAR' => 83,
			'IDENT' => 81
		},
		GOTOS => {
			'symbol' => 207
		}
	},
	{#State 176
		ACTIONS => {
			")" => 209
		}
	},
	{#State 177
		ACTIONS => {
			"(" => 125,
			'VAR' => 83,
			'IDENT' => 11
		},
		GOTOS => {
			'symbol' => 122,
			'subquery' => 121,
			'model' => 120,
			'proc_call' => 210,
			'joined_obj' => 126,
			'joined_obj_list' => 211
		}
	},
	{#State 178
		ACTIONS => {
			"::" => 129,
			"%" => 131,
			"^" => 132,
			"*" => 133,
			"||" => 134,
			"/" => 135
		},
		DEFAULT => -59
	},
	{#State 179
		DEFAULT => -61
	},
	{#State 180
		ACTIONS => {
			"::" => 129,
			"%" => 131,
			"^" => 132,
			"*" => 133,
			"||" => 134,
			"/" => 135
		},
		DEFAULT => -58
	},
	{#State 181
		ACTIONS => {
			"::" => 129,
			"^" => 132,
			"||" => 134
		},
		DEFAULT => -57
	},
	{#State 182
		ACTIONS => {
			"::" => 129,
			"^" => 132,
			"||" => 134
		},
		DEFAULT => -60
	},
	{#State 183
		ACTIONS => {
			"::" => 129,
			"^" => 132,
			"||" => 134
		},
		DEFAULT => -55
	},
	{#State 184
		ACTIONS => {
			"::" => 129
		},
		DEFAULT => -54
	},
	{#State 185
		ACTIONS => {
			"::" => 129,
			"^" => 132,
			"||" => 134
		},
		DEFAULT => -56
	},
	{#State 186
		ACTIONS => {
			"-" => 128,
			"::" => 129,
			"||" => 134,
			"+" => 130,
			"/" => 135,
			"%" => 131,
			"^" => 132,
			"*" => 133
		},
		DEFAULT => -73
	},
	{#State 187
		ACTIONS => {
			"," => 212
		},
		DEFAULT => -72
	},
	{#State 188
		ACTIONS => {
			")" => 213
		}
	},
	{#State 189
		DEFAULT => -68
	},
	{#State 190
		ACTIONS => {
			")" => 214
		}
	},
	{#State 191
		DEFAULT => -51
	},
	{#State 192
		DEFAULT => -62
	},
	{#State 193
		ACTIONS => {
			"-" => 32,
			"::" => 33,
			"||" => 38,
			"+" => 34,
			"/" => 39,
			"%" => 35,
			"^" => 36,
			"*" => 37,
			"]" => 215
		}
	},
	{#State 194
		DEFAULT => -138
	},
	{#State 195
		DEFAULT => -135
	},
	{#State 196
		DEFAULT => -101
	},
	{#State 197
		DEFAULT => -99
	},
	{#State 198
		ACTIONS => {
			"-" => 128,
			"::" => 129,
			"+" => 130,
			"%" => 131,
			"^" => 132,
			"*" => 133,
			"||" => 134,
			"/" => 135
		},
		DEFAULT => -108
	},
	{#State 199
		DEFAULT => -103
	},
	{#State 200
		DEFAULT => -110
	},
	{#State 201
		DEFAULT => -107
	},
	{#State 202
		ACTIONS => {
			'NUM' => 14,
			"(" => 220,
			'VAR' => 79,
			"select" => 4,
			'IDENT' => 216,
			'STRING' => 13
		},
		GOTOS => {
			'select_stmt' => 176,
			'expr2' => 140,
			'comparison' => 113,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 114,
			'atom' => 17,
			'column' => 217,
			'conjunction' => 115,
			'symbol' => 19,
			'true_literal' => 218,
			'atom2' => 74,
			'proc_call' => 22,
			'disjunction' => 116,
			'true_number' => 219,
			'proc_call2' => 77,
			'lhs_atom' => 117,
			'condition' => 221
		}
	},
	{#State 203
		DEFAULT => -128
	},
	{#State 204
		ACTIONS => {
			'' => -104,
			"or" => -104,
			"limit" => -104,
			"order by" => -104,
			";" => -104,
			"group by" => -104,
			"offset" => -104,
			")" => -104,
			"where" => -104,
			"from" => -104,
			"and" => -104
		},
		DEFAULT => -106
	},
	{#State 205
		DEFAULT => -16
	},
	{#State 206
		DEFAULT => -20
	},
	{#State 207
		DEFAULT => -18
	},
	{#State 208
		ACTIONS => {
			'IDENT' => 222
		},
		GOTOS => {
			'col_decl' => 223,
			'col_decl_list' => 224
		}
	},
	{#State 209
		DEFAULT => -24
	},
	{#State 210
		ACTIONS => {
			"as" => 175
		}
	},
	{#State 211
		DEFAULT => -14
	},
	{#State 212
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			'VAR' => 79,
			'IDENT' => 68,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 186,
			'symbol' => 19,
			'true_literal' => 73,
			'parameter2' => 187,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 225,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'column' => 71
		}
	},
	{#State 213
		DEFAULT => -70
	},
	{#State 214
		DEFAULT => -69
	},
	{#State 215
		DEFAULT => -48
	},
	{#State 216
		ACTIONS => {
			"(" => 226
		},
		DEFAULT => -83
	},
	{#State 217
		ACTIONS => {
			"[" => 41
		},
		DEFAULT => -44
	},
	{#State 218
		DEFAULT => -45
	},
	{#State 219
		DEFAULT => -46
	},
	{#State 220
		ACTIONS => {
			'NUM' => 14,
			"(" => 220,
			'VAR' => 79,
			'IDENT' => 216,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 140,
			'comparison' => 113,
			'array_index' => 9,
			'number' => 8,
			'variable' => 67,
			'string' => 10,
			'qualified_symbol' => 12,
			'literal' => 69,
			'expr' => 171,
			'atom' => 17,
			'column' => 217,
			'conjunction' => 115,
			'symbol' => 19,
			'true_literal' => 218,
			'atom2' => 74,
			'disjunction' => 116,
			'proc_call' => 22,
			'true_number' => 219,
			'proc_call2' => 77,
			'lhs_atom' => 117,
			'condition' => 172
		}
	},
	{#State 221
		ACTIONS => {
			")" => 227
		}
	},
	{#State 222
		ACTIONS => {
			'IDENT' => 228
		}
	},
	{#State 223
		ACTIONS => {
			"," => 229
		},
		DEFAULT => -22
	},
	{#State 224
		ACTIONS => {
			")" => 230
		}
	},
	{#State 225
		DEFAULT => -71
	},
	{#State 226
		ACTIONS => {
			'NUM' => 14,
			"(" => 78,
			"*" => 232,
			'VAR' => 79,
			'IDENT' => 68,
			")" => 189,
			'STRING' => 13
		},
		GOTOS => {
			'expr2' => 231,
			'symbol' => 19,
			'true_literal' => 73,
			'parameter2' => 187,
			'number' => 8,
			'variable' => 67,
			'parameter_list2' => 190,
			'atom2' => 74,
			'string' => 10,
			'qualified_symbol' => 12,
			'parameter' => 76,
			'true_number' => 75,
			'literal' => 69,
			'proc_call2' => 77,
			'parameter_list' => 72,
			'column' => 71
		}
	},
	{#State 227
		DEFAULT => -109
	},
	{#State 228
		DEFAULT => -23
	},
	{#State 229
		ACTIONS => {
			'IDENT' => 222
		},
		GOTOS => {
			'col_decl' => 223,
			'col_decl_list' => 233
		}
	},
	{#State 230
		DEFAULT => -17
	},
	{#State 231
		ACTIONS => {
			"-" => 128,
			"::" => 129,
			"||" => 134,
			"+" => 130,
			"/" => 135,
			"%" => 131,
			"^" => 132,
			"*" => 133
		},
		DEFAULT => -53
	},
	{#State 232
		ACTIONS => {
			")" => 234
		}
	},
	{#State 233
		DEFAULT => -21
	},
	{#State 234
		DEFAULT => -50
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
		 'proc_call', 4,
sub
#line 131 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'proc_call', 4,
sub
#line 133 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'parameter_list', 3,
sub
#line 137 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'parameter_list', 1, undef
	],
	[#Rule 53
		 'parameter', 1, undef
	],
	[#Rule 54
		 'expr2', 3,
sub
#line 145 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'expr2', 3,
sub
#line 147 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'expr2', 3,
sub
#line 149 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'expr2', 3,
sub
#line 151 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'expr2', 3,
sub
#line 153 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'expr2', 3,
sub
#line 155 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'expr2', 3,
sub
#line 157 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'expr2', 3,
sub
#line 159 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'expr2', 3,
sub
#line 161 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'expr2', 1, undef
	],
	[#Rule 64
		 'atom2', 1, undef
	],
	[#Rule 65
		 'atom2', 1, undef
	],
	[#Rule 66
		 'atom2', 1, undef
	],
	[#Rule 67
		 'atom2', 1, undef
	],
	[#Rule 68
		 'proc_call2', 3,
sub
#line 172 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 69
		 'proc_call2', 4,
sub
#line 174 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 70
		 'proc_call2', 4,
sub
#line 176 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 71
		 'parameter_list2', 3,
sub
#line 180 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 72
		 'parameter_list2', 1, undef
	],
	[#Rule 73
		 'parameter2', 1, undef
	],
	[#Rule 74
		 'variable', 1,
sub
#line 189 "grammar/restyscript-view.yp"
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
	[#Rule 75
		 'true_number', 1, undef
	],
	[#Rule 76
		 'number', 1, undef
	],
	[#Rule 77
		 'number', 3,
sub
#line 205 "grammar/restyscript-view.yp"
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
	[#Rule 78
		 'string', 1,
sub
#line 217 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 79
		 'string', 3,
sub
#line 219 "grammar/restyscript-view.yp"
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
	[#Rule 80
		 'column', 1, undef
	],
	[#Rule 81
		 'column', 1,
sub
#line 231 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 82
		 'qualified_symbol', 3,
sub
#line 235 "grammar/restyscript-view.yp"
{
                      #push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 83
		 'symbol', 1, undef
	],
	[#Rule 84
		 'symbol', 3,
sub
#line 244 "grammar/restyscript-view.yp"
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
	[#Rule 85
		 'symbol', 1,
sub
#line 256 "grammar/restyscript-view.yp"
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
	[#Rule 86
		 'alias', 1, undef
	],
	[#Rule 87
		 'postfix_clause_list', 2,
sub
#line 272 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 88
		 'postfix_clause_list', 1, undef
	],
	[#Rule 89
		 'postfix_clause', 1, undef
	],
	[#Rule 90
		 'postfix_clause', 1, undef
	],
	[#Rule 91
		 'postfix_clause', 1, undef
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
		 'from_clause', 2,
sub
#line 285 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 96
		 'from_clause', 2,
sub
#line 287 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 97
		 'where_clause', 2,
sub
#line 291 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 98
		 'condition', 1, undef
	],
	[#Rule 99
		 'disjunction', 3,
sub
#line 298 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 100
		 'disjunction', 1, undef
	],
	[#Rule 101
		 'conjunction', 3,
sub
#line 303 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 102
		 'conjunction', 1, undef
	],
	[#Rule 103
		 'comparison', 3,
sub
#line 308 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 104
		 'comparison', 3,
sub
#line 310 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 105
		 'lhs_atom', 1, undef
	],
	[#Rule 106
		 'lhs_atom', 3,
sub
#line 315 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 107
		 'rhs_atom', 1, undef
	],
	[#Rule 108
		 'rhs_atom', 1, undef
	],
	[#Rule 109
		 'rhs_atom', 3,
sub
#line 321 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 110
		 'rhs_atom', 1, undef
	],
	[#Rule 111
		 'operator', 1, undef
	],
	[#Rule 112
		 'operator', 1, undef
	],
	[#Rule 113
		 'operator', 1, undef
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
		 'operator', 2,
sub
#line 343 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 129
		 'operator', 1, undef
	],
	[#Rule 130
		 'true_literal', 1, undef
	],
	[#Rule 131
		 'true_literal', 1, undef
	],
	[#Rule 132
		 'literal', 1, undef
	],
	[#Rule 133
		 'literal', 1, undef
	],
	[#Rule 134
		 'group_by_clause', 2,
sub
#line 357 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 135
		 'column_list', 3,
sub
#line 361 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 136
		 'column_list', 1, undef
	],
	[#Rule 137
		 'order_by_clause', 2,
sub
#line 366 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 138
		 'order_by_objects', 3,
sub
#line 370 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 139
		 'order_by_objects', 1, undef
	],
	[#Rule 140
		 'order_by_object', 2,
sub
#line 375 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 141
		 'order_by_object', 1, undef
	],
	[#Rule 142
		 'order_by_atom', 1, undef
	],
	[#Rule 143
		 'order_by_atom', 1, undef
	],
	[#Rule 144
		 'order_by_modifier', 1, undef
	],
	[#Rule 145
		 'order_by_modifier', 1, undef
	],
	[#Rule 146
		 'limit_clause', 2,
sub
#line 387 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 147
		 'offset_clause', 2,
sub
#line 391 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 394 "grammar/restyscript-view.yp"


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
