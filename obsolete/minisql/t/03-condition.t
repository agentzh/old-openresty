use strict;
use warnings;

use t::miniSQL;

# value
test 'value', 'abc', {
    column => column('abc')
};
test 'value', '123', {
    literal => literal('123')
};

# rel_op
test 'rel_op', '>=', '>=';
test 'rel_op', '<=', '<=';
test 'rel_op', '<>', '<>';
test 'rel_op', '>', '>';
test 'rel_op', '=', '=';
test 'rel_op', '<', '<';
test 'rel_op', 'like', 'like';

# comparison
test 'comparison', 'abc > 123', {
    value => [
        value('abc'),
        value('123')
    ],
    rel_op => '>'
};
test 'comparison', '123 = abc', {
    value => [
        value('123'),
        value('abc')
    ],
    rel_op => '='
};
test 'comparison', 'my_name like "abc%" ', {
    value => [
        value('my_name'),
        value('"abc%"')
    ],
    rel_op => 'like'
};
test 'comparison', '( a > b )', {
    condition => condition('a > b')
};

# conjunction
test 'conjunction', 'a > b and c <= d', {
    comparison => [
        comparison('a > b'),
        comparison('c <= d')
    ]    
};
test 'conjunction', 'a <> b and c >= d and e < f', {
    comparison => [
        comparison('a <> b'),
        comparison('c >= d'),
        comparison('e < f')
    ]    
};

# disjunction
test 'disjunction', 'a > b or c <= d', {
    conjunction => [
        conjunction('a > b'),
        conjunction('c <= d')
    ]
};
test 'disjunction', 'a <> b and c <= d or a > e or b = a', {
    conjunction => [
        conjunction('a <> b and c <= d'),
        conjunction('a > e'),
        conjunction('b = a')
    ]
};

# condition
test 'condition', '(a > b or c < d) and x like "1%a"', {
    disjunction => disjunction('(a > b or c < d) and x like "1%a"')
};




