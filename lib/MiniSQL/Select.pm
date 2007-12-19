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



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			"select" => 3
		},
		GOTOS => {
			'select_stmt' => 1,
			'statement' => 2,
			'miniSQL' => 4
		}
	},
	{#State 1
		ACTIONS => {
			";" => 5
		},
		DEFAULT => -3
	},
	{#State 2
		DEFAULT => -1
	},
	{#State 3
		ACTIONS => {
			"sum" => 10,
			"max" => 7,
			"*" => 12,
			"count" => 13,
			'IDENT' => 8,
			"min" => 18
		},
		GOTOS => {
			'pattern' => 11,
			'symbol' => 6,
			'func' => 16,
			'aggregate' => 15,
			'pattern_list' => 14,
			'column' => 17,
			'qualified_symbol' => 9
		}
	},
	{#State 4
		ACTIONS => {
			'' => 19
		}
	},
	{#State 5
		DEFAULT => -2
	},
	{#State 6
		ACTIONS => {
			"." => 20
		},
		DEFAULT => -22
	},
	{#State 7
		DEFAULT => -17
	},
	{#State 8
		DEFAULT => -24
	},
	{#State 9
		DEFAULT => -21
	},
	{#State 10
		DEFAULT => -20
	},
	{#State 11
		ACTIONS => {
			"," => 21
		},
		DEFAULT => -10
	},
	{#State 12
		DEFAULT => -14
	},
	{#State 13
		DEFAULT => -19
	},
	{#State 14
		ACTIONS => {
			"from" => 22
		}
	},
	{#State 15
		ACTIONS => {
			'IDENT' => 8
		},
		DEFAULT => -12,
		GOTOS => {
			'symbol' => 23,
			'alias' => 24
		}
	},
	{#State 16
		ACTIONS => {
			"(" => 25
		}
	},
	{#State 17
		DEFAULT => -13
	},
	{#State 18
		DEFAULT => -18
	},
	{#State 19
		DEFAULT => 0
	},
	{#State 20
		ACTIONS => {
			'IDENT' => 8
		},
		GOTOS => {
			'symbol' => 26
		}
	},
	{#State 21
		ACTIONS => {
			"sum" => 10,
			"max" => 7,
			"*" => 12,
			"count" => 13,
			'IDENT' => 8,
			"min" => 18
		},
		GOTOS => {
			'pattern' => 11,
			'symbol' => 6,
			'pattern_list' => 27,
			'aggregate' => 15,
			'func' => 16,
			'column' => 17,
			'qualified_symbol' => 9
		}
	},
	{#State 22
		ACTIONS => {
			'IDENT' => 30
		},
		GOTOS => {
			'models' => 28,
			'model' => 29
		}
	},
	{#State 23
		DEFAULT => -25
	},
	{#State 24
		DEFAULT => -11
	},
	{#State 25
		ACTIONS => {
			"*" => 31,
			'IDENT' => 8
		},
		GOTOS => {
			'symbol' => 6,
			'column' => 32,
			'qualified_symbol' => 9
		}
	},
	{#State 26
		DEFAULT => -23
	},
	{#State 27
		DEFAULT => -9
	},
	{#State 28
		ACTIONS => {
			"where" => 33,
			"order by" => 38,
			"limit" => 37,
			"group by" => 41,
			"offset" => 42
		},
		DEFAULT => -5,
		GOTOS => {
			'postfix_clause_list' => 36,
			'order_by_clause' => 35,
			'offset_clause' => 34,
			'where_clause' => 39,
			'group_by_clause' => 40,
			'limit_clause' => 43,
			'postfix_clause' => 44
		}
	},
	{#State 29
		ACTIONS => {
			"," => 45
		},
		DEFAULT => -7
	},
	{#State 30
		DEFAULT => -8
	},
	{#State 31
		ACTIONS => {
			")" => 46
		}
	},
	{#State 32
		ACTIONS => {
			")" => 47
		}
	},
	{#State 33
		ACTIONS => {
			"(" => 51,
			'IDENT' => 8
		},
		GOTOS => {
			'comparison' => 48,
			'symbol' => 6,
			'conjunction' => 49,
			'disjunction' => 50,
			'condition' => 53,
			'column' => 52,
			'qualified_symbol' => 9
		}
	},
	{#State 34
		DEFAULT => -32
	},
	{#State 35
		DEFAULT => -30
	},
	{#State 36
		DEFAULT => -4
	},
	{#State 37
		ACTIONS => {
			'DIGITS' => 55
		},
		GOTOS => {
			'integer' => 54
		}
	},
	{#State 38
		ACTIONS => {
			'IDENT' => 8
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 56,
			'column' => 57,
			'qualified_symbol' => 9
		}
	},
	{#State 39
		DEFAULT => -28
	},
	{#State 40
		DEFAULT => -29
	},
	{#State 41
		ACTIONS => {
			'IDENT' => 8
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 58,
			'column' => 57,
			'qualified_symbol' => 9
		}
	},
	{#State 42
		ACTIONS => {
			'DIGITS' => 55
		},
		GOTOS => {
			'integer' => 59
		}
	},
	{#State 43
		DEFAULT => -31
	},
	{#State 44
		ACTIONS => {
			"where" => 33,
			"order by" => 38,
			"limit" => 37,
			"group by" => 41,
			"offset" => 42
		},
		DEFAULT => -27,
		GOTOS => {
			'postfix_clause_list' => 60,
			'order_by_clause' => 35,
			'offset_clause' => 34,
			'where_clause' => 39,
			'group_by_clause' => 40,
			'limit_clause' => 43,
			'postfix_clause' => 44
		}
	},
	{#State 45
		ACTIONS => {
			'IDENT' => 30
		},
		GOTOS => {
			'models' => 61,
			'model' => 29
		}
	},
	{#State 46
		DEFAULT => -16
	},
	{#State 47
		DEFAULT => -15
	},
	{#State 48
		ACTIONS => {
			"and" => 62
		},
		DEFAULT => -38
	},
	{#State 49
		ACTIONS => {
			"or" => 63
		},
		DEFAULT => -36
	},
	{#State 50
		DEFAULT => -34
	},
	{#State 51
		ACTIONS => {
			"(" => 51,
			'IDENT' => 8
		},
		GOTOS => {
			'comparison' => 48,
			'symbol' => 6,
			'conjunction' => 49,
			'disjunction' => 50,
			'condition' => 64,
			'column' => 52,
			'qualified_symbol' => 9
		}
	},
	{#State 52
		ACTIONS => {
			"<" => 65,
			"like" => 66,
			"<=" => 70,
			">" => 72,
			"<>" => 71,
			">=" => 68,
			"=" => 67
		},
		GOTOS => {
			'operator' => 69
		}
	},
	{#State 53
		DEFAULT => -33
	},
	{#State 54
		DEFAULT => -57
	},
	{#State 55
		DEFAULT => -52
	},
	{#State 56
		DEFAULT => -56
	},
	{#State 57
		ACTIONS => {
			"," => 73
		},
		DEFAULT => -55
	},
	{#State 58
		DEFAULT => -53
	},
	{#State 59
		DEFAULT => -58
	},
	{#State 60
		DEFAULT => -26
	},
	{#State 61
		DEFAULT => -6
	},
	{#State 62
		ACTIONS => {
			"(" => 51,
			'IDENT' => 8
		},
		GOTOS => {
			'comparison' => 74,
			'symbol' => 6,
			'column' => 52,
			'qualified_symbol' => 9
		}
	},
	{#State 63
		ACTIONS => {
			"(" => 51,
			'IDENT' => 8
		},
		GOTOS => {
			'comparison' => 48,
			'conjunction' => 75,
			'symbol' => 6,
			'column' => 52,
			'qualified_symbol' => 9
		}
	},
	{#State 64
		ACTIONS => {
			")" => 76
		}
	},
	{#State 65
		DEFAULT => -45
	},
	{#State 66
		DEFAULT => -48
	},
	{#State 67
		DEFAULT => -47
	},
	{#State 68
		DEFAULT => -43
	},
	{#State 69
		ACTIONS => {
			"\'" => 80,
			'IDENT' => 8,
			'DIGITS' => 55
		},
		GOTOS => {
			'literal' => 78,
			'symbol' => 6,
			'integer' => 79,
			'string' => 77,
			'column' => 81,
			'qualified_symbol' => 9
		}
	},
	{#State 70
		DEFAULT => -44
	},
	{#State 71
		DEFAULT => -46
	},
	{#State 72
		DEFAULT => -42
	},
	{#State 73
		ACTIONS => {
			'IDENT' => 8
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 82,
			'column' => 57,
			'qualified_symbol' => 9
		}
	},
	{#State 74
		DEFAULT => -37
	},
	{#State 75
		DEFAULT => -35
	},
	{#State 76
		DEFAULT => -41
	},
	{#State 77
		DEFAULT => -49
	},
	{#State 78
		DEFAULT => -39
	},
	{#State 79
		DEFAULT => -50
	},
	{#State 80
		ACTIONS => {
			'IDENT' => 8
		},
		GOTOS => {
			'symbol' => 83
		}
	},
	{#State 81
		DEFAULT => -40
	},
	{#State 82
		DEFAULT => -54
	},
	{#State 83
		ACTIONS => {
			"\'" => 84
		}
	},
	{#State 84
		DEFAULT => -51
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'miniSQL', 1,
sub
#line 10 "grammar/Select.yp"
{ print "Done!\n" }
	],
	[#Rule 2
		 'statement', 2, undef
	],
	[#Rule 3
		 'statement', 1, undef
	],
	[#Rule 4
		 'select_stmt', 5, undef
	],
	[#Rule 5
		 'select_stmt', 4, undef
	],
	[#Rule 6
		 'models', 3, undef
	],
	[#Rule 7
		 'models', 1, undef
	],
	[#Rule 8
		 'model', 1, undef
	],
	[#Rule 9
		 'pattern_list', 3, undef
	],
	[#Rule 10
		 'pattern_list', 1, undef
	],
	[#Rule 11
		 'pattern', 2, undef
	],
	[#Rule 12
		 'pattern', 1, undef
	],
	[#Rule 13
		 'pattern', 1, undef
	],
	[#Rule 14
		 'pattern', 1, undef
	],
	[#Rule 15
		 'aggregate', 4, undef
	],
	[#Rule 16
		 'aggregate', 4, undef
	],
	[#Rule 17
		 'func', 1, undef
	],
	[#Rule 18
		 'func', 1, undef
	],
	[#Rule 19
		 'func', 1, undef
	],
	[#Rule 20
		 'func', 1, undef
	],
	[#Rule 21
		 'column', 1, undef
	],
	[#Rule 22
		 'column', 1, undef
	],
	[#Rule 23
		 'qualified_symbol', 3, undef
	],
	[#Rule 24
		 'symbol', 1, undef
	],
	[#Rule 25
		 'alias', 1, undef
	],
	[#Rule 26
		 'postfix_clause_list', 2, undef
	],
	[#Rule 27
		 'postfix_clause_list', 1, undef
	],
	[#Rule 28
		 'postfix_clause', 1, undef
	],
	[#Rule 29
		 'postfix_clause', 1, undef
	],
	[#Rule 30
		 'postfix_clause', 1, undef
	],
	[#Rule 31
		 'postfix_clause', 1, undef
	],
	[#Rule 32
		 'postfix_clause', 1, undef
	],
	[#Rule 33
		 'where_clause', 2, undef
	],
	[#Rule 34
		 'condition', 1, undef
	],
	[#Rule 35
		 'disjunction', 3, undef
	],
	[#Rule 36
		 'disjunction', 1, undef
	],
	[#Rule 37
		 'conjunction', 3, undef
	],
	[#Rule 38
		 'conjunction', 1, undef
	],
	[#Rule 39
		 'comparison', 3, undef
	],
	[#Rule 40
		 'comparison', 3, undef
	],
	[#Rule 41
		 'comparison', 3, undef
	],
	[#Rule 42
		 'operator', 1, undef
	],
	[#Rule 43
		 'operator', 1, undef
	],
	[#Rule 44
		 'operator', 1, undef
	],
	[#Rule 45
		 'operator', 1, undef
	],
	[#Rule 46
		 'operator', 1, undef
	],
	[#Rule 47
		 'operator', 1, undef
	],
	[#Rule 48
		 'operator', 1, undef
	],
	[#Rule 49
		 'literal', 1, undef
	],
	[#Rule 50
		 'literal', 1, undef
	],
	[#Rule 51
		 'string', 3, undef
	],
	[#Rule 52
		 'integer', 1, undef
	],
	[#Rule 53
		 'group_by_clause', 2, undef
	],
	[#Rule 54
		 'column_list', 3, undef
	],
	[#Rule 55
		 'column_list', 1, undef
	],
	[#Rule 56
		 'order_by_clause', 2, undef
	],
	[#Rule 57
		 'limit_clause', 2, undef
	],
	[#Rule 58
		 'offset_clause', 2, undef
	]
],
                                  @_);
    bless($self,$class);
}

#line 122 "grammar/Select.yp"


#use Smart::Comments;
my $nberr = 3;

sub _Error {
    my ($value) = $_[0]->YYCurval;

    my $token = 1;
    ## $value
    my @expect = $_[0]->YYExpect;
    ### expect: @expect
    my ($what) = $value ? "input: '$value'" : "end of input";

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

    if (!$yydata->{input}) {
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
        s/^\s*([0-9]+)//s
                and return ('DIGITS', $1);
        s/^\s*(\*|count|sum|max|min|select|and|or|from|where|delete|update|set|order by|group by|limit|offset)\b//s
                and return ($1, $1);
        s/^\s*(<=|>=|<>)//s
                and return ($1, $1);
        s/^\s*([A-Za-z][A-Za-z0-9_]*)\b//s
                and return ('IDENT', $1);
        s/^\s*(\S)//s
                and return ($1, $1);
    }
}

sub parse {
    my ($self, $sql) = @_;
    open my $source, '<', \$sql;
    $self->YYData->{source} = $source;
    #$self->YYData->{INPUT} = ;
    ### $sql
    $self->YYParse( yydebug => 0 & 0x1F, yylex => \&_Lexer, yyerror => \&_Error );
    close $source;
}

#my ($select) =new Select;
#my $var = $select->Run;

1;

1;
