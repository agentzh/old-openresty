use strict;
use warnings;

use t::miniSQL;

# patterns
test 'aggr_func', 'max', 'max';
test 'aggr_func', 'min', 'min';
test 'aggr_func', 'count', 'count';
test 'aggr_func', 'sum', 'sum';
test 'aggregate', 'sum ( abc )', {
    aggr_func => 'sum',
    column => column('abc')
};
test 'pattern_core', 'count (a12)', {
    aggregate => aggregate('count (a12)')
};
test 'pattern_core', 'abc', {
    column => column('abc')
};
test 'pattern', 'abc def', {
    pattern_core => pattern_core('abc'),
    alias => alias('def')
};
test 'pattern', 'sum(abc)', {
    pattern_core => pattern_core('sum(abc)')
};
test 'patterns', 'a', {
    pattern => [
        pattern('a')
    ]
};
test 'patterns', 'sum(abc) , abc def', {
    pattern => [
        pattern('sum(abc)'),
        pattern('abc def')
    ]
};

# models
test 'models', 'a', {
    model => [
        model('a')
    ]
};
test 'models', 'a, b, c', {
    model => [
        model('a'),
        model('b'),
        model('c')
    ]
};

# where_clause
test 'where_clause', 'where a>b and c=d', {
    condition => condition('a>b and c=d')
};

# orderby_clause
test 'ordered_column', 'a.b desc', {
    column => column('a.b'),
    order => 'desc'
};
test 'ordered_column', 'a', {
    column => column('a')
};
test 'ordered_columns', 'a', {
    ordered_column => [
        ordered_column('a')
    ]
};
test 'ordered_columns', 'a.b asc, b, c desc', {
    ordered_column => [
        ordered_column('a.b asc'),
        ordered_column('b'),
        ordered_column('c desc')
    ]
};
test 'orderby_clause', 'order by a asc, b', {
    ordered_columns => ordered_columns('a asc, b')
};

# groupby_clause
test 'columns', 'a', {
    column => [
        column('a')
    ]
};
test 'columns', 'a.a, b, c.c', {
    column => [
        column('a.a'),
        column('b'),
        column('c.c')
    ]
};
test 'groupby_clause', 'group by a.b, c', {
    columns => columns('a.b, c')
};

# select_stmt
test 'select_stmt', 'select * from a', {
    patterns => patterns('*'),
    models => models('a')
};
test 'select_stmt', 'select a.a b, c d from m1, m2', {
    patterns => patterns('a.a b, c d'),
    models => models('m1, m2')
};
test 'select_stmt',
    'select select from from where where a>order order by group group by a', {
    patterns => patterns('select from'),
    models => models('where'),
    where_clause => where_clause('where a>order'),
    orderby_clause => orderby_clause('order by group'),
    groupby_clause => groupby_clause('group by a')    
};
    
# delete_stmt
test 'delete_stmt', 'delete from a', {
    model => model('a')
};
test 'delete_stmt', 'delete from a where b>c', {
    model => model('a'),
    where_clause => where_clause('where b>c')
};

# assignment
test 'assignment', 'a = 1', {
    column => column('a'),
    literal => literal('1')
};

# set_clause
test 'set_clause', 'set a = 1', {
    assignment => [
        assignment('a = 1')
    ]
};
test 'set_clause', 'set a = 1, b = 2', {
    assignment => [
        assignment('a = 1'),
        assignment('b = 2')
    ]
};

# update_stmt
test 'update_stmt', 'update m set a = 1', {
    model => model('m'),
    set_clause => set_clause('set a = 1')
};
test 'update_stmt', 'update m set a = 1 where b > c', {
    model => model('m'),
    set_clause => set_clause('set a = 1'),
    where_clause => where_clause('where b > c')
};
