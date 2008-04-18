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
			"(" => 22,
			"*" => 15,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'symbol' => 19,
			'true_literal' => 18,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'pattern' => 23,
			'expr' => 14,
			'atom' => 16,
			'pattern_list' => 25,
			'column' => 17
		}
	},
	{#State 5
		ACTIONS => {
			";" => 26
		},
		DEFAULT => -3
	},
	{#State 6
		ACTIONS => {
			'' => 27
		}
	},
	{#State 7
		ACTIONS => {
			")" => 28
		}
	},
	{#State 8
		DEFAULT => -103
	},
	{#State 9
		DEFAULT => -102
	},
	{#State 10
		ACTIONS => {
			"(" => 29
		},
		DEFAULT => -69
	},
	{#State 11
		DEFAULT => -66
	},
	{#State 12
		DEFAULT => -64
	},
	{#State 13
		DEFAULT => -61
	},
	{#State 14
		ACTIONS => {
			"-" => 30,
			"::" => 31,
			"+" => 32,
			"%" => 33,
			"^" => 34,
			"*" => 35,
			"||" => 36,
			"/" => 37,
			"as" => 38
		},
		DEFAULT => -19
	},
	{#State 15
		DEFAULT => -20
	},
	{#State 16
		DEFAULT => -30
	},
	{#State 17
		DEFAULT => -33
	},
	{#State 18
		DEFAULT => -34
	},
	{#State 19
		ACTIONS => {
			"." => 39
		},
		DEFAULT => -67
	},
	{#State 20
		DEFAULT => -32
	},
	{#State 21
		DEFAULT => -35
	},
	{#State 22
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 40,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 23
		ACTIONS => {
			"," => 41
		},
		DEFAULT => -17
	},
	{#State 24
		ACTIONS => {
			"|" => 42
		},
		DEFAULT => -71
	},
	{#State 25
		ACTIONS => {
			"where" => 54,
			"order by" => 46,
			"limit" => 45,
			"group by" => 49,
			"from" => 56,
			"offset" => 51
		},
		DEFAULT => -12,
		GOTOS => {
			'postfix_clause_list' => 55,
			'order_by_clause' => 44,
			'offset_clause' => 43,
			'where_clause' => 47,
			'group_by_clause' => 48,
			'from_clause' => 50,
			'limit_clause' => 52,
			'postfix_clause' => 53
		}
	},
	{#State 26
		DEFAULT => -2
	},
	{#State 27
		DEFAULT => 0
	},
	{#State 28
		ACTIONS => {
			"intersect" => 59,
			"union" => 57,
			"except" => 60,
			"union all" => 61
		},
		DEFAULT => -5,
		GOTOS => {
			'set_operator' => 58
		}
	},
	{#State 29
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			"*" => 66,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 62,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'parameter' => 72,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67,
			'parameter_list' => 68
		}
	},
	{#State 30
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 76,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 31
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 78,
			'type' => 80
		}
	},
	{#State 32
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 81,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 33
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 82,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 34
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 83,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 35
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 84,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 36
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 85,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 37
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'expr' => 86,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 38
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 87,
			'alias' => 88
		}
	},
	{#State 39
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 89
		}
	},
	{#State 40
		ACTIONS => {
			"-" => 30,
			"::" => 31,
			"||" => 36,
			"+" => 32,
			"/" => 37,
			"%" => 33,
			"^" => 34,
			"*" => 35,
			")" => 90
		}
	},
	{#State 41
		ACTIONS => {
			'NUM' => 13,
			"(" => 22,
			"*" => 15,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'pattern' => 23,
			'expr' => 14,
			'atom' => 16,
			'pattern_list' => 91,
			'column' => 17
		}
	},
	{#State 42
		ACTIONS => {
			'NUM' => 94,
			'IDENT' => 92,
			'STRING' => 93
		}
	},
	{#State 43
		DEFAULT => -79
	},
	{#State 44
		DEFAULT => -77
	},
	{#State 45
		ACTIONS => {
			'NUM' => 95,
			'VAR' => 97,
			'STRING' => 12
		},
		GOTOS => {
			'literal' => 96,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'string' => 9
		}
	},
	{#State 46
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 19,
			'order_by_objects' => 99,
			'column' => 100,
			'qualified_symbol' => 11,
			'order_by_object' => 98
		}
	},
	{#State 47
		DEFAULT => -75
	},
	{#State 48
		DEFAULT => -76
	},
	{#State 49
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 101,
			'column' => 102,
			'qualified_symbol' => 11
		}
	},
	{#State 50
		DEFAULT => -80
	},
	{#State 51
		ACTIONS => {
			'NUM' => 95,
			'VAR' => 97,
			'STRING' => 12
		},
		GOTOS => {
			'literal' => 103,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'string' => 9
		}
	},
	{#State 52
		DEFAULT => -78
	},
	{#State 53
		ACTIONS => {
			"where" => 54,
			"order by" => 46,
			"limit" => 45,
			"group by" => 49,
			"from" => 56,
			"offset" => 51
		},
		DEFAULT => -74,
		GOTOS => {
			'postfix_clause_list' => 104,
			'order_by_clause' => 44,
			'offset_clause' => 43,
			'where_clause' => 47,
			'group_by_clause' => 48,
			'from_clause' => 50,
			'limit_clause' => 52,
			'postfix_clause' => 53
		}
	},
	{#State 54
		ACTIONS => {
			'NUM' => 13,
			"(" => 110,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 105,
			'true_literal' => 18,
			'symbol' => 19,
			'conjunction' => 107,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'disjunction' => 108,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'lhs_atom' => 109,
			'expr' => 106,
			'atom' => 16,
			'condition' => 111,
			'column' => 17
		}
	},
	{#State 55
		DEFAULT => -11
	},
	{#State 56
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 10
		},
		GOTOS => {
			'models' => 113,
			'symbol' => 114,
			'model' => 112,
			'proc_call' => 115
		}
	},
	{#State 57
		DEFAULT => -8
	},
	{#State 58
		ACTIONS => {
			"(" => 2,
			"select" => 4
		},
		GOTOS => {
			'select_stmt' => 1,
			'compound_select_stmt' => 116
		}
	},
	{#State 59
		DEFAULT => -9
	},
	{#State 60
		DEFAULT => -10
	},
	{#State 61
		DEFAULT => -7
	},
	{#State 62
		ACTIONS => {
			"-" => 117,
			"::" => 118,
			"||" => 123,
			"+" => 119,
			"/" => 124,
			"%" => 120,
			"^" => 121,
			"*" => 122
		},
		DEFAULT => -40
	},
	{#State 63
		DEFAULT => -105
	},
	{#State 64
		ACTIONS => {
			"(" => 125
		},
		DEFAULT => -69
	},
	{#State 65
		DEFAULT => -53
	},
	{#State 66
		ACTIONS => {
			")" => 126
		}
	},
	{#State 67
		DEFAULT => -52
	},
	{#State 68
		ACTIONS => {
			")" => 127
		}
	},
	{#State 69
		DEFAULT => -104
	},
	{#State 70
		DEFAULT => -50
	},
	{#State 71
		DEFAULT => -54
	},
	{#State 72
		ACTIONS => {
			"," => 128
		},
		DEFAULT => -39
	},
	{#State 73
		DEFAULT => -51
	},
	{#State 74
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 129,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 75
		ACTIONS => {
			"<" => -71,
			"like" => -71,
			">=" => -71,
			"<>" => -71,
			"=" => -71,
			"|" => 42,
			"<=" => -71,
			"." => -71,
			">" => -71
		},
		DEFAULT => -60
	},
	{#State 76
		ACTIONS => {
			"::" => 31,
			"%" => 33,
			"^" => 34,
			"*" => 35,
			"||" => 36,
			"/" => 37
		},
		DEFAULT => -26
	},
	{#State 77
		DEFAULT => -69
	},
	{#State 78
		DEFAULT => -31
	},
	{#State 79
		ACTIONS => {
			"|" => 130
		},
		DEFAULT => -71
	},
	{#State 80
		DEFAULT => -28
	},
	{#State 81
		ACTIONS => {
			"::" => 31,
			"%" => 33,
			"^" => 34,
			"*" => 35,
			"||" => 36,
			"/" => 37
		},
		DEFAULT => -25
	},
	{#State 82
		ACTIONS => {
			"::" => 31,
			"^" => 34,
			"||" => 36
		},
		DEFAULT => -24
	},
	{#State 83
		ACTIONS => {
			"::" => 31,
			"^" => 34,
			"||" => 36
		},
		DEFAULT => -27
	},
	{#State 84
		ACTIONS => {
			"::" => 31,
			"^" => 34,
			"||" => 36
		},
		DEFAULT => -22
	},
	{#State 85
		ACTIONS => {
			"::" => 31
		},
		DEFAULT => -21
	},
	{#State 86
		ACTIONS => {
			"::" => 31,
			"^" => 34,
			"||" => 36
		},
		DEFAULT => -23
	},
	{#State 87
		DEFAULT => -72
	},
	{#State 88
		DEFAULT => -18
	},
	{#State 89
		DEFAULT => -68
	},
	{#State 90
		DEFAULT => -29
	},
	{#State 91
		DEFAULT => -16
	},
	{#State 92
		DEFAULT => -70
	},
	{#State 93
		DEFAULT => -65
	},
	{#State 94
		DEFAULT => -63
	},
	{#State 95
		DEFAULT => -62
	},
	{#State 96
		DEFAULT => -116
	},
	{#State 97
		ACTIONS => {
			"|" => 131
		},
		DEFAULT => -60
	},
	{#State 98
		ACTIONS => {
			"," => 132
		},
		DEFAULT => -111
	},
	{#State 99
		DEFAULT => -109
	},
	{#State 100
		ACTIONS => {
			"desc" => 133,
			"asc" => 134
		},
		DEFAULT => -113,
		GOTOS => {
			'order_by_modifier' => 135
		}
	},
	{#State 101
		DEFAULT => -106
	},
	{#State 102
		ACTIONS => {
			"," => 136
		},
		DEFAULT => -108
	},
	{#State 103
		DEFAULT => -117
	},
	{#State 104
		DEFAULT => -73
	},
	{#State 105
		ACTIONS => {
			"and" => 137
		},
		DEFAULT => -88
	},
	{#State 106
		ACTIONS => {
			"-" => 30,
			"::" => 31,
			"+" => 32,
			"%" => 33,
			"^" => 34,
			"*" => 35,
			"||" => 36,
			"/" => 37
		},
		DEFAULT => -91
	},
	{#State 107
		ACTIONS => {
			"or" => 138
		},
		DEFAULT => -86
	},
	{#State 108
		DEFAULT => -84
	},
	{#State 109
		ACTIONS => {
			"<" => 139,
			"like" => 140,
			"<=" => 145,
			">" => 146,
			"=" => 144,
			"<>" => 143,
			">=" => 141
		},
		GOTOS => {
			'operator' => 142
		}
	},
	{#State 110
		ACTIONS => {
			'NUM' => 13,
			"(" => 110,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 105,
			'true_literal' => 18,
			'symbol' => 19,
			'conjunction' => 107,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'disjunction' => 108,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'lhs_atom' => 109,
			'expr' => 147,
			'atom' => 16,
			'condition' => 148,
			'column' => 17
		}
	},
	{#State 111
		DEFAULT => -83
	},
	{#State 112
		ACTIONS => {
			"," => 149
		},
		DEFAULT => -14
	},
	{#State 113
		DEFAULT => -81
	},
	{#State 114
		DEFAULT => -15
	},
	{#State 115
		DEFAULT => -82
	},
	{#State 116
		DEFAULT => -4
	},
	{#State 117
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 150,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 118
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 78,
			'type' => 151
		}
	},
	{#State 119
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 152,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 120
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 153,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 121
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 154,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 122
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 155,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 123
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 156,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 124
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 157,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 125
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			"*" => 160,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 158,
			'symbol' => 19,
			'true_literal' => 69,
			'parameter2' => 159,
			'number' => 8,
			'variable' => 63,
			'parameter_list2' => 161,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 126
		DEFAULT => -37
	},
	{#State 127
		DEFAULT => -36
	},
	{#State 128
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 62,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'parameter' => 72,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67,
			'parameter_list' => 162
		}
	},
	{#State 129
		ACTIONS => {
			"-" => 117,
			"::" => 118,
			"||" => 123,
			"+" => 119,
			"/" => 124,
			"%" => 120,
			"^" => 121,
			"*" => 122,
			")" => 163
		}
	},
	{#State 130
		ACTIONS => {
			'IDENT' => 92
		}
	},
	{#State 131
		ACTIONS => {
			'NUM' => 94,
			'STRING' => 93
		}
	},
	{#State 132
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 19,
			'order_by_objects' => 164,
			'column' => 100,
			'qualified_symbol' => 11,
			'order_by_object' => 98
		}
	},
	{#State 133
		DEFAULT => -115
	},
	{#State 134
		DEFAULT => -114
	},
	{#State 135
		DEFAULT => -112
	},
	{#State 136
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'symbol' => 19,
			'column_list' => 165,
			'column' => 102,
			'qualified_symbol' => 11
		}
	},
	{#State 137
		ACTIONS => {
			'NUM' => 13,
			"(" => 110,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 166,
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'lhs_atom' => 109,
			'expr' => 106,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 138
		ACTIONS => {
			'NUM' => 13,
			"(" => 110,
			'VAR' => 24,
			'IDENT' => 10,
			'STRING' => 12
		},
		GOTOS => {
			'comparison' => 105,
			'conjunction' => 167,
			'true_literal' => 18,
			'symbol' => 19,
			'number' => 8,
			'string' => 9,
			'proc_call' => 20,
			'qualified_symbol' => 11,
			'true_number' => 21,
			'lhs_atom' => 109,
			'expr' => 106,
			'atom' => 16,
			'column' => 17
		}
	},
	{#State 139
		DEFAULT => -98
	},
	{#State 140
		DEFAULT => -101
	},
	{#State 141
		DEFAULT => -96
	},
	{#State 142
		ACTIONS => {
			'NUM' => 13,
			"(" => 170,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 168,
			'symbol' => 19,
			'true_literal' => 69,
			'number' => 8,
			'variable' => 63,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'rhs_atom' => 169,
			'column' => 67
		}
	},
	{#State 143
		DEFAULT => -99
	},
	{#State 144
		DEFAULT => -100
	},
	{#State 145
		DEFAULT => -97
	},
	{#State 146
		DEFAULT => -95
	},
	{#State 147
		ACTIONS => {
			"-" => 30,
			"::" => 31,
			"+" => 32,
			"%" => 33,
			"^" => 34,
			"*" => 35,
			")" => 90,
			"||" => 36,
			"/" => 37
		},
		DEFAULT => -91
	},
	{#State 148
		ACTIONS => {
			")" => 171
		}
	},
	{#State 149
		ACTIONS => {
			'VAR' => 79,
			'IDENT' => 77
		},
		GOTOS => {
			'models' => 172,
			'symbol' => 114,
			'model' => 112
		}
	},
	{#State 150
		ACTIONS => {
			"::" => 118,
			"%" => 120,
			"^" => 121,
			"*" => 122,
			"||" => 123,
			"/" => 124
		},
		DEFAULT => -46
	},
	{#State 151
		DEFAULT => -48
	},
	{#State 152
		ACTIONS => {
			"::" => 118,
			"%" => 120,
			"^" => 121,
			"*" => 122,
			"||" => 123,
			"/" => 124
		},
		DEFAULT => -45
	},
	{#State 153
		ACTIONS => {
			"::" => 118,
			"^" => 121,
			"||" => 123
		},
		DEFAULT => -44
	},
	{#State 154
		ACTIONS => {
			"::" => 118,
			"^" => 121,
			"||" => 123
		},
		DEFAULT => -47
	},
	{#State 155
		ACTIONS => {
			"::" => 118,
			"^" => 121,
			"||" => 123
		},
		DEFAULT => -42
	},
	{#State 156
		ACTIONS => {
			"::" => 118
		},
		DEFAULT => -41
	},
	{#State 157
		ACTIONS => {
			"::" => 118,
			"^" => 121,
			"||" => 123
		},
		DEFAULT => -43
	},
	{#State 158
		ACTIONS => {
			"-" => 117,
			"::" => 118,
			"||" => 123,
			"+" => 119,
			"/" => 124,
			"%" => 120,
			"^" => 121,
			"*" => 122
		},
		DEFAULT => -59
	},
	{#State 159
		ACTIONS => {
			"," => 173
		},
		DEFAULT => -58
	},
	{#State 160
		ACTIONS => {
			")" => 174
		}
	},
	{#State 161
		ACTIONS => {
			")" => 175
		}
	},
	{#State 162
		DEFAULT => -38
	},
	{#State 163
		DEFAULT => -49
	},
	{#State 164
		DEFAULT => -110
	},
	{#State 165
		DEFAULT => -107
	},
	{#State 166
		DEFAULT => -87
	},
	{#State 167
		DEFAULT => -85
	},
	{#State 168
		ACTIONS => {
			"-" => 117,
			"::" => 118,
			"+" => 119,
			"%" => 120,
			"^" => 121,
			"*" => 122,
			"||" => 123,
			"/" => 124
		},
		DEFAULT => -93
	},
	{#State 169
		DEFAULT => -89
	},
	{#State 170
		ACTIONS => {
			'NUM' => 13,
			"(" => 180,
			'VAR' => 75,
			'IDENT' => 176,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 129,
			'comparison' => 105,
			'number' => 8,
			'variable' => 63,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 65,
			'expr' => 106,
			'atom' => 16,
			'column' => 177,
			'conjunction' => 107,
			'symbol' => 19,
			'true_literal' => 178,
			'atom2' => 70,
			'disjunction' => 108,
			'proc_call' => 20,
			'true_number' => 179,
			'proc_call2' => 73,
			'lhs_atom' => 109,
			'condition' => 181
		}
	},
	{#State 171
		ACTIONS => {
			"<" => -92,
			"like" => -92,
			">=" => -92,
			"<>" => -92,
			"=" => -92,
			"<=" => -92,
			">" => -92
		},
		DEFAULT => -90
	},
	{#State 172
		DEFAULT => -13
	},
	{#State 173
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 158,
			'symbol' => 19,
			'true_literal' => 69,
			'parameter2' => 159,
			'number' => 8,
			'variable' => 63,
			'parameter_list2' => 182,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'column' => 67
		}
	},
	{#State 174
		DEFAULT => -56
	},
	{#State 175
		DEFAULT => -55
	},
	{#State 176
		ACTIONS => {
			"(" => 183
		},
		DEFAULT => -69
	},
	{#State 177
		DEFAULT => -33
	},
	{#State 178
		DEFAULT => -34
	},
	{#State 179
		DEFAULT => -35
	},
	{#State 180
		ACTIONS => {
			'NUM' => 13,
			"(" => 180,
			'VAR' => 75,
			'IDENT' => 176,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 129,
			'comparison' => 105,
			'number' => 8,
			'variable' => 63,
			'string' => 9,
			'qualified_symbol' => 11,
			'literal' => 65,
			'expr' => 147,
			'atom' => 16,
			'column' => 177,
			'conjunction' => 107,
			'symbol' => 19,
			'true_literal' => 178,
			'atom2' => 70,
			'disjunction' => 108,
			'proc_call' => 20,
			'true_number' => 179,
			'proc_call2' => 73,
			'lhs_atom' => 109,
			'condition' => 148
		}
	},
	{#State 181
		ACTIONS => {
			")" => 184
		}
	},
	{#State 182
		DEFAULT => -57
	},
	{#State 183
		ACTIONS => {
			'NUM' => 13,
			"(" => 74,
			"*" => 186,
			'VAR' => 75,
			'IDENT' => 64,
			'STRING' => 12
		},
		GOTOS => {
			'expr2' => 185,
			'symbol' => 19,
			'true_literal' => 69,
			'parameter2' => 159,
			'number' => 8,
			'variable' => 63,
			'parameter_list2' => 161,
			'atom2' => 70,
			'string' => 9,
			'qualified_symbol' => 11,
			'parameter' => 72,
			'true_number' => 71,
			'literal' => 65,
			'proc_call2' => 73,
			'parameter_list' => 68,
			'column' => 67
		}
	},
	{#State 184
		DEFAULT => -94
	},
	{#State 185
		ACTIONS => {
			"-" => 117,
			"::" => 118,
			"||" => 123,
			"+" => 119,
			"/" => 124,
			"%" => 120,
			"^" => 121,
			"*" => 122
		},
		DEFAULT => -40
	},
	{#State 186
		ACTIONS => {
			")" => 187
		}
	},
	{#State 187
		DEFAULT => -37
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
		 'select_stmt', 3,
sub
#line 43 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 12
		 'select_stmt', 2,
sub
#line 45 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 13
		 'models', 3,
sub
#line 49 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 14
		 'models', 1, undef
	],
	[#Rule 15
		 'model', 1,
sub
#line 53 "grammar/restyscript-view.yp"
{ push @Models, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 16
		 'pattern_list', 3,
sub
#line 57 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'pattern_list', 1, undef
	],
	[#Rule 18
		 'pattern', 3,
sub
#line 62 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 19
		 'pattern', 1, undef
	],
	[#Rule 20
		 'pattern', 1, undef
	],
	[#Rule 21
		 'expr', 3,
sub
#line 68 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 22
		 'expr', 3,
sub
#line 70 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'expr', 3,
sub
#line 72 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'expr', 3,
sub
#line 74 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 25
		 'expr', 3,
sub
#line 76 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 26
		 'expr', 3,
sub
#line 78 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 27
		 'expr', 3,
sub
#line 80 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 28
		 'expr', 3,
sub
#line 82 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 29
		 'expr', 3,
sub
#line 84 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 30
		 'expr', 1, undef
	],
	[#Rule 31
		 'type', 1, undef
	],
	[#Rule 32
		 'atom', 1, undef
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
		 'proc_call', 4,
sub
#line 98 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 37
		 'proc_call', 4,
sub
#line 100 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 38
		 'parameter_list', 3,
sub
#line 104 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 39
		 'parameter_list', 1, undef
	],
	[#Rule 40
		 'parameter', 1, undef
	],
	[#Rule 41
		 'expr2', 3,
sub
#line 112 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 42
		 'expr2', 3,
sub
#line 114 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 43
		 'expr2', 3,
sub
#line 116 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 44
		 'expr2', 3,
sub
#line 118 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 45
		 'expr2', 3,
sub
#line 120 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 46
		 'expr2', 3,
sub
#line 122 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'expr2', 3,
sub
#line 124 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'expr2', 3,
sub
#line 126 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'expr2', 3,
sub
#line 128 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'expr2', 1, undef
	],
	[#Rule 51
		 'atom2', 1, undef
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
		 'proc_call2', 4,
sub
#line 139 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'proc_call2', 4,
sub
#line 141 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'parameter_list2', 3,
sub
#line 145 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'parameter_list2', 1, undef
	],
	[#Rule 59
		 'parameter2', 1, undef
	],
	[#Rule 60
		 'variable', 1,
sub
#line 154 "grammar/restyscript-view.yp"
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
	[#Rule 61
		 'true_number', 1, undef
	],
	[#Rule 62
		 'number', 1, undef
	],
	[#Rule 63
		 'number', 3,
sub
#line 170 "grammar/restyscript-view.yp"
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
	[#Rule 64
		 'string', 1,
sub
#line 182 "grammar/restyscript-view.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 65
		 'string', 3,
sub
#line 184 "grammar/restyscript-view.yp"
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
	[#Rule 66
		 'column', 1, undef
	],
	[#Rule 67
		 'column', 1,
sub
#line 196 "grammar/restyscript-view.yp"
{ push @Columns, $_[1]; $QuoteIdent->($_[1]) }
	],
	[#Rule 68
		 'qualified_symbol', 3,
sub
#line 200 "grammar/restyscript-view.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      $QuoteIdent->($_[1]).'.'.$QuoteIdent->($_[3]);
                    }
	],
	[#Rule 69
		 'symbol', 1, undef
	],
	[#Rule 70
		 'symbol', 3,
sub
#line 209 "grammar/restyscript-view.yp"
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
	[#Rule 71
		 'symbol', 1,
sub
#line 221 "grammar/restyscript-view.yp"
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
	[#Rule 72
		 'alias', 1, undef
	],
	[#Rule 73
		 'postfix_clause_list', 2,
sub
#line 237 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 74
		 'postfix_clause_list', 1, undef
	],
	[#Rule 75
		 'postfix_clause', 1, undef
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
		 'from_clause', 2,
sub
#line 250 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 82
		 'from_clause', 2,
sub
#line 252 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 83
		 'where_clause', 2,
sub
#line 256 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 84
		 'condition', 1, undef
	],
	[#Rule 85
		 'disjunction', 3,
sub
#line 263 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 86
		 'disjunction', 1, undef
	],
	[#Rule 87
		 'conjunction', 3,
sub
#line 268 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 88
		 'conjunction', 1, undef
	],
	[#Rule 89
		 'comparison', 3,
sub
#line 273 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 90
		 'comparison', 3,
sub
#line 275 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 91
		 'lhs_atom', 1, undef
	],
	[#Rule 92
		 'lhs_atom', 3, undef
	],
	[#Rule 93
		 'rhs_atom', 1, undef
	],
	[#Rule 94
		 'rhs_atom', 3, undef
	],
	[#Rule 95
		 'operator', 1, undef
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
		 'true_literal', 1, undef
	],
	[#Rule 103
		 'true_literal', 1, undef
	],
	[#Rule 104
		 'literal', 1, undef
	],
	[#Rule 105
		 'literal', 1, undef
	],
	[#Rule 106
		 'group_by_clause', 2,
sub
#line 305 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 107
		 'column_list', 3,
sub
#line 309 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 108
		 'column_list', 1, undef
	],
	[#Rule 109
		 'order_by_clause', 2,
sub
#line 314 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 110
		 'order_by_objects', 3,
sub
#line 318 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 111
		 'order_by_objects', 1, undef
	],
	[#Rule 112
		 'order_by_object', 2,
sub
#line 323 "grammar/restyscript-view.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 113
		 'order_by_object', 1, undef
	],
	[#Rule 114
		 'order_by_modifier', 1, undef
	],
	[#Rule 115
		 'order_by_modifier', 1, undef
	],
	[#Rule 116
		 'limit_clause', 2,
sub
#line 331 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 117
		 'offset_clause', 2,
sub
#line 335 "grammar/restyscript-view.yp"
{ delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 338 "grammar/restyscript-view.yp"


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
        s/^\s*(<=|>=|<>|\|\||::|like\b)//s
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


1;
