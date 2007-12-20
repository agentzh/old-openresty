use Test::Base;

use lib 'lib';
use MiniSQL::Select;

#plan tests => 3 * blocks();

plan 'no_plan';

run {
    my $block = shift;
    my $name = $block->name;
    my $select = MiniSQL::Select->new;
    my $sql = $block->sql or die "$name - No --- sql section found.\n";
    my $res;
    eval {
        $res = $select->parse($sql);
    };
    my $error = $block->error;
    $error =~ s/^\s+$//g;
    is $@, $error, "$name - parsable?";
    my (@models, @cols);
    if ($res) {
        @models = @{ $res->{models} };
        @cols = @{ $res->{columns} };
    }
    my $ex_models = $block->models;
    if (defined $ex_models) {
        is join(' ', @models), $block->models, "$name - model list ok";
    }
    my $ex_cols = $block->cols;
    if (defined $ex_cols) {
        is join(' ', @cols), $block->cols, "$name - model cols ok";
    }
};

__DATA__

=== TEST 1: Simple
--- sql
select * from Carrie
--- error
--- models: Carrie
--- cols:



=== TEST 2: where clause
--- sql
select * from Carrie where name='zhxj'
--- error
--- models: Carrie
--- cols: name



=== TEST 3:
--- sql
select * from Carrie;
--- error



=== TEST 4: Bad token
--- sql
select * from Carrie blah
--- error
line 1: error: Unexpected input: "blah".



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
line 1: error: Unexpected input: "blah".



=== TEST 8: Aggregate function 'count'
--- sql
select count(*)
from Carrie
where name='zhxj';
--- error
--- models: Carrie
--- cols: name



=== TEST 9: Group by
--- sql
select sum ( * )
from People, Blah
where name='zhxj'
group by name
--- error
--- models: People Blah
--- cols: name name



=== TEST 10: Bad ";"
--- sql
select sum ( * )
from People, Blah
where name='zhxj';
group by name
--- error
line 4: error: Unexpected input: "group by".



=== TEST 11: 'and' in where
--- sql
select *
from foo
where name = 'Hi' and age > 4;
--- error
--- models: foo
--- cols: name age



=== TEST 12: 'or' in where
--- sql
select *
from blah
where name = 'Hi' or age <= 3;
--- error
--- models: blah
--- cols: name age



=== TEST 13: escaped single quotes
--- sql
select *
from blah
where name = '''Hi' or age <= 3;
--- error
line 3: error: Unexpected input: "'Hi'".



=== TEST 14: unmatched single quotes
--- sql
select *
from blah
where name = ''''Hi' or age <= 3;
--- error
line 3: error: Unexpected input: "''".



=== TEST 15: unmatched single quotes
--- sql
select *
from blah
where name = ''
--- error
--- models: blah
--- cols: name



=== TEST 16: empty string literals
--- sql
select *
from blah
where name = '' or age <= 3;
--- error
--- models: blah
--- cols: name age



=== TEST 17: sql injection
--- sql
select *
from blah
where name = '\'' and #@!##$@ --' or age <= 3;
--- error
line 3: error: Unexpected input: "' and #@!##$@ --'".



=== TEST 18: $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$$ \n\nhehe $q$ and age > 3;
--- error
--- models: blah
--- cols: name age



=== TEST 19: $q$ ... $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$q$ update nhehe $q$ and age > 3;
--- error
line 3: error: Unexpected input: "update".



=== TEST 20: $q$q$q$
--- sql
select *
from blah
where name = $q$q$q$ and age > 3;
--- error
--- models: blah
--- cols: name age



=== TEST 21: empty string literals
--- sql
select *
from Book, Student
where Book.brower = Student.name and Book.title = '' or age <= 3;
--- error
--- models: Book Student Book Student Book
--- cols: brower name title age



=== TEST 22: offset & limit
--- sql
select * from Carrie limit 1 offset 0
--- error



=== TEST 23: proc call
--- sql
select hello(1) from Carrie limit 1 offset 0
--- error



=== TEST 24: proc call with more parameters
--- sql
select hello(1, '2') from Carrie limit 1 offset 0
--- error



=== TEST 25: proc names with underscores
--- sql
select hello_world(1, '2') from Carrie limit 1 offset 0
--- error

