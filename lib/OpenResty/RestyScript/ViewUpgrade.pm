####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package OpenResty::RestyScript::ViewUpgrade;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 5 "grammar/view-upgrade.yp"


my @Vars;



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
		DEFAULT => -110
	},
	{#State 9
		DEFAULT => -109
	},
	{#State 10
		ACTIONS => {
			"(" => 30
		},
		DEFAULT => -70
	},
	{#State 11
		DEFAULT => -67
	},
	{#State 12
		DEFAULT => -65
	},
	{#State 13
		DEFAULT => -62
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
		DEFAULT => -20
	},
	{#State 15
		DEFAULT => -21
	},
	{#State 16
		DEFAULT => -31
	},
	{#State 17
		DEFAULT => -34
	},
	{#State 18
		ACTIONS => {
			"." => 40
		},
		DEFAULT => -68
	},
	{#State 19
		DEFAULT => -35
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
		DEFAULT => -33
	},
	{#State 22
		DEFAULT => -36
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
		DEFAULT => -18
	},
	{#State 25
		ACTIONS => {
			"|" => 44
		},
		DEFAULT => -72
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
		DEFAULT => -80
	},
	{#State 46
		DEFAULT => -78
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
		DEFAULT => -76
	},
	{#State 50
		DEFAULT => -77
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
		DEFAULT => -81
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
		DEFAULT => -79
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
		DEFAULT => -75,
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
			'models' => 116,
			'symbol' => 117,
			'model' => 115,
			'proc_call' => 118
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
			'compound_select_stmt' => 119
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
			"-" => 120,
			"::" => 121,
			"||" => 126,
			"+" => 122,
			"/" => 127,
			"%" => 123,
			"^" => 124,
			"*" => 125
		},
		DEFAULT => -41
	},
	{#State 65
		DEFAULT => -112
	},
	{#State 66
		ACTIONS => {
			"(" => 128
		},
		DEFAULT => -70
	},
	{#State 67
		DEFAULT => -54
	},
	{#State 68
		ACTIONS => {
			")" => 129
		}
	},
	{#State 69
		DEFAULT => -53
	},
	{#State 70
		ACTIONS => {
			")" => 130
		}
	},
	{#State 71
		DEFAULT => -111
	},
	{#State 72
		DEFAULT => -51
	},
	{#State 73
		DEFAULT => -55
	},
	{#State 74
		ACTIONS => {
			"," => 131
		},
		DEFAULT => -40
	},
	{#State 75
		DEFAULT => -52
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
			'expr2' => 132,
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
			"\@\@" => -72,
			"<" => -72,
			"like" => -72,
			">=" => -72,
			">>=" => -72,
			">>" => -72,
			"<>" => -72,
			"!=" => -72,
			"=" => -72,
			"<<=" => -72,
			"|" => 44,
			"<<" => -72,
			"<=" => -72,
			"." => -72,
			">" => -72
		},
		DEFAULT => -61
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
		DEFAULT => -27
	},
	{#State 79
		DEFAULT => -70
	},
	{#State 80
		DEFAULT => -32
	},
	{#State 81
		ACTIONS => {
			"|" => 133
		},
		DEFAULT => -72
	},
	{#State 82
		DEFAULT => -29
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
		DEFAULT => -26
	},
	{#State 84
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -25
	},
	{#State 85
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -28
	},
	{#State 86
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -23
	},
	{#State 87
		ACTIONS => {
			"::" => 32
		},
		DEFAULT => -22
	},
	{#State 88
		ACTIONS => {
			"::" => 32,
			"^" => 35,
			"||" => 37
		},
		DEFAULT => -24
	},
	{#State 89
		DEFAULT => -73
	},
	{#State 90
		DEFAULT => -19
	},
	{#State 91
		DEFAULT => -69
	},
	{#State 92
		DEFAULT => -11
	},
	{#State 93
		DEFAULT => -30
	},
	{#State 94
		DEFAULT => -17
	},
	{#State 95
		DEFAULT => -71
	},
	{#State 96
		DEFAULT => -66
	},
	{#State 97
		DEFAULT => -64
	},
	{#State 98
		DEFAULT => -63
	},
	{#State 99
		DEFAULT => -123
	},
	{#State 100
		ACTIONS => {
			"|" => 134
		},
		DEFAULT => -61
	},
	{#State 101
		ACTIONS => {
			"," => 135
		},
		DEFAULT => -118
	},
	{#State 102
		DEFAULT => -116
	},
	{#State 103
		ACTIONS => {
			"desc" => 136,
			"asc" => 137
		},
		DEFAULT => -120,
		GOTOS => {
			'order_by_modifier' => 138
		}
	},
	{#State 104
		DEFAULT => -113
	},
	{#State 105
		ACTIONS => {
			"," => 139
		},
		DEFAULT => -115
	},
	{#State 106
		DEFAULT => -124
	},
	{#State 107
		DEFAULT => -74
	},
	{#State 108
		DEFAULT => -89
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
		DEFAULT => -92
	},
	{#State 110
		ACTIONS => {
			"and" => 140
		},
		DEFAULT => -87
	},
	{#State 111
		ACTIONS => {
			"or" => 141
		},
		DEFAULT => -85
	},
	{#State 112
		ACTIONS => {
			"!=" => 150,
			"<" => 143,
			"\@\@" => 142,
			"like" => 144,
			"=" => 151,
			">=" => 145,
			"<<=" => 152,
			">>=" => 146,
			"<<" => 153,
			"<=" => 154,
			">" => 155,
			">>" => 148,
			"<>" => 149
		},
		GOTOS => {
			'operator' => 147
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
			'expr' => 156,
			'atom' => 16,
			'condition' => 157,
			'column' => 17
		}
	},
	{#State 114
		DEFAULT => -84
	},
	{#State 115
		ACTIONS => {
			"," => 158
		},
		DEFAULT => -15
	},
	{#State 116
		DEFAULT => -82
	},
	{#State 117
		DEFAULT => -16
	},
	{#State 118
		DEFAULT => -83
	},
	{#State 119
		DEFAULT => -4
	},
	{#State 120
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 159,
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
	{#State 121
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 80,
			'type' => 160
		}
	},
	{#State 122
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
	{#State 123
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 162,
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
	{#State 125
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
	{#State 126
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
	{#State 127
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
	{#State 128
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 169,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 167,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 168,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 170,
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
		DEFAULT => -38
	},
	{#State 130
		DEFAULT => -37
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
			'parameter_list' => 171
		}
	},
	{#State 132
		ACTIONS => {
			"-" => 120,
			"::" => 121,
			"||" => 126,
			"+" => 122,
			"/" => 127,
			"%" => 123,
			"^" => 124,
			"*" => 125,
			")" => 172
		}
	},
	{#State 133
		ACTIONS => {
			'IDENT' => 95
		}
	},
	{#State 134
		ACTIONS => {
			'NUM' => 97,
			'STRING' => 96
		}
	},
	{#State 135
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'order_by_objects' => 173,
			'column' => 103,
			'qualified_symbol' => 11,
			'order_by_object' => 101
		}
	},
	{#State 136
		DEFAULT => -122
	},
	{#State 137
		DEFAULT => -121
	},
	{#State 138
		DEFAULT => -119
	},
	{#State 139
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'symbol' => 18,
			'column_list' => 174,
			'column' => 105,
			'qualified_symbol' => 11
		}
	},
	{#State 140
		ACTIONS => {
			'NUM' => 13,
			"(" => 113,
			'VAR' => 25,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 108,
			'conjunction' => 175,
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
			'true_literal' => 19,
			'symbol' => 18,
			'conjunction' => 110,
			'number' => 8,
			'string' => 9,
			'disjunction' => 176,
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
		DEFAULT => -104
	},
	{#State 143
		DEFAULT => -99
	},
	{#State 144
		DEFAULT => -103
	},
	{#State 145
		DEFAULT => -97
	},
	{#State 146
		DEFAULT => -107
	},
	{#State 147
		ACTIONS => {
			'NUM' => 13,
			"(" => 179,
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
			'rhs_atom' => 178,
			'column' => 69
		}
	},
	{#State 148
		DEFAULT => -108
	},
	{#State 149
		DEFAULT => -100
	},
	{#State 150
		DEFAULT => -101
	},
	{#State 151
		DEFAULT => -102
	},
	{#State 152
		DEFAULT => -105
	},
	{#State 153
		DEFAULT => -106
	},
	{#State 154
		DEFAULT => -98
	},
	{#State 155
		DEFAULT => -96
	},
	{#State 156
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
		DEFAULT => -92
	},
	{#State 157
		ACTIONS => {
			")" => 180
		}
	},
	{#State 158
		ACTIONS => {
			'VAR' => 81,
			'IDENT' => 79
		},
		GOTOS => {
			'models' => 181,
			'symbol' => 117,
			'model' => 115
		}
	},
	{#State 159
		ACTIONS => {
			"::" => 121,
			"%" => 123,
			"^" => 124,
			"*" => 125,
			"||" => 126,
			"/" => 127
		},
		DEFAULT => -47
	},
	{#State 160
		DEFAULT => -49
	},
	{#State 161
		ACTIONS => {
			"::" => 121,
			"%" => 123,
			"^" => 124,
			"*" => 125,
			"||" => 126,
			"/" => 127
		},
		DEFAULT => -46
	},
	{#State 162
		ACTIONS => {
			"::" => 121,
			"^" => 124,
			"||" => 126
		},
		DEFAULT => -45
	},
	{#State 163
		ACTIONS => {
			"::" => 121,
			"^" => 124,
			"||" => 126
		},
		DEFAULT => -48
	},
	{#State 164
		ACTIONS => {
			"::" => 121,
			"^" => 124,
			"||" => 126
		},
		DEFAULT => -43
	},
	{#State 165
		ACTIONS => {
			"::" => 121
		},
		DEFAULT => -42
	},
	{#State 166
		ACTIONS => {
			"::" => 121,
			"^" => 124,
			"||" => 126
		},
		DEFAULT => -44
	},
	{#State 167
		ACTIONS => {
			"-" => 120,
			"::" => 121,
			"||" => 126,
			"+" => 122,
			"/" => 127,
			"%" => 123,
			"^" => 124,
			"*" => 125
		},
		DEFAULT => -60
	},
	{#State 168
		ACTIONS => {
			"," => 182
		},
		DEFAULT => -59
	},
	{#State 169
		ACTIONS => {
			")" => 183
		}
	},
	{#State 170
		ACTIONS => {
			")" => 184
		}
	},
	{#State 171
		DEFAULT => -39
	},
	{#State 172
		DEFAULT => -50
	},
	{#State 173
		DEFAULT => -117
	},
	{#State 174
		DEFAULT => -114
	},
	{#State 175
		DEFAULT => -88
	},
	{#State 176
		DEFAULT => -86
	},
	{#State 177
		ACTIONS => {
			"-" => 120,
			"::" => 121,
			"+" => 122,
			"%" => 123,
			"^" => 124,
			"*" => 125,
			"||" => 126,
			"/" => 127
		},
		DEFAULT => -94
	},
	{#State 178
		DEFAULT => -90
	},
	{#State 179
		ACTIONS => {
			'NUM' => 13,
			"(" => 189,
			'VAR' => 77,
			'IDENT' => 185,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 132,
			'comparison' => 108,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 109,
			'atom' => 16,
			'column' => 186,
			'conjunction' => 110,
			'symbol' => 18,
			'true_literal' => 187,
			'atom2' => 72,
			'disjunction' => 111,
			'proc_call' => 21,
			'true_number' => 188,
			'proc_call2' => 75,
			'lhs_atom' => 112,
			'condition' => 190
		}
	},
	{#State 180
		ACTIONS => {
			'' => -91,
			"or" => -91,
			"order by" => -91,
			"limit" => -91,
			";" => -91,
			"group by" => -91,
			"offset" => -91,
			")" => -91,
			"where" => -91,
			"from" => -91,
			"and" => -91
		},
		DEFAULT => -93
	},
	{#State 181
		DEFAULT => -14
	},
	{#State 182
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
			'parameter2' => 168,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 191,
			'atom2' => 72,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 73,
			'literal' => 67,
			'proc_call2' => 75,
			'column' => 69
		}
	},
	{#State 183
		DEFAULT => -57
	},
	{#State 184
		DEFAULT => -56
	},
	{#State 185
		ACTIONS => {
			"(" => 192
		},
		DEFAULT => -70
	},
	{#State 186
		DEFAULT => -34
	},
	{#State 187
		DEFAULT => -35
	},
	{#State 188
		DEFAULT => -36
	},
	{#State 189
		ACTIONS => {
			'NUM' => 13,
			"(" => 189,
			'VAR' => 77,
			'IDENT' => 185,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 132,
			'comparison' => 108,
			'number' => 8,
			'variable' => 65,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 67,
			'expr' => 156,
			'atom' => 16,
			'column' => 186,
			'conjunction' => 110,
			'symbol' => 18,
			'true_literal' => 187,
			'atom2' => 72,
			'disjunction' => 111,
			'proc_call' => 21,
			'true_number' => 188,
			'proc_call2' => 75,
			'lhs_atom' => 112,
			'condition' => 157
		}
	},
	{#State 190
		ACTIONS => {
			")" => 193
		}
	},
	{#State 191
		DEFAULT => -58
	},
	{#State 192
		ACTIONS => {
			'NUM' => 13,
			"(" => 76,
			"*" => 195,
			'VAR' => 77,
			'IDENT' => 66,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 194,
			'symbol' => 18,
			'true_literal' => 71,
			'parameter2' => 168,
			'number' => 8,
			'variable' => 65,
			'parameter_list2' => 170,
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
	{#State 193
		DEFAULT => -95
	},
	{#State 194
		ACTIONS => {
			"-" => 120,
			"::" => 121,
			"||" => 126,
			"+" => 122,
			"/" => 127,
			"%" => 123,
			"^" => 124,
			"*" => 125
		},
		DEFAULT => -41
	},
	{#State 195
		ACTIONS => {
			")" => 196
		}
	},
	{#State 196
		DEFAULT => -38
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
#line 29 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 5
		 'compound_select_stmt', 3,
sub
#line 31 "grammar/view-upgrade.yp"
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
#line 39 "grammar/view-upgrade.yp"
{ "select distinct $_[3]\n$_[4]" }
	],
	[#Rule 12
		 'select_stmt', 3,
sub
#line 41 "grammar/view-upgrade.yp"
{ "select $_[2]\n$_[3]" }
	],
	[#Rule 13
		 'select_stmt', 2,
sub
#line 43 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 14
		 'models', 3,
sub
#line 47 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 15
		 'models', 1, undef
	],
	[#Rule 16
		 'model', 1, undef
	],
	[#Rule 17
		 'pattern_list', 3,
sub
#line 55 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 18
		 'pattern_list', 1, undef
	],
	[#Rule 19
		 'pattern', 3,
sub
#line 60 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 20
		 'pattern', 1, undef
	],
	[#Rule 21
		 'pattern', 1, undef
	],
	[#Rule 22
		 'expr', 3,
sub
#line 66 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'expr', 3,
sub
#line 68 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'expr', 3,
sub
#line 70 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'expr', 3,
sub
#line 72 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'expr', 3,
sub
#line 74 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 27
		 'expr', 3,
sub
#line 76 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'expr', 3,
sub
#line 78 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'expr', 3,
sub
#line 80 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'expr', 3,
sub
#line 82 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 31
		 'expr', 1, undef
	],
	[#Rule 32
		 'type', 1, undef
	],
	[#Rule 33
		 'atom', 1, undef
	],
	[#Rule 34
		 'atom', 1, undef
	],
	[#Rule 35
		 'atom', 1, undef
	],
	[#Rule 36
		 'atom', 1, undef
	],
	[#Rule 37
		 'proc_call', 4,
sub
#line 96 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 38
		 'proc_call', 4,
sub
#line 98 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 39
		 'parameter_list', 3,
sub
#line 102 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 40
		 'parameter_list', 1, undef
	],
	[#Rule 41
		 'parameter', 1, undef
	],
	[#Rule 42
		 'expr2', 3,
sub
#line 110 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 43
		 'expr2', 3,
sub
#line 112 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 44
		 'expr2', 3,
sub
#line 114 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 45
		 'expr2', 3,
sub
#line 116 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 46
		 'expr2', 3,
sub
#line 118 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'expr2', 3,
sub
#line 120 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'expr2', 3,
sub
#line 122 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'expr2', 3,
sub
#line 124 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'expr2', 3,
sub
#line 126 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'expr2', 1, undef
	],
	[#Rule 52
		 'atom2', 1, undef
	],
	[#Rule 53
		 'atom2', 1, undef
	],
	[#Rule 54
		 'atom2', 1, undef
	],
	[#Rule 55
		 'atom2', 1, undef
	],
	[#Rule 56
		 'proc_call2', 4,
sub
#line 137 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'proc_call2', 4,
sub
#line 139 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'parameter_list2', 3,
sub
#line 143 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 59
		 'parameter_list2', 1, undef
	],
	[#Rule 60
		 'parameter2', 1, undef
	],
	[#Rule 61
		 'variable', 1,
sub
#line 152 "grammar/view-upgrade.yp"
{
                push @Vars, [$_[1], 'literal'];
                $_[1];
            }
	],
	[#Rule 62
		 'true_number', 1, undef
	],
	[#Rule 63
		 'number', 1, undef
	],
	[#Rule 64
		 'number', 3,
sub
#line 163 "grammar/view-upgrade.yp"
{
                push @Vars, [$_[1], 'literal', $_[3]];
                $_[1];
            }
	],
	[#Rule 65
		 'string', 1, undef
	],
	[#Rule 66
		 'string', 3,
sub
#line 171 "grammar/view-upgrade.yp"
{
                push @Vars, [$_[1], 'literal', parse_string($_[3])];
                $_[1];
          }
	],
	[#Rule 67
		 'column', 1, undef
	],
	[#Rule 68
		 'column', 1, undef
	],
	[#Rule 69
		 'qualified_symbol', 3, undef
	],
	[#Rule 70
		 'symbol', 1, undef
	],
	[#Rule 71
		 'symbol', 3,
sub
#line 186 "grammar/view-upgrade.yp"
{
                push @Vars, [$_[1], 'symbol', $_[3]];
                $_[1];
          }
	],
	[#Rule 72
		 'symbol', 1,
sub
#line 191 "grammar/view-upgrade.yp"
{
                push @Vars, [$_[1], 'symbol'];
                $_[1];
          }
	],
	[#Rule 73
		 'alias', 1, undef
	],
	[#Rule 74
		 'postfix_clause_list', 2,
sub
#line 201 "grammar/view-upgrade.yp"
{ join("\n", @_[1..$#_]) }
	],
	[#Rule 75
		 'postfix_clause_list', 1, undef
	],
	[#Rule 76
		 'postfix_clause', 1, undef
	],
	[#Rule 77
		 'postfix_clause', 1, undef
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
		 'from_clause', 2,
sub
#line 214 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 83
		 'from_clause', 2,
sub
#line 216 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 84
		 'where_clause', 2,
sub
#line 220 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 85
		 'condition', 1, undef
	],
	[#Rule 86
		 'disjunction', 3,
sub
#line 227 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 87
		 'disjunction', 1, undef
	],
	[#Rule 88
		 'conjunction', 3,
sub
#line 232 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 89
		 'conjunction', 1, undef
	],
	[#Rule 90
		 'comparison', 3,
sub
#line 237 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 91
		 'comparison', 3,
sub
#line 239 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 92
		 'lhs_atom', 1, undef
	],
	[#Rule 93
		 'lhs_atom', 3, undef
	],
	[#Rule 94
		 'rhs_atom', 1, undef
	],
	[#Rule 95
		 'rhs_atom', 3, undef
	],
	[#Rule 96
		 'operator', 1, undef
	],
	[#Rule 97
		 'operator', 1, undef
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
		 'true_literal', 1, undef
	],
	[#Rule 110
		 'true_literal', 1, undef
	],
	[#Rule 111
		 'literal', 1, undef
	],
	[#Rule 112
		 'literal', 1, undef
	],
	[#Rule 113
		 'group_by_clause', 2,
sub
#line 276 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 114
		 'column_list', 3,
sub
#line 280 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 115
		 'column_list', 1, undef
	],
	[#Rule 116
		 'order_by_clause', 2,
sub
#line 285 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 117
		 'order_by_objects', 3,
sub
#line 289 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 118
		 'order_by_objects', 1, undef
	],
	[#Rule 119
		 'order_by_object', 2,
sub
#line 294 "grammar/view-upgrade.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 120
		 'order_by_object', 1, undef
	],
	[#Rule 121
		 'order_by_modifier', 1, undef
	],
	[#Rule 122
		 'order_by_modifier', 1, undef
	],
	[#Rule 123
		 'limit_clause', 2,
sub
#line 302 "grammar/view-upgrade.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 124
		 'offset_clause', 2,
sub
#line 306 "grammar/view-upgrade.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 309 "grammar/view-upgrade.yp"


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
        s/^(\$\w+)//s
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
    my ($self, $sql) = @_;
    open my $source, '<', \$sql;
    my $yydata = $self->YYData;
    $yydata->{source} = $source;

    #$QuoteIdent = $params->{quote_ident};

    #$self->YYData->{INPUT} = ;
    ### $sql
    @Vars = ();
    $sql = $self->YYParse( yydebug => 0 & 0x1F, yylex => \&_Lexer, yyerror => \&_Error );
    close $source;
    return {
        vars => \@Vars,
        newdef => $sql . "\n",
    };
}

sub _IDENT {
    (defined $_[0] && $_[0] =~ /^[A-Za-z]\w*$/) ? $_[0] : undef;
}

#my ($select) =new Select;
#my $var = $select->Run;

1;


1;
