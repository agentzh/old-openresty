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
line 3: error: Unexpected end of input.



=== TEST 7:
--- sql
select * from Carrie blah
--- error
line 1: error: Unexpected input: 'blah'.

