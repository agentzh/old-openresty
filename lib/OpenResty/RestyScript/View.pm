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
		DEFAULT => -117
	},
	{#State 9
		DEFAULT => -116
	},
	{#State 10
		ACTIONS => {
			"(" => 30
		},
		DEFAULT => -75
	},
	{#State 11
		DEFAULT => -72
	},
	{#State 12
		DEFAULT => -70
	},
	{#State 13
		DEFAULT => -67
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
		DEFAULT => -25
	},
	{#State 15
		DEFAULT => -26
	},
	{#State 16
		DEFAULT => -36
	},
	{#State 17
		DEFAULT => -39
	},
	{#State 18
		ACTIONS => {
			"." => 40
		},
		DEFAULT => -73
	},
	{#State 19
		DEFAULT => -40
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
		DEFAULT => -38
	},
	{#State 22
		DEFAULT => -41
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
		DEFAULT => -23
	},
	{#State 25
		ACTIONS => {
			"|" => 44
		},
		DEFAULT => -77
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
		DEFAULT => -85
	},
	{#State 46
		DEFAULT => -83
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
		DEFAULT => -81
	},
	{#State 50
		DEFAULT => -82
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
		DEFAULT => -86
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
		DEFAULT => -84
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
		DEFAULT => -80,
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
		DEFAULT => -46
	},
	{#State 65
		DEFAULT => -119
	},
	{#State 66
		ACTIONS => {
			"(" => 133
		},
		DEFAULT => -75
	},
	{#State 67
		DEFAULT => -59
	},
	{#State 68
		ACTIONS => {
			")" => 134
		}
	},
	{#State 69
		DEFAULT => -58
	},
	{#State 70
		ACTIONS => {
			")" => 135
		}
	},
	{#State 71
		DEFAULT => -118
	},
	{#State 72
		DEFAULT => -56
	},
	{#State 73
		DEFAULT => -60
	},
	{#State 74
		ACTIONS => {
			"," => 136
		},
		DEFAULT => -45
	},
	{#State 75
		DEFAULT => -57
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
			"\@\@" => -77,
			"<" => -77,
			"like" => -77,
			">=" => -77,
			">>" => -77,
			"<>" => -77,
			"<<=" => -77,
			"|" => 44,
			"<=" => -77,
			"." => -77,
			">" => -77,
			">>=" => -77,
			"in" => -77,
			"!=" => -77,
			"=" => -77,
			"<<" => -77
		},
		DEFAULT => -66
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
		DEFAULT => -32
	},
	{#State 79
		DEFAULT => -75
	},
	{#State 80
		DEFAULT => -37
	},
	{#State 81
		ACTIONS => {
			"|" => 138
		},
		DEFAULT => -77
	},
	{#State 82
		DEFAULT => -34
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
		DEFAULT => -31
	},
	{#State 84
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -30
	},
	{#State 85
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -33
	},
	{#State 86
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -28
	},
	{#State 87
		ACTIONS => {
			"::" => 32
		},
		DEFAULT => -27
	},
	{#State 88
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -29
	},
	{#State 89
		DEFAULT => -78
	},
	{#State 90
		DEFAULT => -24
	},
	{#State 91
		DEFAULT => -74
	},
	{#State 92
		DEFAULT => -11
	},
	{#State 93
		DEFAULT => -35
	},
	{#State 94
		DEFAULT => -22
	},
	{#State 95
		DEFAULT => -76
	},
	{#State 96
		DEFAULT => -71
	},
	{#State 97
		DEFAULT => -69
	},
	{#State 98
		DEFAULT => -68
	},
	{#State 99
		DEFAULT => -132
	},
	{#State 100
		ACTIONS => {
			"|" => 139
		},
		DEFAULT => -66
	},
	{#State 101
		ACTIONS => {
			"," => 140
		},
		DEFAULT => -125
	},
	{#State 102
		DEFAULT => -123
	},
	{#State 103
		DEFAULT => -128
	},
	{#State 104
		DEFAULT => -129
	},
	{#State 105
		ACTIONS => {
			"desc" => 141,
			"asc" => 142
		},
		DEFAULT => -127,
		GOTOS => {
			'order_by_modifier' => 143
		}
	},
	{#State 106
		DEFAULT => -120
	},
	{#State 107
		ACTIONS => {
			"," => 144
		},
		DEFAULT => -122
	},
	{#State 108
		DEFAULT => -133
	},
	{#State 109
		DEFAULT => -79
	},
	{#State 110
		DEFAULT => -94
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
		DEFAULT => -97
	},
	{#State 112
		ACTIONS => {
			"and" => 145
		},
		DEFAULT => -92
	},
	{#State 113
		ACTIONS => {
			"or" => 146
		},
		DEFAULT => -90
	},
	{#State 114
		ACTIONS => {
			"!=" => 156,
			"<" => 148,
			"\@\@" => 147,
			"like" => 149,
			"=" => 157,
			">=" => 150,
			"<<=" => 158,
			">>=" => 151,
			"<<" => 159,
			"<=" => 160,
			"in" => 153,
			">" => 161,
			">>" => 154,
			"<>" => 155
		},
		GOTOS => {
			'operator' => 152
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
			'expr' => 162,
			'atom' => 16,
			'condition' => 163,
			'column' => 17
		}
	},
	{#State 116
		DEFAULT => -89
	},
	{#State 117
		ACTIONS => {
			"as" => 164
		},
		DEFAULT => -18
	},
	{#State 118
		ACTIONS => {
			"as" => 165
		}
	},
	{#State 119
		DEFAULT => -21
	},
	{#State 120
		ACTIONS => {
			"as" => 166
		},
		DEFAULT => -88
	},
	{#State 121
		DEFAULT => -87
	},
	{#State 122
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 167
		}
	},
	{#State 123
		ACTIONS => {
			"," => 168
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
			'expr2' => 169,
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
			'type' => 170
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
	{#State 128
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 172,
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
	{#State 130
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
	{#State 131
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
	{#State 132
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
	{#State 133
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 179,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 177,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 178,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 180,
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
		DEFAULT => -43
	},
	{#State 135
		DEFAULT => -42
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
			'parameter_list' => 181
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
			")" => 182
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
			'order_by_objects' => 183,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 141
		DEFAULT => -131
	},
	{#State 142
		DEFAULT => -130
	},
	{#State 143
		DEFAULT => -126
	},
	{#State 144
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 184,
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
			'conjunction' => 185,
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
			'disjunction' => 186,
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
		DEFAULT => -110
	},
	{#State 148
		DEFAULT => -105
	},
	{#State 149
		DEFAULT => -109
	},
	{#State 150
		DEFAULT => -103
	},
	{#State 151
		DEFAULT => -113
	},
	{#State 152
		ACTIONS => {
			'NUM' => 13,
			"(" => 190,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 187,
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
			'rhs_atom' => 188,
			'subquery' => 189,
			'column' => 69
		}
	},
	{#State 153
		DEFAULT => -115
	},
	{#State 154
		DEFAULT => -114
	},
	{#State 155
		DEFAULT => -106
	},
	{#State 156
		DEFAULT => -107
	},
	{#State 157
		DEFAULT => -108
	},
	{#State 158
		DEFAULT => -111
	},
	{#State 159
		DEFAULT => -112
	},
	{#State 160
		DEFAULT => -104
	},
	{#State 161
		DEFAULT => -102
	},
	{#State 162
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
		DEFAULT => -97
	},
	{#State 163
		ACTIONS => {
			")" => 191
		}
	},
	{#State 164
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 192
		}
	},
	{#State 165
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 193
		}
	},
	{#State 166
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 194
		}
	},
	{#State 167
		ACTIONS => {
			")" => 195
		}
	},
	{#State 168
		ACTIONS => {
			"(" => 122,
			'VAR' => 81,
			'IDENT' => 10
		},
		GOTOS => {
			'symbol' => 119,
			'subquery' => 118,
			'model' => 117,
			'proc_call' => 196,
			'joined_obj' => 123,
			'joined_obj_list' => 197
		}
	},
	{#State 169
		ACTIONS => {
			"::" => 126,
			"%" => 128,
			"^" => 129,
			"*" => 130,
			"||" => 131,
			"/" => 132
		},
		DEFAULT => -52
	},
	{#State 170
		DEFAULT => -54
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
		DEFAULT => -51
	},
	{#State 172
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -50
	},
	{#State 173
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -53
	},
	{#State 174
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -48
	},
	{#State 175
		ACTIONS => {
			"::" => 126
		},
		DEFAULT => -47
	},
	{#State 176
		ACTIONS => {
			"::" => 126,
			"^" => 129,
			"||" => 131
		},
		DEFAULT => -49
	},
	{#State 177
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
		DEFAULT => -65
	},
	{#State 178
		ACTIONS => {
			"," => 198
		},
		DEFAULT => -64
	},
	{#State 179
		ACTIONS => {
			")" => 199
		}
	},
	{#State 180
		ACTIONS => {
			")" => 200
		}
	},
	{#State 181
		DEFAULT => -44
	},
	{#State 182
		DEFAULT => -55
	},
	{#State 183
		DEFAULT => -124
	},
	{#State 184
		DEFAULT => -121
	},
	{#State 185
		DEFAULT => -93
	},
	{#State 186
		DEFAULT => -91
	},
	{#State 187
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
		DEFAULT => -99
	},
	{#State 188
		DEFAULT => -95
	},
	{#State 189
		DEFAULT => -101
	},
	{#State 190
		ACTIONS => {
			'NUM' => 13,
			"(" => 205,
			'VAR' => 77,
			"select" => 4,
			'IDENT' => 201,
			'STRING' => 12
		},
		GOTOS => {
			'select_stmt' => 167,
			'expr2' => 137,
			'comparison' => 110,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 111,
			'atom' => 16,
			'column' => 202,
			'conjunction' => 112,
			'symbol' => 18,
			'true_literal' => 203,
			'atom2' => 72,
			'disjunction' => 113,
			'proc_call' => 21,
			'true_number' => 204,
			'proc_call2' => 75,
			'lhs_atom' => 114,
			'condition' => 206
		}
	},
	{#State 191
		ACTIONS => {
			'' => -96,
			"or" => -96,
			"order by" => -96,
			"limit" => -96,
			";" => -96,
			"group by" => -96,
			"offset" => -96,
			")" => -96,
			"where" => -96,
			"from" => -96,
			"and" => -96
		},
		DEFAULT => -98
	},
	{#State 192
		DEFAULT => -16
	},
	{#State 193
		DEFAULT => -19
	},
	{#State 194
		DEFAULT => -17
	},
	{#State 195
		DEFAULT => -20
	},
	{#State 196
		ACTIONS => {
			"as" => 166
		}
	},
	{#State 197
		DEFAULT => -14
	},
	{#State 198
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
			'parameter2' => 178,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 207,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 199
		DEFAULT => -62
	},
	{#State 200
		DEFAULT => -61
	},
	{#State 201
		ACTIONS => {
			"(" => 208
		},
		DEFAULT => -75
	},
	{#State 202
		DEFAULT => -39
	},
	{#State 203
		DEFAULT => -40
	},
	{#State 204
		DEFAULT => -41
	},
	{#State 205
		ACTIONS => {
			'NUM' => 13,
			"(" => 205,
			'VAR' => 77,
			'IDENT' => 201,
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
			'expr' => 162,
			'atom' => 16,
			'column' => 202,
			'conjunction' => 112,
			'symbol' => 18,
			'true_literal' => 203,
			'atom2' => 72,
			'disjunction' => 113,
			'proc_call' => 21,
			'true_number' => 204,
			'proc_call2' => 75,
			'lhs_atom' => 114,
			'condition' => 163
		}
	},
	{#State 206
		ACTIONS => {
			")" => 209
		}
	},
	{#State 207
		DEFAULT => -63
	},
	{#State 208
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 211,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 210,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 178,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 180,
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
	{#State 209
		DEFAULT => -100
	},
	{#State 210
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
		DEFAULT => -46
	},
	{#State 211
		ACTIONS => {
			")" => 212
		}
	},
	{#State 212
		DEFAULT => -43
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
		 'joined_obj', 3,
sub
#line 58 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 18
		 'joined_obj', 1, undef
	],
	[#Rule 19
		 'joined_obj', 3,
sub
#line 61 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 20
		 'subquery', 3,
sub
#line 65 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 21
		 'model', 1,
sub
#line 68 "grammar/restyscript-view.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 22
		 'pattern_list', 3,
sub
#line 72 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'pattern_list', 1, undef
	],
	[#Rule 24
		 'pattern', 3,
sub
#line 77 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'pattern', 1, undef
	],
	[#Rule 26
		 'pattern', 1, undef
	],
	[#Rule 27
		 'expr', 3,
sub
#line 83 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'expr', 3,
sub
#line 85 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'expr', 3,
sub
#line 87 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'expr', 3,
sub
#line 89 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 31
		 'expr', 3,
sub
#line 91 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 32
		 'expr', 3,
sub
#line 93 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 33
		 'expr', 3,
sub
#line 95 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 34
		 'expr', 3,
sub
#line 97 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 35
		 'expr', 3,
sub
#line 99 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 36
		 'expr', 1, undef
	],
	[#Rule 37
		 'type', 1, undef
	],
	[#Rule 38
		 'atom', 1, undef
	],
	[#Rule 39
		 'atom', 1, undef
	],
	[#Rule 40
		 'atom', 1, undef
	],
	[#Rule 41
		 'atom', 1, undef
	],
	[#Rule 42
		 'proc_call', 4,
sub
#line 113 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 43
		 'proc_call', 4,
sub
#line 115 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 44
		 'parameter_list', 3,
sub
#line 119 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 45
		 'parameter_list', 1, undef
	],
	[#Rule 46
		 'parameter', 1, undef
	],
	[#Rule 47
		 'expr2', 3,
sub
#line 127 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'expr2', 3,
sub
#line 129 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'expr2', 3,
sub
#line 131 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'expr2', 3,
sub
#line 133 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'expr2', 3,
sub
#line 135 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'expr2', 3,
sub
#line 137 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'expr2', 3,
sub
#line 139 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'expr2', 3,
sub
#line 141 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'expr2', 3,
sub
#line 143 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'expr2', 1, undef
	],
	[#Rule 57
		 'atom2', 1, undef
	],
	[#Rule 58
		 'atom2', 1, undef
	],
	[#Rule 59
		 'atom2', 1, undef
	],
	[#Rule 60
		 'atom2', 1, undef
	],
	[#Rule 61
		 'proc_call2', 4,
sub
#line 154 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'proc_call2', 4,
sub
#line 156 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'parameter_list2', 3,
sub
#line 160 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 64
		 'parameter_list2', 1, undef
	],
	[#Rule 65
		 'parameter2', 1, undef
	],
	[#Rule 66
		 'variable', 1,
sub
#line 169 "grammar/restyscript-view.yp"
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
	[#Rule 67
		 'true_number', 1, undef
	],
	[#Rule 68
		 'number', 1, undef
	],
	[#Rule 69
		 'number', 3,
sub
#line 185 "grammar/restyscript-view.yp"
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
	[#Rule 70
		 'string', 1,
sub
#line 197 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 71
		 'string', 3,
sub
#line 199 "grammar/restyscript-view.yp"
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
	[#Rule 72
		 'column', 1, undef
	],
	[#Rule 73
		 'column', 1,
sub
#line 211 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 74
		 'qualified_symbol', 3,
sub
#line 215 "grammar/restyscript-view.yp"
{
                      #push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 75
		 'symbol', 1, undef
	],
	[#Rule 76
		 'symbol', 3,
sub
#line 224 "grammar/restyscript-view.yp"
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
	[#Rule 77
		 'symbol', 1,
sub
#line 236 "grammar/restyscript-view.yp"
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
	[#Rule 78
		 'alias', 1, undef
	],
	[#Rule 79
		 'postfix_clause_list', 2,
sub
#line 252 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 80
		 'postfix_clause_list', 1, undef
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
		 'postfix_clause', 1, undef
	],
	[#Rule 85
		 'postfix_clause', 1, undef
	],
	[#Rule 86
		 'postfix_clause', 1, undef
	],
	[#Rule 87
		 'from_clause', 2,
sub
#line 265 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 88
		 'from_clause', 2,
sub
#line 267 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 89
		 'where_clause', 2,
sub
#line 271 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 90
		 'condition', 1, undef
	],
	[#Rule 91
		 'disjunction', 3,
sub
#line 278 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 92
		 'disjunction', 1, undef
	],
	[#Rule 93
		 'conjunction', 3,
sub
#line 283 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 94
		 'conjunction', 1, undef
	],
	[#Rule 95
		 'comparison', 3,
sub
#line 288 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 96
		 'comparison', 3,
sub
#line 290 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 97
		 'lhs_atom', 1, undef
	],
	[#Rule 98
		 'lhs_atom', 3,
sub
#line 295 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 99
		 'rhs_atom', 1, undef
	],
	[#Rule 100
		 'rhs_atom', 3,
sub
#line 300 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 101
		 'rhs_atom', 1, undef
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
		 'true_literal', 1, undef
	],
	[#Rule 117
		 'true_literal', 1, undef
	],
	[#Rule 118
		 'literal', 1, undef
	],
	[#Rule 119
		 'literal', 1, undef
	],
	[#Rule 120
		 'group_by_clause', 2,
sub
#line 330 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 121
		 'column_list', 3,
sub
#line 334 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 122
		 'column_list', 1, undef
	],
	[#Rule 123
		 'order_by_clause', 2,
sub
#line 339 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 124
		 'order_by_objects', 3,
sub
#line 343 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 125
		 'order_by_objects', 1, undef
	],
	[#Rule 126
		 'order_by_object', 2,
sub
#line 348 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 127
		 'order_by_object', 1, undef
	],
	[#Rule 128
		 'order_by_atom', 1, undef
	],
	[#Rule 129
		 'order_by_atom', 1, undef
	],
	[#Rule 130
		 'order_by_modifier', 1, undef
	],
	[#Rule 131
		 'order_by_modifier', 1, undef
	],
	[#Rule 132
		 'limit_clause', 2,
sub
#line 360 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 133
		 'offset_clause', 2,
sub
#line 364 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 367 "grammar/restyscript-view.yp"


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
        s/^\s*(<<=|<<|>>=|>>|<=|>=|<>|!=|\|\||::|\blike\b|\bin\b|\@\@)//s
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
