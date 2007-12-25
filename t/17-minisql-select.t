use Test::Base;

use Smart::Comments;
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
    if (defined $block->out) {
        is $res->{sql}, $block->out, "$name - sql emittion ok";
    }
};

__DATA__

=== TEST 1: Simple
--- sql
select * from Carrie
--- error
--- models: Carrie
--- cols:
--- out: select * from "Carrie"



=== TEST 2: where clause
--- sql
select * from Carrie where name='zhxj'
--- error
--- models: Carrie
--- cols: name
--- out: select * from "Carrie" where "name" = 'zhxj'



=== TEST 3: with trailing ;
--- sql
select * from Carrie;
--- error
--- out: select * from "Carrie"



=== TEST 4: Bad token
--- sql
select * from Carrie blah
--- error
line 1: error: Unexpected input: "blah".



=== TEST 5: Unexpected end of input
--- sql
select *
from Carrie
where
--- error
line 3: error: Unexpected end of input (IDENT or '(' expected).



=== TEST 6: Aggregate function 'count'
--- sql
select count(*)
from Carrie
where name='zhxj';
--- error
--- models: Carrie
--- cols: name
--- out: select count ( * ) from "Carrie" where "name" = 'zhxj'



=== TEST 7: Group by
--- sql
select sum ( * )
from People, Blah
where name='zhxj'
group by name
--- error
--- models: People Blah
--- cols: name name
--- out: select sum ( * ) from "People" , "Blah" where "name" = 'zhxj' group by "name"



=== TEST 8: Bad ";"
--- sql
select sum ( * )
from People, Blah
where name='zhxj';
group by name
--- error
line 4: error: Unexpected input: "group by".



=== TEST 9: 'and' in where
--- sql
select *
from foo
where name = 'Hi' and age > 4;
--- error
--- models: foo
--- cols: name age
--- out: select * from "foo" where "name" = 'Hi' and "age" > 4



=== TEST 10: 'or' in where
--- sql
select *
from blah
where name = 'Hi' or age <= 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = 'Hi' or "age" <= 3



=== TEST 11: escaped single quotes
--- sql
select *
from blah
where name = '''Hi' or age <= 3;
--- error
line 3: error: Unexpected input: "'Hi'".



=== TEST 12: unmatched single quotes
--- sql
select *
from blah
where name = ''''Hi' or age <= 3;
--- error
line 3: error: Unexpected input: "''".



=== TEST 13: unmatched single quotes
--- sql
select *
from blah
where name = ''
--- error
--- models: blah
--- cols: name
--- out: select * from "blah" where "name" = ''



=== TEST 14: empty string literals
--- sql
select *
from blah
where name = '' or age <= 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = '' or "age" <= 3



=== TEST 15: sql injection
--- sql
select *
from blah
where name = '\'' and #@!##$@ --' or age <= 3;
--- error
line 3: error: Unexpected input: "' and #@!##$@ --'".



=== TEST 16: $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$$ \n\nhehe $q$ and age > 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = $q$Laser's gift...$$ \n\nhehe $q$ and "age" > 3



=== TEST 17: $q$ ... $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$q$ update nhehe $q$ and age > 3;
--- error
line 3: error: Unexpected input: "update".



=== TEST 18: $q$q$q$
--- sql
select *
from blah
where name = $q$q$q$ and age > 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = $q$q$q$ and "age" > 3



=== TEST 19: empty string literals
--- sql
select *
from Book, Student
where Book.browser = Student.name and Book.title = '' or age <= 3;
--- error
--- models: Book Student Book Student Book
--- cols: browser name title age
--- out: select * from "Book" , "Student" where "Book"."browser" = "Student"."name" and "Book"."title" = '' or "age" <= 3



=== TEST 20: offset & limit
--- sql
select * from Carrie limit 1 offset 0
--- error
--- out: select * from "Carrie" limit 1 offset 0



=== TEST 21: proc call
--- sql
select hello(1) from Carrie limit 1 offset 0
--- error
--- out: select hello ( 1 ) from "Carrie" limit 1 offset 0



=== TEST 22: proc call with more parameters
--- sql
select hello(1, '2') from Carrie limit 1 offset 0
--- error
--- out: select hello ( 1 , '2' ) from "Carrie" limit 1 offset 0



=== TEST 23: proc names with underscores
--- sql
select hello_world(1, '2') from Carrie limit 1 offset 0
--- error
--- models: Carrie
--- cols:
--- out: select hello_world ( 1 , '2' ) from "Carrie" limit 1 offset 0



=== TEST 24: from a proc call
--- sql
select * from hello_world(1, '2')
--- error
--- models:
--- cols:
--- out: select * from hello_world ( 1 , '2' )

