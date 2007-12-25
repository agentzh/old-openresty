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


my (@Models, @Columns, @OutVars, %InVals, %Defaults, $Quote);



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
			'VAR' => 14,
			"count" => 15,
			'IDENT' => 8,
			"min" => 19
		},
		GOTOS => {
			'symbol' => 6,
			'proc_call' => 9,
			'qualified_symbol' => 10,
			'pattern' => 12,
			'pattern_list' => 16,
			'aggregate' => 17,
			'func' => 18,
			'column' => 20
		}
	},
	{#State 4
		ACTIONS => {
			'' => 21
		}
	},
	{#State 5
		DEFAULT => -2
	},
	{#State 6
		ACTIONS => {
			"." => 22
		},
		DEFAULT => -28
	},
	{#State 7
		DEFAULT => -18
	},
	{#State 8
		ACTIONS => {
			"(" => 23
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
			"," => 24
		},
		DEFAULT => -10
	},
	{#State 13
		DEFAULT => -15
	},
	{#State 14
		DEFAULT => -31
	},
	{#State 15
		DEFAULT => -20
	},
	{#State 16
		ACTIONS => {
			"where" => 25,
			"order by" => 30,
			"limit" => 29,
			"group by" => 33,
			"from" => 34,
			"offset" => 36
		},
		DEFAULT => -5,
		GOTOS => {
			'postfix_clause_list' => 28,
			'order_by_clause' => 27,
			'offset_clause' => 26,
			'from_clause' => 35,
			'where_clause' => 31,
			'group_by_clause' => 32,
			'limit_clause' => 37,
			'postfix_clause' => 38
		}
	},
	{#State 17
		ACTIONS => {
			'IDENT' => 40,
			'VAR' => 14
		},
		DEFAULT => -12,
		GOTOS => {
			'symbol' => 39,
			'alias' => 41
		}
	},
	{#State 18
		ACTIONS => {
			"(" => 42
		}
	},
	{#State 19
		DEFAULT => -19
	},
	{#State 20
		DEFAULT => -14
	},
	{#State 21
		DEFAULT => 0
	},
	{#State 22
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'symbol' => 43
		}
	},
	{#State 23
		ACTIONS => {
			'INTEGER' => 44,
			'STRING' => 45
		},
		GOTOS => {
			'parameter' => 46,
			'parameter_list' => 47
		}
	},
	{#State 24
		ACTIONS => {
			"sum" => 11,
			"max" => 7,
			"*" => 13,
			'VAR' => 14,
			"count" => 15,
			'IDENT' => 8,
			"min" => 19
		},
		GOTOS => {
			'symbol' => 6,
			'proc_call' => 9,
			'qualified_symbol' => 10,
			'pattern' => 12,
			'func' => 18,
			'aggregate' => 17,
			'pattern_list' => 48,
			'column' => 20
		}
	},
	{#State 25
		ACTIONS => {
			"(" => 52,
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'comparison' => 49,
			'symbol' => 6,
			'conjunction' => 50,
			'disjunction' => 51,
			'condition' => 54,
			'column' => 53,
			'qualified_symbol' => 10
		}
	},
	{#State 26
		DEFAULT => -39
	},
	{#State 27
		DEFAULT => -37
	},
	{#State 28
		DEFAULT => -4
	},
	{#State 29
		ACTIONS => {
			'INTEGER' => 55
		}
	},
	{#State 30
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 56,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 31
		DEFAULT => -35
	},
	{#State 32
		DEFAULT => -36
	},
	{#State 33
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 58,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 34
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 8
		},
		GOTOS => {
			'models' => 59,
			'symbol' => 60,
			'model' => 61,
			'proc_call' => 62
		}
	},
	{#State 35
		DEFAULT => -40
	},
	{#State 36
		ACTIONS => {
			'INTEGER' => 63
		}
	},
	{#State 37
		DEFAULT => -38
	},
	{#State 38
		ACTIONS => {
			"where" => 25,
			"order by" => 30,
			"limit" => 29,
			"group by" => 33,
			"from" => 34,
			"offset" => 36
		},
		DEFAULT => -34,
		GOTOS => {
			'postfix_clause_list' => 64,
			'order_by_clause' => 27,
			'offset_clause' => 26,
			'from_clause' => 35,
			'where_clause' => 31,
			'group_by_clause' => 32,
			'limit_clause' => 37,
			'postfix_clause' => 38
		}
	},
	{#State 39
		DEFAULT => -32
	},
	{#State 40
		DEFAULT => -30
	},
	{#State 41
		DEFAULT => -11
	},
	{#State 42
		ACTIONS => {
			"*" => 65,
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'symbol' => 6,
			'column' => 66,
			'qualified_symbol' => 10
		}
	},
	{#State 43
		DEFAULT => -29
	},
	{#State 44
		DEFAULT => -26
	},
	{#State 45
		DEFAULT => -25
	},
	{#State 46
		ACTIONS => {
			"," => 67
		},
		DEFAULT => -24
	},
	{#State 47
		ACTIONS => {
			")" => 68
		}
	},
	{#State 48
		DEFAULT => -9
	},
	{#State 49
		ACTIONS => {
			"and" => 69
		},
		DEFAULT => -48
	},
	{#State 50
		ACTIONS => {
			"or" => 70
		},
		DEFAULT => -46
	},
	{#State 51
		DEFAULT => -44
	},
	{#State 52
		ACTIONS => {
			"(" => 52,
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'comparison' => 49,
			'symbol' => 6,
			'conjunction' => 50,
			'disjunction' => 51,
			'condition' => 71,
			'column' => 53,
			'qualified_symbol' => 10
		}
	},
	{#State 53
		ACTIONS => {
			"<" => 72,
			"like" => 73,
			"<=" => 77,
			">" => 79,
			"<>" => 78,
			">=" => 75,
			"=" => 74
		},
		GOTOS => {
			'operator' => 76
		}
	},
	{#State 54
		DEFAULT => -43
	},
	{#State 55
		DEFAULT => -65
	},
	{#State 56
		DEFAULT => -64
	},
	{#State 57
		ACTIONS => {
			"," => 80
		},
		DEFAULT => -63
	},
	{#State 58
		DEFAULT => -61
	},
	{#State 59
		DEFAULT => -41
	},
	{#State 60
		DEFAULT => -8
	},
	{#State 61
		ACTIONS => {
			"," => 81
		},
		DEFAULT => -7
	},
	{#State 62
		DEFAULT => -42
	},
	{#State 63
		DEFAULT => -66
	},
	{#State 64
		DEFAULT => -33
	},
	{#State 65
		ACTIONS => {
			")" => 82
		}
	},
	{#State 66
		ACTIONS => {
			")" => 83
		}
	},
	{#State 67
		ACTIONS => {
			'INTEGER' => 44,
			'STRING' => 45
		},
		GOTOS => {
			'parameter' => 46,
			'parameter_list' => 84
		}
	},
	{#State 68
		DEFAULT => -22
	},
	{#State 69
		ACTIONS => {
			"(" => 52,
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'comparison' => 85,
			'symbol' => 6,
			'column' => 53,
			'qualified_symbol' => 10
		}
	},
	{#State 70
		ACTIONS => {
			"(" => 52,
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'comparison' => 49,
			'conjunction' => 86,
			'symbol' => 6,
			'column' => 53,
			'qualified_symbol' => 10
		}
	},
	{#State 71
		ACTIONS => {
			")" => 87
		}
	},
	{#State 72
		DEFAULT => -55
	},
	{#State 73
		DEFAULT => -58
	},
	{#State 74
		DEFAULT => -57
	},
	{#State 75
		DEFAULT => -53
	},
	{#State 76
		ACTIONS => {
			'INTEGER' => 88,
			'VAR' => 14,
			'IDENT' => 40,
			'STRING' => 89
		},
		GOTOS => {
			'literal' => 90,
			'symbol' => 6,
			'column' => 91,
			'qualified_symbol' => 10
		}
	},
	{#State 77
		DEFAULT => -54
	},
	{#State 78
		DEFAULT => -56
	},
	{#State 79
		DEFAULT => -52
	},
	{#State 80
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 92,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 81
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 40
		},
		GOTOS => {
			'models' => 93,
			'symbol' => 60,
			'model' => 61
		}
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
		DEFAULT => -47
	},
	{#State 86
		DEFAULT => -45
	},
	{#State 87
		DEFAULT => -51
	},
	{#State 88
		DEFAULT => -60
	},
	{#State 89
		DEFAULT => -59
	},
	{#State 90
		DEFAULT => -49
	},
	{#State 91
		DEFAULT => -50
	},
	{#State 92
		DEFAULT => -62
	},
	{#State 93
		DEFAULT => -6
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
                      "\"$_[1]\".\"$_[3]\""
                    }
	],
	[#Rule 30
		 'symbol', 1, undef
	],
	[#Rule 31
		 'symbol', 1,
sub
#line 88 "grammar/Select.yp"
{ push @OutVars, $_[1]; $Quote ? $Quote->($InVals{$_[1]}) : '' }
	],
	[#Rule 32
		 'alias', 1, undef
	],
	[#Rule 33
		 'postfix_clause_list', 2,
sub
#line 95 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 34
		 'postfix_clause_list', 1, undef
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
		 'postfix_clause', 1, undef
	],
	[#Rule 41
		 'from_clause', 2,
sub
#line 108 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 42
		 'from_clause', 2,
sub
#line 110 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 43
		 'where_clause', 2,
sub
#line 114 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 44
		 'condition', 1, undef
	],
	[#Rule 45
		 'disjunction', 3,
sub
#line 121 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 46
		 'disjunction', 1, undef
	],
	[#Rule 47
		 'conjunction', 3,
sub
#line 126 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'conjunction', 1, undef
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
		 'comparison', 3,
sub
#line 135 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
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
		 'operator', 1, undef
	],
	[#Rule 59
		 'literal', 1, undef
	],
	[#Rule 60
		 'literal', 1, undef
	],
	[#Rule 61
		 'group_by_clause', 2,
sub
#line 152 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 62
		 'column_list', 3,
sub
#line 156 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 63
		 'column_list', 1, undef
	],
	[#Rule 64
		 'order_by_clause', 2,
sub
#line 161 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 65
		 'limit_clause', 2,
sub
#line 165 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 66
		 'offset_clause', 2,
sub
#line 168 "grammar/Select.yp"
{
                 delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 172 "grammar/Select.yp"


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
        s/^\s*(\$q\$.*?\$q\$)//
                and return ('STRING', $1);
        s/^\s*(\*|count|sum|max|min|select|and|or|from|where|delete|update|set|order by|group by|limit|offset)\b//s
                and return ($1, $1);
        s/^\s*(<=|>=|<>)//s
                and return ($1, $1);
        s/^\s*([A-Za-z][A-Za-z0-9_]*)\b//s
                and return ('IDENT', $1);
        s/^\$(\w+)//s
                and return ('VAR', $1);
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
    %InVals = ();
    @OutVars = ();
    %Defaults = ();
    my $sql = $self->YYParse( yydebug => 0 & 0x1F, yylex => \&_Lexer, yyerror => \&_Error );
    close $source;
    return {
        limit   => $yydata->{limit},
        offset  => $yydata->{offset},
        models  => [@Models],
        columns => [@Columns],
        sql => $sql,
        vars => [@OutVars],
        defaults => {%Defaults},
    };
}

#my ($select) =new Select;
#my $var = $select->Run;

1;


1;
