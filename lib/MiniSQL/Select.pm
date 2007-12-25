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


my (@Models, @Columns, @OutVars, $InVals, %Defaults, $Quote);



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
		DEFAULT => -33
	},
	{#State 7
		DEFAULT => -18
	},
	{#State 8
		ACTIONS => {
			"(" => 23
		},
		DEFAULT => -35
	},
	{#State 9
		DEFAULT => -13
	},
	{#State 10
		DEFAULT => -32
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
		ACTIONS => {
			"|" => 25
		},
		DEFAULT => -36
	},
	{#State 15
		DEFAULT => -20
	},
	{#State 16
		ACTIONS => {
			"where" => 26,
			"order by" => 31,
			"limit" => 30,
			"group by" => 34,
			"from" => 35,
			"offset" => 37
		},
		DEFAULT => -5,
		GOTOS => {
			'postfix_clause_list' => 29,
			'order_by_clause' => 28,
			'offset_clause' => 27,
			'from_clause' => 36,
			'where_clause' => 32,
			'group_by_clause' => 33,
			'limit_clause' => 38,
			'postfix_clause' => 39
		}
	},
	{#State 17
		ACTIONS => {
			'IDENT' => 41,
			'VAR' => 14
		},
		DEFAULT => -12,
		GOTOS => {
			'symbol' => 40,
			'alias' => 42
		}
	},
	{#State 18
		ACTIONS => {
			"(" => 43
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
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 44
		}
	},
	{#State 23
		ACTIONS => {
			'NUM' => 47,
			'VAR' => 49,
			'STRING' => 46
		},
		GOTOS => {
			'parameter' => 48,
			'string' => 45,
			'parameter_list' => 50
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
			'pattern_list' => 51,
			'column' => 20
		}
	},
	{#State 25
		ACTIONS => {
			'IDENT' => 52
		}
	},
	{#State 26
		ACTIONS => {
			"(" => 56,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 53,
			'symbol' => 6,
			'conjunction' => 54,
			'disjunction' => 55,
			'condition' => 58,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 27
		DEFAULT => -45
	},
	{#State 28
		DEFAULT => -43
	},
	{#State 29
		DEFAULT => -4
	},
	{#State 30
		ACTIONS => {
			'NUM' => 59
		}
	},
	{#State 31
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 60,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 32
		DEFAULT => -41
	},
	{#State 33
		DEFAULT => -42
	},
	{#State 34
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 62,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 35
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 8
		},
		GOTOS => {
			'models' => 63,
			'symbol' => 64,
			'model' => 65,
			'proc_call' => 66
		}
	},
	{#State 36
		DEFAULT => -46
	},
	{#State 37
		ACTIONS => {
			'NUM' => 67
		}
	},
	{#State 38
		DEFAULT => -44
	},
	{#State 39
		ACTIONS => {
			"where" => 26,
			"order by" => 31,
			"limit" => 30,
			"group by" => 34,
			"from" => 35,
			"offset" => 37
		},
		DEFAULT => -40,
		GOTOS => {
			'postfix_clause_list' => 68,
			'order_by_clause' => 28,
			'offset_clause' => 27,
			'from_clause' => 36,
			'where_clause' => 32,
			'group_by_clause' => 33,
			'limit_clause' => 38,
			'postfix_clause' => 39
		}
	},
	{#State 40
		DEFAULT => -38
	},
	{#State 41
		DEFAULT => -35
	},
	{#State 42
		DEFAULT => -11
	},
	{#State 43
		ACTIONS => {
			"*" => 69,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column' => 70,
			'qualified_symbol' => 10
		}
	},
	{#State 44
		DEFAULT => -34
	},
	{#State 45
		DEFAULT => -25
	},
	{#State 46
		DEFAULT => -29
	},
	{#State 47
		DEFAULT => -26
	},
	{#State 48
		ACTIONS => {
			"," => 71
		},
		DEFAULT => -24
	},
	{#State 49
		ACTIONS => {
			"|" => 72
		},
		DEFAULT => -30
	},
	{#State 50
		ACTIONS => {
			")" => 73
		}
	},
	{#State 51
		DEFAULT => -9
	},
	{#State 52
		DEFAULT => -37
	},
	{#State 53
		ACTIONS => {
			"and" => 74
		},
		DEFAULT => -54
	},
	{#State 54
		ACTIONS => {
			"or" => 75
		},
		DEFAULT => -52
	},
	{#State 55
		DEFAULT => -50
	},
	{#State 56
		ACTIONS => {
			"(" => 56,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 53,
			'symbol' => 6,
			'conjunction' => 54,
			'disjunction' => 55,
			'condition' => 76,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 57
		ACTIONS => {
			"<" => 77,
			"like" => 78,
			"<=" => 82,
			">" => 84,
			"<>" => 83,
			">=" => 80,
			"=" => 79
		},
		GOTOS => {
			'operator' => 81
		}
	},
	{#State 58
		DEFAULT => -49
	},
	{#State 59
		DEFAULT => -71
	},
	{#State 60
		DEFAULT => -70
	},
	{#State 61
		ACTIONS => {
			"," => 85
		},
		DEFAULT => -69
	},
	{#State 62
		DEFAULT => -67
	},
	{#State 63
		DEFAULT => -47
	},
	{#State 64
		DEFAULT => -8
	},
	{#State 65
		ACTIONS => {
			"," => 86
		},
		DEFAULT => -7
	},
	{#State 66
		DEFAULT => -48
	},
	{#State 67
		DEFAULT => -72
	},
	{#State 68
		DEFAULT => -39
	},
	{#State 69
		ACTIONS => {
			")" => 87
		}
	},
	{#State 70
		ACTIONS => {
			")" => 88
		}
	},
	{#State 71
		ACTIONS => {
			'NUM' => 47,
			'VAR' => 49,
			'STRING' => 46
		},
		GOTOS => {
			'parameter' => 48,
			'string' => 45,
			'parameter_list' => 89
		}
	},
	{#State 72
		ACTIONS => {
			'NUM' => 92,
			'STRING' => 91
		},
		GOTOS => {
			'constant' => 90
		}
	},
	{#State 73
		DEFAULT => -22
	},
	{#State 74
		ACTIONS => {
			"(" => 56,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 93,
			'symbol' => 6,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 75
		ACTIONS => {
			"(" => 56,
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'comparison' => 53,
			'conjunction' => 94,
			'symbol' => 6,
			'column' => 57,
			'qualified_symbol' => 10
		}
	},
	{#State 76
		ACTIONS => {
			")" => 95
		}
	},
	{#State 77
		DEFAULT => -61
	},
	{#State 78
		DEFAULT => -64
	},
	{#State 79
		DEFAULT => -63
	},
	{#State 80
		DEFAULT => -59
	},
	{#State 81
		ACTIONS => {
			'NUM' => 97,
			'VAR' => 99,
			'IDENT' => 41,
			'STRING' => 46
		},
		GOTOS => {
			'literal' => 98,
			'symbol' => 6,
			'string' => 96,
			'column' => 100,
			'qualified_symbol' => 10
		}
	},
	{#State 82
		DEFAULT => -60
	},
	{#State 83
		DEFAULT => -62
	},
	{#State 84
		DEFAULT => -58
	},
	{#State 85
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'symbol' => 6,
			'column_list' => 101,
			'column' => 61,
			'qualified_symbol' => 10
		}
	},
	{#State 86
		ACTIONS => {
			'VAR' => 14,
			'IDENT' => 41
		},
		GOTOS => {
			'models' => 102,
			'symbol' => 64,
			'model' => 65
		}
	},
	{#State 87
		DEFAULT => -17
	},
	{#State 88
		DEFAULT => -16
	},
	{#State 89
		DEFAULT => -23
	},
	{#State 90
		DEFAULT => -31
	},
	{#State 91
		DEFAULT => -27
	},
	{#State 92
		DEFAULT => -28
	},
	{#State 93
		DEFAULT => -53
	},
	{#State 94
		DEFAULT => -51
	},
	{#State 95
		DEFAULT => -57
	},
	{#State 96
		DEFAULT => -65
	},
	{#State 97
		DEFAULT => -66
	},
	{#State 98
		DEFAULT => -55
	},
	{#State 99
		ACTIONS => {
			"|" => 103,
			"." => -36
		},
		DEFAULT => -30
	},
	{#State 100
		DEFAULT => -56
	},
	{#State 101
		DEFAULT => -68
	},
	{#State 102
		DEFAULT => -6
	},
	{#State 103
		ACTIONS => {
			'NUM' => 92,
			'IDENT' => 52,
			'STRING' => 91
		},
		GOTOS => {
			'constant' => 90
		}
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
		 'constant', 1, undef
	],
	[#Rule 28
		 'constant', 1, undef
	],
	[#Rule 29
		 'string', 1,
sub
#line 76 "grammar/Select.yp"
{ $Quote->(parse_string($_[1])) }
	],
	[#Rule 30
		 'string', 1,
sub
#line 78 "grammar/Select.yp"
{ push @OutVars, $_[1];
            $Quote->($InVals->{$_[1]})
          }
	],
	[#Rule 31
		 'string', 3,
sub
#line 82 "grammar/Select.yp"
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
	[#Rule 32
		 'column', 1, undef
	],
	[#Rule 33
		 'column', 1,
sub
#line 94 "grammar/Select.yp"
{ push @Columns, $_[1]; "\"$_[1]\"" }
	],
	[#Rule 34
		 'qualified_symbol', 3,
sub
#line 98 "grammar/Select.yp"
{
                      push @Models, $_[1];
                      push @Columns, $_[3];
                      "\"$_[1]\".\"$_[3]\""
                    }
	],
	[#Rule 35
		 'symbol', 1, undef
	],
	[#Rule 36
		 'symbol', 1,
sub
#line 107 "grammar/Select.yp"
{ push @OutVars, $_[1]; $InVals->{$_[1]} }
	],
	[#Rule 37
		 'symbol', 3,
sub
#line 109 "grammar/Select.yp"
{ push @OutVars, $_[1];
            my $val = $InVals->{$_[1]};
            if (!defined $val) {
                my $default;
                $Defaults{$_[1]} = $default = $_[3];
                return $default;
            }
            $val;
          }
	],
	[#Rule 38
		 'alias', 1, undef
	],
	[#Rule 39
		 'postfix_clause_list', 2,
sub
#line 124 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 40
		 'postfix_clause_list', 1, undef
	],
	[#Rule 41
		 'postfix_clause', 1, undef
	],
	[#Rule 42
		 'postfix_clause', 1, undef
	],
	[#Rule 43
		 'postfix_clause', 1, undef
	],
	[#Rule 44
		 'postfix_clause', 1, undef
	],
	[#Rule 45
		 'postfix_clause', 1, undef
	],
	[#Rule 46
		 'postfix_clause', 1, undef
	],
	[#Rule 47
		 'from_clause', 2,
sub
#line 137 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 48
		 'from_clause', 2,
sub
#line 139 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 49
		 'where_clause', 2,
sub
#line 143 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 50
		 'condition', 1, undef
	],
	[#Rule 51
		 'disjunction', 3,
sub
#line 150 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 52
		 'disjunction', 1, undef
	],
	[#Rule 53
		 'conjunction', 3,
sub
#line 155 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 54
		 'conjunction', 1, undef
	],
	[#Rule 55
		 'comparison', 3,
sub
#line 160 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 56
		 'comparison', 3,
sub
#line 162 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 57
		 'comparison', 3,
sub
#line 164 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 58
		 'operator', 1, undef
	],
	[#Rule 59
		 'operator', 1, undef
	],
	[#Rule 60
		 'operator', 1, undef
	],
	[#Rule 61
		 'operator', 1, undef
	],
	[#Rule 62
		 'operator', 1, undef
	],
	[#Rule 63
		 'operator', 1, undef
	],
	[#Rule 64
		 'operator', 1, undef
	],
	[#Rule 65
		 'literal', 1, undef
	],
	[#Rule 66
		 'literal', 1, undef
	],
	[#Rule 67
		 'group_by_clause', 2,
sub
#line 181 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 68
		 'column_list', 3,
sub
#line 185 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 69
		 'column_list', 1, undef
	],
	[#Rule 70
		 'order_by_clause', 2,
sub
#line 190 "grammar/Select.yp"
{ join(' ', @_[1..$#_]) }
	],
	[#Rule 71
		 'limit_clause', 2,
sub
#line 194 "grammar/Select.yp"
{ delete $_[0]->YYData->{limit}; join(' ', @_[1..$#_]) }
	],
	[#Rule 72
		 'offset_clause', 2,
sub
#line 197 "grammar/Select.yp"
{
                 delete $_[0]->YYData->{offset}; join(' ', @_[1..$#_]) }
	]
],
                                  @_);
    bless($self,$class);
}

#line 201 "grammar/Select.yp"


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
        s/^\s*(\$(\w*)\$.*?\$\2\$)//
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
    $InVals = $params->{vars} || {};
    #$QuoteIdent = $params->{quote_ident};

    #$self->YYData->{INPUT} = ;
    ### $sql
    @Models = ();
    @Columns = ();
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
