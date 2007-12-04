use strict;
use warnings;

use t::miniSQL;

test 'symbol', 'a', 'a';
test 'symbol', 'abc', 'abc';
test 'symbol', 'ABC', 'ABC';
test 'symbol', 'aBc', 'aBc';
test 'symbol', 'abc123', 'abc123';
test 'symbol', 'abc123_', 'abc123_';
test 'symbol', '_abc123_', '_abc123_';
test 'symbol', '_abc_123_', '_abc_123_';
test 'symbol', '123abc', 'abc';

test 'qualified_symbol', '_a3_bc_._1b_ca2_', {
    symbol => [
        symbol('_a3_bc_'),
        symbol('_1b_ca2_')
    ]
};

test 'alias', 'abc_123', {
    'symbol' => 'abc_123'
};
test 'model', '_Abc1CbA', {
    'symbol' => '_Abc1CbA'
};


test 'column', 'abc', {
    'symbol' => 'abc'
};
test 'column', 'abc.efg', {
    qualified_symbol => qualified_symbol('abc.efg')
};
