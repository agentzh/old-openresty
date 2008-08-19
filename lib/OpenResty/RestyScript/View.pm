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
		DEFAULT => -125
	},
	{#State 9
		DEFAULT => -124
	},
	{#State 10
		ACTIONS => {
			"(" => 30
		},
		DEFAULT => -79
	},
	{#State 11
		DEFAULT => -76
	},
	{#State 12
		DEFAULT => -74
	},
	{#State 13
		DEFAULT => -71
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
		DEFAULT => -29
	},
	{#State 15
		DEFAULT => -30
	},
	{#State 16
		DEFAULT => -40
	},
	{#State 17
		DEFAULT => -43
	},
	{#State 18
		ACTIONS => {
			"." => 40
		},
		DEFAULT => -77
	},
	{#State 19
		DEFAULT => -44
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
		DEFAULT => -42
	},
	{#State 22
		DEFAULT => -45
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
		DEFAULT => -27
	},
	{#State 25
		ACTIONS => {
			"|" => 44
		},
		DEFAULT => -81
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
		DEFAULT => -89
	},
	{#State 46
		DEFAULT => -87
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
			'IDENT' => 66
		},
		GOTOS => {
			'proc_call2' => 104,
			'symbol' => 18,
			'order_by_atom' => 105,
			'order_by_objects' => 102,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 49
		DEFAULT => -85
	},
	{#State 50
		DEFAULT => -86
	},
	{#State 51
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 106,
			'column' => 107,
			'qualified_symbol' => 11
		}
	},
	{#State 52
		DEFAULT => -90
	},
	{#State 53
		ACTIONS => {
			'NUM' => 98,
			'VAR' => 100,
			'STRING' => 12
		},
		GOTOS => {
			'literal' => 108,
			'true_literal' => 71,
			'number' => 8,
			'variable' => 65,
			'string' => 9
		}
	},
	{#State 54
		DEFAULT => -88
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
		DEFAULT => -84,
		GOTOS => {
			'postfix_clause_list' => 109,
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
			"(" => 115,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 110,
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 112,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'disjunction' => 113,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 114,
			'expr' => 111,
			'atom' => 16,
			'condition' => 116,
			'column' => 17
		}
	},
	{#State 57
		DEFAULT => -12
	},
	{#State 58
		ACTIONS => {
			"(" => 122,
			'VAR' => 81,
			'IDENT' => 10
		},
		GOTOS => {
			'symbol' => 119,
			'subquery' => 118,
			'model' => 117,
			'proc_call' => 120,
			'joined_obj' => 123,
			'joined_obj_list' => 121
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
			'compound_select_stmt' => 124
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
			"-" => 125,
			"::" => 126,
			"||" => 131,
			"+" => 127,
			"/" => 132,
			"%" => 128,
			"^" => 129,
			"*" => 130
		},
		DEFAULT => -50
	},
	{#State 65
		DEFAULT => -127
	},
	{#State 66
		ACTIONS => {
			"(" => 133
		},
		DEFAULT => -79
	},
	{#State 67
		DEFAULT => -63
	},
	{#State 68
		ACTIONS => {
			")" => 134
		}
	},
	{#State 69
		DEFAULT => -62
	},
	{#State 70
		ACTIONS => {
			")" => 135
		}
	},
	{#State 71
		DEFAULT => -126
	},
	{#State 72
		DEFAULT => -60
	},
	{#State 73
		DEFAULT => -64
	},
	{#State 74
		ACTIONS => {
			"," => 136
		},
		DEFAULT => -49
	},
	{#State 75
		DEFAULT => -61
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
			'expr2' => 137,
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
			"\@>" => -81,
			"\@\@" => -81,
			"<" => -81,
			"like" => -81,
			">=" => -81,
			">>" => -81,
			"<>" => -81,
			"<<=" => -81,
			"|" => 44,
			"<=" => -81,
			"." => -81,
			">" => -81,
			">>=" => -81,
			"in" => -81,
			"!=" => -81,
			"is" => -81,
			"=" => -81,
			"<<" => -81
		},
		DEFAULT => -70
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
		DEFAULT => -36
	},
	{#State 79
		DEFAULT => -79
	},
	{#State 80
		DEFAULT => -41
	},
	{#State 81
		ACTIONS => {
			"|" => 138
		},
		DEFAULT => -81
	},
	{#State 82
		DEFAULT => -38
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
		DEFAULT => -35
	},
	{#State 84
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -34
	},
	{#State 85
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -37
	},
	{#State 86
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -32
	},
	{#State 87
		ACTIONS => {
			"::" => 32
		},
		DEFAULT => -31
	},
	{#State 88
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -33
	},
	{#State 89
		DEFAULT => -82
	},
	{#State 90
		DEFAULT => -28
	},
	{#State 91
		DEFAULT => -78
	},
	{#State 92
		DEFAULT => -11
	},
	{#State 93
		DEFAULT => -39
	},
	{#State 94
		DEFAULT => -26
	},
	{#State 95
		DEFAULT => -80
	},
	{#State 96
		DEFAULT => -75
	},
	{#State 97
		DEFAULT => -73
	},
	{#State 98
		DEFAULT => -72
	},
	{#State 99
		DEFAULT => -140
	},
	{#State 100
		ACTIONS => {
			"|" => 139
		},
		DEFAULT => -70
	},
	{#State 101
		ACTIONS => {
			"," => 140
		},
		DEFAULT => -133
	},
	{#State 102
		DEFAULT => -131
	},
	{#State 103
		DEFAULT => -136
	},
	{#State 104
		DEFAULT => -137
	},
	{#State 105
		ACTIONS => {
			"desc" => 141,
			"asc" => 142
		},
		DEFAULT => -135,
		GOTOS => {
			'order_by_modifier' => 143
		}
	},
	{#State 106
		DEFAULT => -128
	},
	{#State 107
		ACTIONS => {
			"," => 144
		},
		DEFAULT => -130
	},
	{#State 108
		DEFAULT => -141
	},
	{#State 109
		DEFAULT => -83
	},
	{#State 110
		DEFAULT => -98
	},
	{#State 111
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
		DEFAULT => -101
	},
	{#State 112
		ACTIONS => {
			"and" => 145
		},
		DEFAULT => -96
	},
	{#State 113
		ACTIONS => {
			"or" => 146
		},
		DEFAULT => -94
	},
	{#State 114
		ACTIONS => {
			"\@>" => 147,
			"<" => 149,
			"\@\@" => 148,
			"like" => 150,
			">=" => 151,
			">>=" => 152,
			"in" => 154,
			"<>" => 156,
			">>" => 155,
			"!=" => 157,
			"is" => 158,
			"=" => 159,
			"<<=" => 160,
			"<<" => 161,
			"<=" => 162,
			">" => 163
		},
		GOTOS => {
			'operator' => 153
		}
	},
	{#State 115
		ACTIONS => {
			'NUM' => 13,
			"(" => 115,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 110,
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 112,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'disjunction' => 113,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 114,
			'expr' => 164,
			'atom' => 16,
			'condition' => 165,
			'column' => 17
		}
	},
	{#State 116
		DEFAULT => -93
	},
	{#State 117
		ACTIONS => {
			"as" => 166
		},
		DEFAULT => -19
	},
	{#State 118
		ACTIONS => {
			"as" => 167
		}
	},
	{#State 119
		DEFAULT => -25
	},
	{#State 120
		ACTIONS => {
			"as" => 168
		},
		DEFAULT => -92
	},
	{#State 121
		DEFAULT => -91
	},
	{#State 122
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 169
		}
	},
	{#State 123
		ACTIONS => {
			"," => 170
		},
		DEFAULT => -15
	},
	{#State 124
		DEFAULT => -4
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
			'expr2' => 171,
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
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 80,
			'type' => 172
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
			'expr2' => 173,
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
			'expr2' => 174,
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
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 175,
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
	{#State 130
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 176,
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
	{#State 131
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 177,
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
	{#State 132
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 178,
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
	{#State 133
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 181,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 179,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 180,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 182,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 134
		DEFAULT => -47
	},
	{#State 135
		DEFAULT => -46
	},
	{#State 136
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
			'parameter_list' => 183
		}
	},
	{#State 137
		ACTIONS => {
			"-" => 125,
			"::" => 126,
			"||" => 131,
			"+" => 127,
			"/" => 132,
			"%" => 128,
			"^" => 129,
			"*" => 130,
			")" => 184
		}
	},
	{#State 138
		ACTIONS => {
			'IDENT' => 95
		}
	},
	{#State 139
		ACTIONS => {
			'NUM' => 97,
			'STRING' => 96
		}
	},
	{#State 140
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 66
		},
		GOTOS => {
			'proc_call2' => 104,
			'symbol' => 18,
			'order_by_atom' => 105,
			'order_by_objects' => 185,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 141
		DEFAULT => -139
	},
	{#State 142
		DEFAULT => -138
	},
	{#State 143
		DEFAULT => -134
	},
	{#State 144
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 186,
			'column' => 107,
			'qualified_symbol' => 11
		}
	},
	{#State 145
		ACTIONS => {
			'NUM' => 13,
			"(" => 115,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 110,
			'conjunction' => 187,
			'true_literal' => 19,
			'symbol' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 114,
			'expr' => 111,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 146
		ACTIONS => {
			'NUM' => 13,
			"(" => 115,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 110,
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 112,
			'number' => 8,
			'string' => 9,
			'disjunction' => 188,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 114,
			'expr' => 111,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 147
		DEFAULT => -116
	},
	{#State 148
		DEFAULT => -115
	},
	{#State 149
		DEFAULT => -110
	},
	{#State 150
		DEFAULT => -114
	},
	{#State 151
		DEFAULT => -108
	},
	{#State 152
		DEFAULT => -119
	},
	{#State 153
		ACTIONS => {
			'NUM' => 13,
			"(" => 193,
			"null" => 192,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 189,
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
			'rhs_atom' => 190,
			'subquery' => 191,
			'column' => 69
		}
	},
	{#State 154
		DEFAULT => -121
	},
	{#State 155
		DEFAULT => -120
	},
	{#State 156
		DEFAULT => -111
	},
	{#State 157
		DEFAULT => -112
	},
	{#State 158
		ACTIONS => {
			"not" => 194
		},
		DEFAULT => -123
	},
	{#State 159
		DEFAULT => -113
	},
	{#State 160
		DEFAULT => -117
	},
	{#State 161
		DEFAULT => -118
	},
	{#State 162
		DEFAULT => -109
	},
	{#State 163
		DEFAULT => -107
	},
	{#State 164
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
		DEFAULT => -101
	},
	{#State 165
		ACTIONS => {
			")" => 195
		}
	},
	{#State 166
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 196
		}
	},
	{#State 167
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 197
		}
	},
	{#State 168
		ACTIONS => {
			"(" => 199,
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 198
		}
	},
	{#State 169
		ACTIONS => {
			")" => 200
		}
	},
	{#State 170
		ACTIONS => {
			"(" => 122,
			'VAR' => 81,
			'IDENT' => 10
		},
		GOTOS => {
			'symbol' => 119,
			'subquery' => 118,
			'model' => 117,
			'proc_call' => 201,
			'joined_obj' => 123,
			'joined_obj_list' => 202
		}
	},
	{#State 171
		ACTIONS => {
			"::" => 126,
			"%" => 128,
			"^" => 129,
			"*" => 130,
			"||" => 131,
			"/" => 132
		},
		DEFAULT => -56
	},
	{#State 172
		DEFAULT => -58
	},
	{#State 173
		ACTIONS => {
			"::" => 126,
			"%" => 128,
			"^" => 129,
			"*" => 130,
			"||" => 131,
			"/" => 132
		},
		DEFAULT => -55
	},
	{#State 174
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -54
	},
	{#State 175
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -57
	},
	{#State 176
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -52
	},
	{#State 177
		ACTIONS => {
			"::" => 126
		},
		DEFAULT => -51
	},
	{#State 178
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -53
	},
	{#State 179
		ACTIONS => {
			"-" => 125,
			"::" => 126,
			"||" => 131,
			"+" => 127,
			"/" => 132,
			"%" => 128,
			"^" => 129,
			"*" => 130
		},
		DEFAULT => -69
	},
	{#State 180
		ACTIONS => {
			"," => 203
		},
		DEFAULT => -68
	},
	{#State 181
		ACTIONS => {
			")" => 204
		}
	},
	{#State 182
		ACTIONS => {
			")" => 205
		}
	},
	{#State 183
		DEFAULT => -48
	},
	{#State 184
		DEFAULT => -59
	},
	{#State 185
		DEFAULT => -132
	},
	{#State 186
		DEFAULT => -129
	},
	{#State 187
		DEFAULT => -97
	},
	{#State 188
		DEFAULT => -95
	},
	{#State 189
		ACTIONS => {
			"-" => 125,
			"::" => 126,
			"+" => 127,
			"%" => 128,
			"^" => 129,
			"*" => 130,
			"||" => 131,
			"/" => 132
		},
		DEFAULT => -104
	},
	{#State 190
		DEFAULT => -99
	},
	{#State 191
		DEFAULT => -106
	},
	{#State 192
		DEFAULT => -103
	},
	{#State 193
		ACTIONS => {
			'NUM' => 13,
			"(" => 210,
			'VAR' => 77,
			"select" => 4,
			'IDENT' => 206,
			'STRING' => 12
		},
		GOTOS => {
			'select_stmt' => 169,
			'expr2' => 137,
			'comparison' => 110,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 111,
			'atom' => 16,
			'column' => 207,
			'conjunction' => 112,
			'symbol' => 18,
			'true_literal' => 208,
			'atom2' => 72,
			'disjunction' => 113,
			'proc_call' => 21,
			'true_number' => 209,
			'proc_call2' => 75,
			'lhs_atom' => 114,
			'condition' => 211
		}
	},
	{#State 194
		DEFAULT => -122
	},
	{#State 195
		ACTIONS => {
			'' => -100,
			"or" => -100,
			"limit" => -100,
			"order by" => -100,
			";" => -100,
			"group by" => -100,
			"offset" => -100,
			")" => -100,
			"where" => -100,
			"from" => -100,
			"and" => -100
		},
		DEFAULT => -102
	},
	{#State 196
		DEFAULT => -16
	},
	{#State 197
		DEFAULT => -20
	},
	{#State 198
		DEFAULT => -18
	},
	{#State 199
		ACTIONS => {
			'IDENT' => 212
		},
		GOTOS => {
			'col_decl' => 213,
			'col_decl_list' => 214
		}
	},
	{#State 200
		DEFAULT => -24
	},
	{#State 201
		ACTIONS => {
			"as" => 168
		}
	},
	{#State 202
		DEFAULT => -14
	},
	{#State 203
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 179,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 180,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 215,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 204
		DEFAULT => -66
	},
	{#State 205
		DEFAULT => -65
	},
	{#State 206
		ACTIONS => {
			"(" => 216
		},
		DEFAULT => -79
	},
	{#State 207
		DEFAULT => -43
	},
	{#State 208
		DEFAULT => -44
	},
	{#State 209
		DEFAULT => -45
	},
	{#State 210
		ACTIONS => {
			'NUM' => 13,
			"(" => 210,
			'VAR' => 77,
			'IDENT' => 206,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 137,
			'comparison' => 110,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 164,
			'atom' => 16,
			'column' => 207,
			'conjunction' => 112,
			'symbol' => 18,
			'true_literal' => 208,
			'atom2' => 72,
			'disjunction' => 113,
			'proc_call' => 21,
			'true_number' => 209,
			'proc_call2' => 75,
			'lhs_atom' => 114,
			'condition' => 165
		}
	},
	{#State 211
		ACTIONS => {
			")" => 217
		}
	},
	{#State 212
		ACTIONS => {
			'IDENT' => 218
		}
	},
	{#State 213
		ACTIONS => {
			"," => 219
		},
		DEFAULT => -22
	},
	{#State 214
		ACTIONS => {
			")" => 220
		}
	},
	{#State 215
		DEFAULT => -67
	},
	{#State 216
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 222,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 221,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 180,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 182,
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
	{#State 217
		DEFAULT => -105
	},
	{#State 218
		DEFAULT => -23
	},
	{#State 219
		ACTIONS => {
			'IDENT' => 212
		},
		GOTOS => {
			'col_decl' => 213,
			'col_decl_list' => 223
		}
	},
	{#State 220
		DEFAULT => -17
	},
	{#State 221
		ACTIONS => {
			"-" => 125,
			"::" => 126,
			"||" => 131,
			"+" => 127,
			"/" => 132,
			"%" => 128,
			"^" => 129,
			"*" => 130
		},
		DEFAULT => -50
	},
	{#State 222
		ACTIONS => {
			")" => 224
		}
	},
	{#State 223
		DEFAULT => -21
	},
	{#State 224
		DEFAULT => -47
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
		 'proc_call', 4,
sub
#line 124 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'proc_call', 4,
sub
#line 126 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'parameter_list', 3,
sub
#line 130 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'parameter_list', 1, undef
	],
	[#Rule 50
		 'parameter', 1, undef
	],
	[#Rule 51
		 'expr2', 3,
sub
#line 138 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'expr2', 3,
sub
#line 140 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'expr2', 3,
sub
#line 142 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'expr2', 3,
sub
#line 144 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'expr2', 3,
sub
#line 146 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'expr2', 3,
sub
#line 148 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'expr2', 3,
sub
#line 150 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'expr2', 3,
sub
#line 152 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'expr2', 3,
sub
#line 154 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 60
		 'expr2', 1, undef
	],
	[#Rule 61
		 'atom2', 1, undef
	],
	[#Rule 62
		 'atom2', 1, undef
	],
	[#Rule 63
		 'atom2', 1, undef
	],
	[#Rule 64
		 'atom2', 1, undef
	],
	[#Rule 65
		 'proc_call2', 4,
sub
#line 165 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 66
		 'proc_call2', 4,
sub
#line 167 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 67
		 'parameter_list2', 3,
sub
#line 171 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 68
		 'parameter_list2', 1, undef
	],
	[#Rule 69
		 'parameter2', 1, undef
	],
	[#Rule 70
		 'variable', 1,
sub
#line 180 "grammar/restyscript-view.yp"
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
	[#Rule 71
		 'true_number', 1, undef
	],
	[#Rule 72
		 'number', 1, undef
	],
	[#Rule 73
		 'number', 3,
sub
#line 196 "grammar/restyscript-view.yp"
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
	[#Rule 74
		 'string', 1,
sub
#line 208 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 75
		 'string', 3,
sub
#line 210 "grammar/restyscript-view.yp"
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
	[#Rule 76
		 'column', 1, undef
	],
	[#Rule 77
		 'column', 1,
sub
#line 222 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 78
		 'qualified_symbol', 3,
sub
#line 226 "grammar/restyscript-view.yp"
{
                      #push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 79
		 'symbol', 1, undef
	],
	[#Rule 80
		 'symbol', 3,
sub
#line 235 "grammar/restyscript-view.yp"
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
	[#Rule 81
		 'symbol', 1,
sub
#line 247 "grammar/restyscript-view.yp"
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
	[#Rule 82
		 'alias', 1, undef
	],
	[#Rule 83
		 'postfix_clause_list', 2,
sub
#line 263 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 84
		 'postfix_clause_list', 1, undef
	],
	[#Rule 85
		 'postfix_clause', 1, undef
	],
	[#Rule 86
		 'postfix_clause', 1, undef
	],
	[#Rule 87
		 'postfix_clause', 1, undef
	],
	[#Rule 88
		 'postfix_clause', 1, undef
	],
	[#Rule 89
		 'postfix_clause', 1, undef
	],
	[#Rule 90
		 'postfix_clause', 1, undef
	],
	[#Rule 91
		 'from_clause', 2,
sub
#line 276 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 92
		 'from_clause', 2,
sub
#line 278 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 93
		 'where_clause', 2,
sub
#line 282 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 94
		 'condition', 1, undef
	],
	[#Rule 95
		 'disjunction', 3,
sub
#line 289 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 96
		 'disjunction', 1, undef
	],
	[#Rule 97
		 'conjunction', 3,
sub
#line 294 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 98
		 'conjunction', 1, undef
	],
	[#Rule 99
		 'comparison', 3,
sub
#line 299 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 100
		 'comparison', 3,
sub
#line 301 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 101
		 'lhs_atom', 1, undef
	],
	[#Rule 102
		 'lhs_atom', 3,
sub
#line 306 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 103
		 'rhs_atom', 1, undef
	],
	[#Rule 104
		 'rhs_atom', 1, undef
	],
	[#Rule 105
		 'rhs_atom', 3,
sub
#line 312 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 106
		 'rhs_atom', 1, undef
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
		 'operator', 2,
sub
#line 332 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 123
		 'operator', 1, undef
	],
	[#Rule 124
		 'true_literal', 1, undef
	],
	[#Rule 125
		 'true_literal', 1, undef
	],
	[#Rule 126
		 'literal', 1, undef
	],
	[#Rule 127
		 'literal', 1, undef
	],
	[#Rule 128
		 'group_by_clause', 2,
sub
#line 346 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 129
		 'column_list', 3,
sub
#line 350 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 130
		 'column_list', 1, undef
	],
	[#Rule 131
		 'order_by_clause', 2,
sub
#line 355 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 132
		 'order_by_objects', 3,
sub
#line 359 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 133
		 'order_by_objects', 1, undef
	],
	[#Rule 134
		 'order_by_object', 2,
sub
#line 364 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 135
		 'order_by_object', 1, undef
	],
	[#Rule 136
		 'order_by_atom', 1, undef
	],
	[#Rule 137
		 'order_by_atom', 1, undef
	],
	[#Rule 138
		 'order_by_modifier', 1, undef
	],
	[#Rule 139
		 'order_by_modifier', 1, undef
	],
	[#Rule 140
		 'limit_clause', 2,
sub
#line 376 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 141
		 'offset_clause', 2,
sub
#line 380 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 383 "grammar/restyscript-view.yp"


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
        s/^\s*(<<=|<<|>>=|>>|<=|>=|<>|!=|\|\||::|\blike\b|\bin\b|\@[>\@])//s
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
