use strict;
use warnings;

package OpenResty::miniSQL;

use OpenResty::miniSQL::Compile; 

grammar OpenResty::miniSQL;

%{

sub cp_match_array(@) {
    my $arr_ref = shift;
    my @a = map {$$_} @$arr_ref;
    return \@a;
}

sub add_if_exists(@) {
    my ($r, $ref, $name) = @_;
    $r->{$name} = ${$ref->[0]} if defined($ref);
}

%}

# number literal

token number {
    | <approximate_float> {
        return { approximate_float => $$<approximate_float> }
    }
    | <exact_float> {
        return { exact_float => $$<exact_float> }
    }
    | <integer> {
        return { integer => $$<integer> }
    }
}
token approximate_float {
    ( [ <.exact_float> | <.integer> ] <[eE]> <.integer> ) { return $$<0> }
}
token exact_float {
    ( <.sign>? <.unsigned_integer>? '.' <.unsigned_integer> ) { return $$<0> }
}
token integer {
    ( <.unsigned_integer> | <.signed_integer> ) { return $$<0> }
}
token unsigned_integer { <.digit>+ }
token signed_integer { <.sign> <.unsigned_integer> }
token sign { [ '-' | '+' ] }

# string literal

token string {
    | \' (<-[\']>* [ \' \' <-[\']>* ]*) \' {
        (my $r = $$<0>) =~ s/\'\'/\'/g;
        return { single_quoted_string => $r };
    }
    | \" (<-[\"]>* [ \" \" <-[\"]>* ]*) \" {
        (my $r = $$<0>) =~ s/\"\"/\"/g;
        return { double_quoted_string => $r };
    }
}

# literal

token literal {
    | <string> { return { string => $$<string> } }
    | <number> { return { number => $$<number> } }
}

# symbols

token symbol { (<[A..Za..z_]> <[A..Za..z0..9_]>*) { return $$<0> } }
token qualified_symbol {
    <symbol>**{1} '.' <symbol>**{1} {
        return { symbol => cp_match_array($<symbol>) }
    }
}
token alias { <symbol> { return { symbol => $$<symbol> } } }
token model { <symbol> { return { symbol => $$<symbol> } } }
token column {
    | <qualified_symbol> {
        return { qualified_symbol => $$<qualified_symbol> }
    }
    | <symbol> {
        return { symbol => $$<symbol> }
    }
}

# condition

token condition {
    <disjunction> {
        return { disjunction => $$<disjunction> }
    }
}
token disjunction {
    <conjunction>**{1} [ <.ws> 'or' <.ws> <conjunction> ]* {
        return { conjunction => cp_match_array($<conjunction>) }
    }
}
token conjunction {
    <comparison>**{1} [ <.ws> 'and' <.ws> <comparison> ]* {
        return { comparison => cp_match_array($<comparison>) }
    }
}
token comparison {
    | <value>**{1} <.ws> <rel_op> <.ws> <value>**{1} {
        return { value => cp_match_array($<value>),
                 rel_op => $$<rel_op> }
    }
    | '(' <.ws> <condition> <.ws> ')' {
        return { condition => $$<condition> }
    }
}
token value {
    | <column> { return { column => $$<column>} }
    | <literal> { return { literal => $$<literal> } }
}
token rel_op {
    ( '>=' | '<=' | '<>' | '>' | '<' | '=' | 'like' ) { return $$<0> }
}

# statements

token statement {
    | <select_stmt> { return { select_stmt => $$<select_stmt> } }
    | <update_stmt> { return { update_stmt => $$<update_stmt> } }
    | <delete_stmt> { return { delete_stmt => $$<delete_stmt> } }
}

# select statement

token select_stmt {
    | 'select' <.ws> <patterns> <.ws> 'from' <.ws> <models>
    [ <.ws> <where_clause> ]?
    [ <.ws> <orderby_clause> ]?
    [ <.ws> <groupby_clause> ]? {
        my $r = { patterns => $$<patterns>, models => $$<models> };
        add_if_exists $r, $<where_clause>, 'where_clause';
        add_if_exists $r, $<orderby_clause>, 'orderby_clause';
        add_if_exists $r, $<groupby_clause>, 'groupby_clause';
        return $r;
    }
}
token patterns {
    | '*' { return { pattern => '*' } }
    | <pattern>**{1} [ <.ws> ',' <.ws> <pattern> ]* {        
        return { pattern => cp_match_array($<pattern>) }
    }
}
token pattern {
    <pattern_core> <.ws> <alias>? {
        my $r = { pattern_core => $$<pattern_core> };
        add_if_exists $r, $<alias>, 'alias';
        return $r;
    }
}
token pattern_core {
    | <aggregate> {
        return { aggregate => $$<aggregate> }
    }
    | <column> {
        return { column => $$<column> }
    }
}
token aggregate {
    <aggr_func> <.ws> '(' <.ws> <column> <.ws> ')' {
        return { aggr_func => $$<aggr_func>,
                 column => $$<column> }
    }
}
token aggr_func {
    ( 'max' | 'min' | 'count' | 'sum' ) {
        return $$<0>;
    }
}
token models {
    <model>**{1} [ <.ws> ',' <.ws> <model> ]* {        
        return { model => cp_match_array($<model>) }
    }
}
token where_clause {
    'where' <.ws> <condition> {
        return { condition => $$<condition> }
    }
}
token orderby_clause {
    'order' <.ws> 'by' <.ws> <ordered_columns> {
        return { ordered_columns => $$<ordered_columns> }
    }
}
token groupby_clause {
    'group' <.ws> 'by' <.ws> <columns> {
        return { columns => $$<columns> }
    }
}
token ordered_columns {
    <ordered_column>**{1} [ <.ws> ',' <.ws> <ordered_column> ]* {        
        return { ordered_column => cp_match_array($<ordered_column>) }
    }
}
token ordered_column {
    <column> [ <.ws> ( 'desc' | 'asc' ) ]? {
        my $r = { column => $$<column> };
        add_if_exists $r, $<0>, 'order';
        return $r;
    }
}
token columns {
    <column>**{1} [ <.ws> ',' <.ws> <column>]* {        
        return { column => cp_match_array($<column>) }
    }
}

# delete, update statements

token delete_stmt {
    'delete' <.ws> 'from' <.ws> <model>
    [ <.ws> <where_clause> ]? {
        my $r = { model => $$<model> };
        add_if_exists $r, $<where_clause>, 'where_clause';
        return $r;
    }
}
token assignment {
    <column> <.ws> '=' <.ws> <literal> {
        return { column => $$<column>, literal => $$<literal> }
    }
}
token set_clause {
    'set' <.ws> <assignment>**{1} [ <.ws> ',' <.ws> <assignment> ]* {
        return { assignment => cp_match_array($<assignment>) }
    }
}
token update_stmt {
    'update' <.ws> <model> <.ws> <set_clause>
    [ <.ws> <where_clause> ]? {
        my $r = { model => $$<model>, set_clause => $$<set_clause> };
        add_if_exists $r, $<where_clause>, 'where_clause';
        return $r;
    }
}








