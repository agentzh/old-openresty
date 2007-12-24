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

#line 5 "grammar/Select.yp"


my (@Models, @Columns);



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
			"sum" => 11,
			"max" => 7,
			"*" => 13,
			"count" => 14,
			'IDENT' => 8,
			"min" => 18
		},
		GOTOS => {
			'symbol' => 6,
			'proc_call' => 9,
			'qualified_symbol' => 10,
			'pattern' => 12,
			'pattern_list' => 15,
			'aggregate' => 16,
			'func' => 17,
			'column' => 19
		}
	},
	{#State 4
		ACTIONS => {
			'' => 20
		}
	},
	{#State 5
		DEFAULT => -2
	},
	{#State 6
		ACTIONS => {
			"." => 21
		},
		DEFAULT => -28
	},
	{#State 7
		DEFAULT => -18
	},
	{#State 8
		ACTIONS => {
			"(" => 22
		},
		DEFAULT => -30
	},
	{#State 9
		DEFAULT => -13
	},
	{#State 10
		DEFAULT => -27
	},
	{#State 11
		DEFAULT => -21
	},
	{#State 12
		ACTIONS => {
			"," => 23
		},
		DEFAULT => -10
	},
	{#State 13
		DEFAULT => -15
	},
	{#State 14
		DEFAULT => -20
	},
	{#State 15
		ACTIONS => {
			"where" => 24,
			"order by" => 29,
			"limit" => 28,
			"group by" => 32,
			"from" => 33,
			"offset" => 35
		},
		DEFAULT => -5,
		GOTOS => {
			'postfix_clause_list' => 27,
			'order_by_clause' => 26,
			'offset_clause' => 25,
			'from_clause' => 34,
			'where_clause' => 30,
			'group_by_clause' => 31,
			'limit_clause' => 36,
			'postfix_clause' => 37
		}
	},
	{#State 16
		ACTIONS => {
			'IDENT' => 39
		},
		DEFAULT => -12,
		GOTOS => {
			'symbol' => 38,
			'alias' => 40
		}
	},
	{#State 17
		ACTIONS => {
			"(" => 41
		}
	},
	{#State 18
		DEFAULT => -19
	},
	{#State 19
		DEFAULT => -14
	},
	{#State 20
		DEFAULT => 0
	},
	{#State 21
		ACTIONS => {
			'IDENT' => 39
		},
		GOTOS => {
			'symbol' => 42
		}
	},
	{#State 22
		ACTIONS => {
			'INTEGER' => 43,
			'STRING' => 44
		},
		GOTOS => {
			'parameter' => 45,
			'parameter_list' => 46
		}
	},
	{#State 23
		ACTIONS => {
			"sum" => 11,
			"max" => 7,
			"*" => 13,
			"count" => 14,
			'IDENT' => 8,
			"min" => 18
		},
		GOTOS => {
			'symbol' => 6,
			'proc_call' => 9,
			'qualified_symbol' => 10,
			'pattern' => 12,
			'func' => 17,
			'aggregate' => 16,
			'pattern_list' => 47,
			'column' => 19
		}
	},
	{#State 24
		ACTIONS => {
			"(" => 51,
			'IDENT' => 39
		},
		GOTOS => {
			'comparison' => 48,
			'symbol' => 6,
			'conjunction' => 49,
			'disjunction' => 50,
			'condition' => 53,
			'column' => 52,
			'qualified_symbol' => 10
		}
	},
	{#State 25
		DEFAULT => -38
	},
	{#State 26
		DEFAULT => -36
	},
	{#State 27
		DEFAULT => -4
	},
	{#State 28
		ACTIONS => {
			'INTEGER' => 54
		}
	},
	{#State 29
		ACTIONS => {
			'IDENT' => 39
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 55,
			'column' => 56,
			'qualified_symbol' => 10
		}
	},
	{#State 30
		DEFAULT => -34
	},
	{#State 31
		DEFAULT => -35
	},
	{#State 32
		ACTIONS => {
			'IDENT' => 39
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 57,
			'column' => 56,
			'qualified_symbol' => 10
		}
	},
	{#State 33
		ACTIONS => {
			'IDENT' => 60
		},
		GOTOS => {
			'models' => 58,
			'model' => 59,
			'proc_call' => 61
		}
	},
	{#State 34
		DEFAULT => -39
	},
	{#State 35
		ACTIONS => {
			'INTEGER' => 62
		}
	},
	{#State 36
		DEFAULT => -37
	},
	{#State 37
		ACTIONS => {
			"where" => 24,
			"order by" => 29,
			"limit" => 28,
			"group by" => 32,
			"from" => 33,
			"offset" => 35
		},
		DEFAULT => -33,
		GOTOS => {
			'postfix_clause_list' => 63,
			'order_by_clause' => 26,
			'offset_clause' => 25,
			'from_clause' => 34,
			'where_clause' => 30,
			'group_by_clause' => 31,
			'limit_clause' => 36,
			'postfix_clause' => 37
		}
	},
	{#State 38
		DEFAULT => -31
	},
	{#State 39
		DEFAULT => -30
	},
	{#State 40
		DEFAULT => -11
	},
	{#State 41
		ACTIONS => {
			"*" => 64,
			'IDENT' => 39
		},
		GOTOS => {
			'symbol' => 6,
			'column' => 65,
			'qualified_symbol' => 10
		}
	},
	{#State 42
		DEFAULT => -29
	},
	{#State 43
		DEFAULT => -26
	},
	{#State 44
		DEFAULT => -25
	},
	{#State 45
		ACTIONS => {
			"," => 66
		},
		DEFAULT => -24
	},
	{#State 46
		ACTIONS => {
			")" => 67
		}
	},
	{#State 47
		DEFAULT => -9
	},
	{#State 48
		ACTIONS => {
			"and" => 68
		},
		DEFAULT => -47
	},
	{#State 49
		ACTIONS => {
			"or" => 69
		},
		DEFAULT => -45
	},
	{#State 50
		DEFAULT => -43
	},
	{#State 51
		ACTIONS => {
			"(" => 51,
			'IDENT' => 39
		},
		GOTOS => {
			'comparison' => 48,
			'symbol' => 6,
			'conjunction' => 49,
			'disjunction' => 50,
			'condition' => 70,
			'column' => 52,
			'qualified_symbol' => 10
		}
	},
	{#State 52
		ACTIONS => {
			"<" => 71,
			"like" => 72,
			"<=" => 76,
			">" => 78,
			"<>" => 77,
			">=" => 74,
			"=" => 73
		},
		GOTOS => {
			'operator' => 75
		}
	},
	{#State 53
		DEFAULT => -42
	},
	{#State 54
		DEFAULT => -64
	},
	{#State 55
		DEFAULT => -63
	},
	{#State 56
		ACTIONS => {
			"," => 79
		},
		DEFAULT => -62
	},
	{#State 57
		DEFAULT => -60
	},
	{#State 58
		DEFAULT => -40
	},
	{#State 59
		ACTIONS => {
			"," => 80
		},
		DEFAULT => -7
	},
	{#State 60
		ACTIONS => {
			"(" => 22
		},
		DEFAULT => -8
	},
	{#State 61
		DEFAULT => -41
	},
	{#State 62
		DEFAULT => -65,
		GOTOS => {
			'@1-2' => 81
		}
	},
	{#State 63
		DEFAULT => -32
	},
	{#State 64
		ACTIONS => {
			")" => 82
		}
	},
	{#State 65
		ACTIONS => {
			")" => 83
		}
	},
	{#State 66
		ACTIONS => {
			'INTEGER' => 43,
			'STRING' => 44
		},
		GOTOS => {
			'parameter' => 45,
			'parameter_list' => 84
		}
	},
	{#State 67
		DEFAULT => -22
	},
	{#State 68
		ACTIONS => {
			"(" => 51,
			'IDENT' => 39
		},
		GOTOS => {
			'comparison' => 85,
			'symbol' => 6,
			'column' => 52,
			'qualified_symbol' => 10
		}
	},
	{#State 69
		ACTIONS => {
			"(" => 51,
			'IDENT' => 39
		},
		GOTOS => {
			'comparison' => 48,
			'conjunction' => 86,
			'symbol' => 6,
			'column' => 52,
			'qualified_symbol' => 10
		}
	},
	{#State 70
		ACTIONS => {
			")" => 87
		}
	},
	{#State 71
		DEFAULT => -54
	},
	{#State 72
		DEFAULT => -57
	},
	{#State 73
		DEFAULT => -56
	},
	{#State 74
		DEFAULT => -52
	},
	{#State 75
		ACTIONS => {
			'INTEGER' => 88,
			'IDENT' => 39,
			'STRING' => 89
		},
		GOTOS => {
			'literal' => 90,
			'symbol' => 6,
			'column' => 91,
			'qualified_symbol' => 10
		}
	},
	{#State 76
		DEFAULT => -53
	},
	{#State 77
		DEFAULT => -55
	},
	{#State 78
		DEFAULT => -51
	},
	{#State 79
		ACTIONS => {
			'IDENT' => 39
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 92,
			'column' => 56,
			'qualified_symbol' => 10
		}
	},
	{#State 80
		ACTIONS => {
			'IDENT' => 94
		},
		GOTOS => {
			'models' => 93,
			'model' => 59
		}
	},
	{#State 81
		DEFAULT => -66
	},
	{#State 82
		DEFAULT => -17
	},
	{#State 83
		DEFAULT => -16
	},
	{#State 84
		DEFAULT => -23
	},
	{#State 85
		DEFAULT => -46
	},
	{#State 86
		DEFAULT => -44
	},
	{#State 87
		DEFAULT => -50
	},
	{#State 88
		DEFAULT => -59
	},
	{#State 89
		DEFAULT => -58
	},
	{#State 90
		DEFAULT => -48
	},
	{#State 91
		DEFAULT => -49
	},
	{#State 92
		DEFAULT => -61
	},
	{#State 93
		DEFAULT => -6
	},
	{#State 94
		DEFAULT => -8
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
		 'select_stmt', 3,
sub
#line 24 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 5
		 'select_stmt', 2,
sub
#line 26 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 6
		 'models', 3,
sub
#line 30 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 7
		 'models', 1, undef
	],
	[#Rule 8
		 'model', 1,
sub
#line 34 "grammar/Select.yp"
{ push @Models, $_[1]; "\"$_[1]\"" }
	],
	[#Rule 9
		 'pattern_list', 3,
sub
#line 38 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'pattern', 1, undef
	],
	[#Rule 16
		 'aggregate', 4,
sub
#line 50 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 17
		 'aggregate', 4,
sub
#line 52 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'func', 1, undef
	],
	[#Rule 22
		 'proc_call', 4,
sub
#line 62 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 23
		 'parameter_list', 3,
sub
#line 66 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 24
		 'parameter_list', 1, undef
	],
	[#Rule 25
		 'parameter', 1, undef
	],
	[#Rule 26
		 'parameter', 1, undef
	],
	[#Rule 27
		 'column', 1, undef
	],
	[#Rule 28
		 'column', 1,
sub
#line 75 "grammar/Select.yp"
{ push @Columns, $_[1]; "\"$_[1]\"" }
	],
	[#Rule 29
		 'qualified_symbol', 3,
sub
#line 79 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      "\"$_[1]\".\"$_[2]\""
                    }
	],
	[#Rule 30
		 'symbol', 1, undef
	],
	[#Rule 31
		 'alias', 1, undef
	],
	[#Rule 32
		 'postfix_clause_list', 2,
sub
#line 93 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 33
		 'postfix_clause_list', 1, undef
	],
	[#Rule 34
		 'postfix_clause', 1, undef
	],
	[#Rule 35
		 'postfix_clause', 1, undef
	],
	[#Rule 36
		 'postfix_clause', 1, undef
	],
	[#Rule 37
		 'postfix_clause', 1, undef
	],
	[#Rule 38
		 'postfix_clause', 1, undef
	],
	[#Rule 39
		 'postfix_clause', 1, undef
	],
	[#Rule 40
		 'from_clause', 2,
sub
#line 106 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 41
		 'from_clause', 2,
sub
#line 108 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 42
		 'where_clause', 2,
sub
#line 112 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 43
		 'condition', 1, undef
	],
	[#Rule 44
		 'disjunction', 3,
sub
#line 119 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 45
		 'disjunction', 1, undef
	],
	[#Rule 46
		 'conjunction', 3,
sub
#line 124 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 47
		 'conjunction', 1, undef
	],
	[#Rule 48
		 'comparison', 3,
sub
#line 129 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'comparison', 3,
sub
#line 131 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'comparison', 3,
sub
#line 133 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 51
		 'operator', 1, undef
	],
	[#Rule 52
		 'operator', 1, undef
	],
	[#Rule 53
		 'operator', 1, undef
	],
	[#Rule 54
		 'operator', 1, undef
	],
	[#Rule 55
		 'operator', 1, undef
	],
	[#Rule 56
		 'operator', 1, undef
	],
	[#Rule 57
		 'operator', 1, undef
	],
	[#Rule 58
		 'literal', 1, undef
	],
	[#Rule 59
		 'literal', 1, undef
	],
	[#Rule 60
		 'group_by_clause', 2,
sub
#line 150 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 61
		 'column_list', 3,
sub
#line 154 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'column_list', 1, undef
	],
	[#Rule 63
		 'order_by_clause', 2,
sub
#line 159 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 64
		 'limit_clause', 2,
sub
#line 163 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 65
		 '@1-2', 0,
sub
#line 166 "grammar/Select.yp"
{ delete $_[0]->YYData->{offset} }
	],
	[#Rule 66
		 'offset_clause', 3,
sub
#line 167 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 170 "grammar/Select.yp"


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
        s/^\s*([0-9]+)\b//s
                and return ('INTEGER', $1);
        s/^\s*('[^']*')//
                and return ('STRING', $1);
        s/^\s*(\$q\$.*?\$q)\$//
                and return ('STRING', $1);
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
    my ($self, $sql, $params) = @_;
    open my $source, '<', \$sql;
    my $yydata = $self->YYData;
    $yydata->{source} = $source;
    $yydata->{limit} = $params->{limit};
    $yydata->{offset} = $params->{offset};

    #$self->YYData->{INPUT} = ;
    ### $sql
    @Models = ();
    @Columns = ();
    my $sql = $self->YYParse( yydebug => 0 & 0x1F, yylex => \&_Lexer, yyerror => \&_Error );
    close $source;
    return {
        limit   => $yydata->{limit},
        offset  => $yydata->{offset},
        models  => [@Models],
        columns => [@Columns],
        sql => $sql,
    };
}

#my ($select) =new Select;
#my $var = $select->Run;

1;


1;
