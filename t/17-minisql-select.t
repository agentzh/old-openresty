use Test::Base;

use lib 'lib';
use MiniSQL::Select;

plan tests => 1 * blocks();

run {
    my $block = shift;
    my $name = $block->name;
    my $select = MiniSQL::Select->new;
    my $sql = $block->sql or die "$name - No --- sql section found.\n";
    eval {
        $select->parse($sql);
    };
    my $error = $block->error;
    $error =~ s/^\s+$//g;
    is $@, $error, "$name - parsable?";
};

__DATA__

=== TEST 1: Simple
--- sql
select * from Carrie
--- error



=== TEST 2: where clause
--- sql
select * from Carrie where name='zhxj'
--- error



=== TEST 3:
--- sql
select * from Carrie;
--- error



=== TEST 4: Bad token
--- sql
select * from Carrie blah
--- error
line 1: error: Unexpected input: 'blah'.



=== TEST 5: Select w/o where or other clauses
--- sql
select * from Carrie;
--- error



=== TEST 6: Unexpected end of input
--- sql
select *
from Carrie
where
--- error
line 3: error: Unexpected end of input (IDENT or '(' expected).



=== TEST 7:
--- sql
select * from Carrie blah
--- error
line 1: error: Unexpected input: 'blah'.



=== TEST 8: Aggregate function 'count'
--- sql
select count(*)
from Carrie
where name='zhxj';
--- error



=== TEST 9: Group by
--- sql
select sum ( * )
from People, Blah
where name='zhxj'
group by name
--- error



=== TEST 10: Bad ";"
--- sql
select sum ( * )
from People, Blah
where name='zhxj';
group by name
--- error
line 4: error: Unexpected input: 'group by'.



=== TEST 11: 'and' in where
--- sql
select *
from foo
where name = 'Hi' and age > 4;
--- error



=== TEST 12: 'or' in where
--- sql
select *
from blah
where name = 'Hi' or age <= 3;
--- error

