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
			'column_list' => 104,
			'column' => 105,
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
			'literal' => 106,
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
			"(" => 120,
			'VAR' => 81,
			'IDENT' => 10
		},
		GOTOS => {
			'symbol' => 117,
			'subquery' => 116,
			'model' => 115,
			'proc_call' => 118,
			'joined_obj' => 121,
			'joined_obj_list' => 119
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
			'compound_select_stmt' => 122
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
			"-" => 123,
			"::" => 124,
			"||" => 129,
			"+" => 125,
			"/" => 130,
			"%" => 126,
			"^" => 127,
			"*" => 128
		},
		DEFAULT => -46
	},
	{#State 65
		DEFAULT => -119
	},
	{#State 66
		ACTIONS => {
			"(" => 131
		},
		DEFAULT => -75
	},
	{#State 67
		DEFAULT => -59
	},
	{#State 68
		ACTIONS => {
			")" => 132
		}
	},
	{#State 69
		DEFAULT => -58
	},
	{#State 70
		ACTIONS => {
			")" => 133
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
			"," => 134
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
			'expr2' => 135,
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
			"|" => 136
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
		DEFAULT => -130
	},
	{#State 100
		ACTIONS => {
			"|" => 137
		},
		DEFAULT => -66
	},
	{#State 101
		ACTIONS => {
			"," => 138
		},
		DEFAULT => -125
	},
	{#State 102
		DEFAULT => -123
	},
	{#State 103
		ACTIONS => {
			"desc" => 139,
			"asc" => 140
		},
		DEFAULT => -127,
		GOTOS => {
			'order_by_modifier' => 141
		}
	},
	{#State 104
		DEFAULT => -120
	},
	{#State 105
		ACTIONS => {
			"," => 142
		},
		DEFAULT => -122
	},
	{#State 106
		DEFAULT => -131
	},
	{#State 107
		DEFAULT => -79
	},
	{#State 108
		DEFAULT => -94
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
		DEFAULT => -97
	},
	{#State 110
		ACTIONS => {
			"and" => 143
		},
		DEFAULT => -92
	},
	{#State 111
		ACTIONS => {
			"or" => 144
		},
		DEFAULT => -90
	},
	{#State 112
		ACTIONS => {
			"!=" => 154,
			"<" => 146,
			"\@\@" => 145,
			"like" => 147,
			"=" => 155,
			">=" => 148,
			"<<=" => 156,
			">>=" => 149,
			"<<" => 157,
			"<=" => 158,
			"in" => 151,
			">" => 159,
			">>" => 152,
			"<>" => 153
		},
		GOTOS => {
			'operator' => 150
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
			'expr' => 160,
			'atom' => 16,
			'condition' => 161,
			'column' => 17
		}
	},
	{#State 114
		DEFAULT => -89
	},
	{#State 115
		ACTIONS => {
			"as" => 162
		},
		DEFAULT => -18
	},
	{#State 116
		ACTIONS => {
			"as" => 163
		}
	},
	{#State 117
		DEFAULT => -21
	},
	{#State 118
		ACTIONS => {
			"as" => 164
		},
		DEFAULT => -88
	},
	{#State 119
		DEFAULT => -87
	},
	{#State 120
		ACTIONS => {
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 165
		}
	},
	{#State 121
		ACTIONS => {
			"," => 166
		},
		DEFAULT => -15
	},
	{#State 122
		DEFAULT => -4
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
	{#State 124
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 80,
			'type' => 168
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
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 170,
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
			"*" => 177,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 175,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 176,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 178,
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
		DEFAULT => -43
	},
	{#State 133
		DEFAULT => -42
	},
	{#State 134
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
			'parameter_list' => 179
		}
	},
	{#State 135
		ACTIONS => {
			"-" => 123,
			"::" => 124,
			"||" => 129,
			"+" => 125,
			"/" => 130,
			"%" => 126,
			"^" => 127,
			"*" => 128,
			")" => 180
		}
	},
	{#State 136
		ACTIONS => {
			'IDENT' => 95
		}
	},
	{#State 137
		ACTIONS => {
			'NUM' => 97,
			'STRING' => 96
		}
	},
	{#State 138
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'order_by_objects' => 181,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 139
		DEFAULT => -129
	},
	{#State 140
		DEFAULT => -128
	},
	{#State 141
		DEFAULT => -126
	},
	{#State 142
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 182,
			'column' => 105,
			'qualified_symbol' => 11
		}
	},
	{#State 143
		ACTIONS => {
			'NUM' => 13,
			"(" => 113,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 108,
			'conjunction' => 183,
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
	{#State 144
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
			'disjunction' => 184,
			'proc_call' => 21,
			'qualified_symbol' => 11,
			'true_number' => 22,
			'lhs_atom' => 112,
			'expr' => 109,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 145
		DEFAULT => -110
	},
	{#State 146
		DEFAULT => -105
	},
	{#State 147
		DEFAULT => -109
	},
	{#State 148
		DEFAULT => -103
	},
	{#State 149
		DEFAULT => -113
	},
	{#State 150
		ACTIONS => {
			'NUM' => 13,
			"(" => 188,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 185,
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
			'rhs_atom' => 186,
			'subquery' => 187,
			'column' => 69
		}
	},
	{#State 151
		DEFAULT => -115
	},
	{#State 152
		DEFAULT => -114
	},
	{#State 153
		DEFAULT => -106
	},
	{#State 154
		DEFAULT => -107
	},
	{#State 155
		DEFAULT => -108
	},
	{#State 156
		DEFAULT => -111
	},
	{#State 157
		DEFAULT => -112
	},
	{#State 158
		DEFAULT => -104
	},
	{#State 159
		DEFAULT => -102
	},
	{#State 160
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
	{#State 161
		ACTIONS => {
			")" => 189
		}
	},
	{#State 162
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 190
		}
	},
	{#State 163
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 191
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
			")" => 193
		}
	},
	{#State 166
		ACTIONS => {
			"(" => 120,
			'VAR' => 81,
			'IDENT' => 10
		},
		GOTOS => {
			'symbol' => 117,
			'subquery' => 116,
			'model' => 115,
			'proc_call' => 194,
			'joined_obj' => 121,
			'joined_obj_list' => 195
		}
	},
	{#State 167
		ACTIONS => {
			"::" => 124,
			"%" => 126,
			"^" => 127,
			"*" => 128,
			"||" => 129,
			"/" => 130
		},
		DEFAULT => -52
	},
	{#State 168
		DEFAULT => -54
	},
	{#State 169
		ACTIONS => {
			"::" => 124,
			"%" => 126,
			"^" => 127,
			"*" => 128,
			"||" => 129,
			"/" => 130
		},
		DEFAULT => -51
	},
	{#State 170
		ACTIONS => {
			"::" => 124,
			"^" => 127,
			"||" => 129
		},
		DEFAULT => -50
	},
	{#State 171
		ACTIONS => {
			"::" => 124,
			"^" => 127,
			"||" => 129
		},
		DEFAULT => -53
	},
	{#State 172
		ACTIONS => {
			"::" => 124,
			"^" => 127,
			"||" => 129
		},
		DEFAULT => -48
	},
	{#State 173
		ACTIONS => {
			"::" => 124
		},
		DEFAULT => -47
	},
	{#State 174
		ACTIONS => {
			"::" => 124,
			"^" => 127,
			"||" => 129
		},
		DEFAULT => -49
	},
	{#State 175
		ACTIONS => {
			"-" => 123,
			"::" => 124,
			"||" => 129,
			"+" => 125,
			"/" => 130,
			"%" => 126,
			"^" => 127,
			"*" => 128
		},
		DEFAULT => -65
	},
	{#State 176
		ACTIONS => {
			"," => 196
		},
		DEFAULT => -64
	},
	{#State 177
		ACTIONS => {
			")" => 197
		}
	},
	{#State 178
		ACTIONS => {
			")" => 198
		}
	},
	{#State 179
		DEFAULT => -44
	},
	{#State 180
		DEFAULT => -55
	},
	{#State 181
		DEFAULT => -124
	},
	{#State 182
		DEFAULT => -121
	},
	{#State 183
		DEFAULT => -93
	},
	{#State 184
		DEFAULT => -91
	},
	{#State 185
		ACTIONS => {
			"-" => 123,
			"::" => 124,
			"+" => 125,
			"%" => 126,
			"^" => 127,
			"*" => 128,
			"||" => 129,
			"/" => 130
		},
		DEFAULT => -99
	},
	{#State 186
		DEFAULT => -95
	},
	{#State 187
		DEFAULT => -101
	},
	{#State 188
		ACTIONS => {
			'NUM' => 13,
			"(" => 203,
			'VAR' => 77,
			"select" => 4,
			'IDENT' => 199,
			'STRING' => 12
		},
		GOTOS => {
			'select_stmt' => 165,
			'expr2' => 135,
			'comparison' => 108,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 109,
			'atom' => 16,
			'column' => 200,
			'conjunction' => 110,
			'symbol' => 18,
			'true_literal' => 201,
			'atom2' => 72,
			'disjunction' => 111,
			'proc_call' => 21,
			'true_number' => 202,
			'proc_call2' => 75,
			'lhs_atom' => 112,
			'condition' => 204
		}
	},
	{#State 189
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
	{#State 190
		DEFAULT => -16
	},
	{#State 191
		DEFAULT => -19
	},
	{#State 192
		DEFAULT => -17
	},
	{#State 193
		DEFAULT => -20
	},
	{#State 194
		ACTIONS => {
			"as" => 164
		}
	},
	{#State 195
		DEFAULT => -14
	},
	{#State 196
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
			'parameter2' => 176,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 205,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 197
		DEFAULT => -62
	},
	{#State 198
		DEFAULT => -61
	},
	{#State 199
		ACTIONS => {
			"(" => 206
		},
		DEFAULT => -75
	},
	{#State 200
		DEFAULT => -39
	},
	{#State 201
		DEFAULT => -40
	},
	{#State 202
		DEFAULT => -41
	},
	{#State 203
		ACTIONS => {
			'NUM' => 13,
			"(" => 203,
			'VAR' => 77,
			'IDENT' => 199,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 135,
			'comparison' => 108,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 160,
			'atom' => 16,
			'column' => 200,
			'conjunction' => 110,
			'symbol' => 18,
			'true_literal' => 201,
			'atom2' => 72,
			'disjunction' => 111,
			'proc_call' => 21,
			'true_number' => 202,
			'proc_call2' => 75,
			'lhs_atom' => 112,
			'condition' => 161
		}
	},
	{#State 204
		ACTIONS => {
			")" => 207
		}
	},
	{#State 205
		DEFAULT => -63
	},
	{#State 206
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 209,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 208,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 176,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 178,
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
	{#State 207
		DEFAULT => -100
	},
	{#State 208
		ACTIONS => {
			"-" => 123,
			"::" => 124,
			"||" => 129,
			"+" => 125,
			"/" => 130,
			"%" => 126,
			"^" => 127,
			"*" => 128
		},
		DEFAULT => -46
	},
	{#State 209
		ACTIONS => {
			")" => 210
		}
	},
	{#State 210
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
		 'joined_obj', 3, undef
	],
	[#Rule 18
		 'joined_obj', 1, undef
	],
	[#Rule 19
		 'joined_obj', 3,
sub
#line 60 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 20
		 'subquery', 3,
sub
#line 64 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 21
		 'model', 1,
sub
#line 67 "grammar/restyscript-view.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 22
		 'pattern_list', 3,
sub
#line 71 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'pattern_list', 1, undef
	],
	[#Rule 24
		 'pattern', 3,
sub
#line 76 "grammar/restyscript-view.yp"
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
#line 82 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'expr', 3,
sub
#line 84 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'expr', 3,
sub
#line 86 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'expr', 3,
sub
#line 88 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 31
		 'expr', 3,
sub
#line 90 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 32
		 'expr', 3,
sub
#line 92 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 33
		 'expr', 3,
sub
#line 94 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 34
		 'expr', 3,
sub
#line 96 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 35
		 'expr', 3,
sub
#line 98 "grammar/restyscript-view.yp"
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
#line 112 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 43
		 'proc_call', 4,
sub
#line 114 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 44
		 'parameter_list', 3,
sub
#line 118 "grammar/restyscript-view.yp"
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
#line 126 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'expr2', 3,
sub
#line 128 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'expr2', 3,
sub
#line 130 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'expr2', 3,
sub
#line 132 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'expr2', 3,
sub
#line 134 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'expr2', 3,
sub
#line 136 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 53
		 'expr2', 3,
sub
#line 138 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'expr2', 3,
sub
#line 140 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 55
		 'expr2', 3,
sub
#line 142 "grammar/restyscript-view.yp"
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
#line 153 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'proc_call2', 4,
sub
#line 155 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'parameter_list2', 3,
sub
#line 159 "grammar/restyscript-view.yp"
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
#line 168 "grammar/restyscript-view.yp"
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
#line 184 "grammar/restyscript-view.yp"
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
#line 196 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 71
		 'string', 3,
sub
#line 198 "grammar/restyscript-view.yp"
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
#line 210 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 74
		 'qualified_symbol', 3,
sub
#line 214 "grammar/restyscript-view.yp"
{
                      push @Models, $_[1];
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
#line 223 "grammar/restyscript-view.yp"
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
#line 235 "grammar/restyscript-view.yp"
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
#line 251 "grammar/restyscript-view.yp"
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
#line 264 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 88
		 'from_clause', 2,
sub
#line 266 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 89
		 'where_clause', 2,
sub
#line 270 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 90
		 'condition', 1, undef
	],
	[#Rule 91
		 'disjunction', 3,
sub
#line 277 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 92
		 'disjunction', 1, undef
	],
	[#Rule 93
		 'conjunction', 3,
sub
#line 282 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 94
		 'conjunction', 1, undef
	],
	[#Rule 95
		 'comparison', 3,
sub
#line 287 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 96
		 'comparison', 3,
sub
#line 289 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 97
		 'lhs_atom', 1, undef
	],
	[#Rule 98
		 'lhs_atom', 3,
sub
#line 294 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 99
		 'rhs_atom', 1, undef
	],
	[#Rule 100
		 'rhs_atom', 3,
sub
#line 299 "grammar/restyscript-view.yp"
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
#line 329 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 121
		 'column_list', 3,
sub
#line 333 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 122
		 'column_list', 1, undef
	],
	[#Rule 123
		 'order_by_clause', 2,
sub
#line 338 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 124
		 'order_by_objects', 3,
sub
#line 342 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 125
		 'order_by_objects', 1, undef
	],
	[#Rule 126
		 'order_by_object', 2,
sub
#line 347 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 127
		 'order_by_object', 1, undef
	],
	[#Rule 128
		 'order_by_modifier', 1, undef
	],
	[#Rule 129
		 'order_by_modifier', 1, undef
	],
	[#Rule 130
		 'limit_clause', 2,
sub
#line 355 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 131
		 'offset_clause', 2,
sub
#line 359 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 362 "grammar/restyscript-view.yp"


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
