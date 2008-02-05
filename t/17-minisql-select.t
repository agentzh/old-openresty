# vi:filetype=

use Test::Base;

use Smart::Comments;
use lib 'lib';
use MiniSQL::Select;

#plan tests => 3 * blocks();

plan 'no_plan';

sub quote {
    my $s = shift;
    if (!defined $s) { $s = '' }
    $s =~ s/\n/{NEW_LINE}/g;
    $s =~ s/\r/{RETURN}/g;
    $s =~ s/\t/{TAB}/g;
    '$y$' . $s . '$y$';
}

sub quote_ident {
    qq/"$_[0]"/
}

run {
    my $block = shift;
    my $name = $block->name;

    my %in_vars;
    my $in_vars = $block->in_vars;
    if (defined $in_vars) {
        my @ln = split /\n+/, $in_vars;
        map {
            my ($var, $val) = split /=/, $_, 2;
            $in_vars{$var} = $val;
        } @ln;
    }

    my $select = MiniSQL::Select->new;
    my $sql = $block->sql or die "$name - No --- sql section found.\n";
    my $res;
    eval {
        $res = $select->parse(
            $sql,
            {
                quote => \&quote,
                quote_ident => \&quote_ident,
                vars => \%in_vars,
            }
        );
    };
    my $error = $block->error || '';
    $error =~ s/^\s+$//g;
    is $@, $error, "$name - parse ok";
    my (@models, @cols, @vars, @unbound);
    if ($res) {
        @models = grep { defined $_ && $_ ne '' } @{ $res->{models} };
        @cols = grep { defined $_ && $_ ne '' } @{ $res->{columns} };
        @vars = grep { defined $_ && $_ ne '' } @{ $res->{vars} };
        @unbound = grep { defined $_ && $_ ne '' } @{ $res->{unbound} };
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
    my $ex_vars = $block->vars;
    if (defined $ex_vars) {
        is join(' ', @vars), $ex_vars, "$name - var list ok";
    }
    my $ex_unbound = $block->unbound;
    if (defined $ex_unbound) {
        is join(' ', @unbound), $ex_unbound, "$name - unbound var list ok";
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
--- out: select * from "Carrie" where "name" = $y$zhxj$y$



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
line 3: error: Unexpected end of input (VAR or IDENT or '(' expected).



=== TEST 6: Aggregate function 'count'
--- sql
select count(*)
from Carrie
where name='zhxj';
--- error
--- models: Carrie
--- cols: name
--- out: select count ( * ) from "Carrie" where "name" = $y$zhxj$y$



=== TEST 7: Group by
--- sql
select sum ( * )
from People, Blah
where name='zhxj'
group by name
--- error
--- models: People Blah
--- cols: name name
--- out: select sum ( * ) from "People" , "Blah" where "name" = $y$zhxj$y$ group by "name"



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
--- out: select * from "foo" where "name" = $y$Hi$y$ and "age" > 4



=== TEST 10: 'or' in where
--- sql
select *
from blah
where name = 'Hi' or age <= 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = $y$Hi$y$ or "age" <= 3



=== TEST 11: escaped single quotes
--- sql
select *
from blah
where name = '''Hi' or age <= 3;
--- error
--- out: select * from "blah" where "name" = $y$'Hi$y$ or "age" <= 3



=== TEST 12: unmatched single quotes
--- sql
select *
from blah
where name = ''''Hi' or age <= 3;
--- error
line 3: error: Unexpected input: "Hi".



=== TEST 13: unmatched single quotes
--- sql
select *
from blah
where name = ''
--- error
--- models: blah
--- cols: name
--- out: select * from "blah" where "name" = $y$$y$ 



=== TEST 14: empty string literals
--- sql
select *
from blah
where name = '' or age <= 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = $y$$y$ or "age" <= 3



=== TEST 15: sql injection
--- sql
select *
from blah
where name = '\'' and #@!##$@ --' or age <= 3;
--- error
line 3: error: Unexpected input: "#" (VAR or IDENT or '(' expected).



=== TEST 16: $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$$ \n\nhehe $q$ and age > 3;
--- error
--- models: blah
--- cols: name age
--- out: select * from "blah" where "name" = $y$Laser's gift...$$ \n\nhehe $y$ and "age" > 3



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
--- out: select * from "blah" where "name" = $y$q$y$ and "age" > 3



=== TEST 19: empty string literals
--- sql
select *
from Book, Student
where Book.browser = Student.name and Book.title = '' or age <= 3;
--- error
--- models: Book Student Book Student Book
--- cols: browser name title age
--- out: select * from "Book" , "Student" where "Book"."browser" = "Student"."name" and "Book"."title" = $y$$y$ or "age" <= 3



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
--- out: select hello ( 1 , $y$2$y$ ) from "Carrie" limit 1 offset 0



=== TEST 23: proc names with underscores
--- sql
select hello_world(1, '2') from Carrie limit 1 offset 0
--- models: Carrie
--- cols:
--- out: select hello_world ( 1 , $y$2$y$ ) from "Carrie" limit 1 offset 0



=== TEST 24: from a proc call
--- sql
select * from hello_world(1, '2')
--- models:
--- cols:
--- out: select * from hello_world ( 1 , $y$2$y$ )



=== TEST 25: from a proc call
--- sql
select * from foo where bar = 'a''b\'\\' and a >= 3
--- models: foo
--- cols: bar a
--- out: select * from "foo" where "bar" = $y$a'b'\$y$ and "a" >= 3



=== TEST 26: Test the literal
--- sql
select * from foo where bar = '\n\t\r\'\\'''
--- error
--- out: select * from "foo" where "bar" = $y${NEW_LINE}{TAB}{RETURN}'\'$y$



=== TEST 27: Test the literal
--- sql
select * from foo where bar = $$hi$$
--- error
--- unbound:
--- out: select * from "foo" where "bar" = $y$hi$y$



=== TEST 28: Test the literal
--- sql
select * from foo where bar = $hello$hi$h$$hello$ and a>3
--- error
--- unbound:
--- out: select * from "foo" where "bar" = $y$hi$h$$y$ and "a" > 3



=== TEST 29: variable interpolation
--- sql
select * from $model where $col = 'hello'
--- models:
--- cols:
--- vars: model col
--- unbound: model col
--- out: select * from "" where "" = $y$hello$y$



=== TEST 30: variable interpolation
--- sql
select * from $model where $col = 'hello'
--- in_vars
model=blah
col=foo
--- models: blah
--- cols: foo
--- vars: model col
--- unbound:
--- out: select * from "blah" where "foo" = $y$hello$y$



=== TEST 31: variable interpolation
--- sql
select * from $model where col = $value order by $col
--- in_vars
model=blah
col=baz
value='howdy'
--- models: blah
--- cols: col baz
--- vars: model value col
--- unbound:
--- out: select * from "blah" where "col" = $y$'howdy'$y$ order by "baz"



=== TEST 32: default values for vars
--- sql
select * from $model where col = $value|'val' order by $col
--- models:
--- cols: col
--- vars: model value col
--- unbound: model col
--- out: select * from "" where "col" = $y$val$y$ order by ""



=== TEST 33: default values for vars
--- sql
select * from $model where col = $value|'val' order by $col
--- in_vars
model=blah
col=baz
--- models: blah
--- cols: col baz
--- vars: model value col
--- unbound:
--- out: select * from "blah" where "col" = $y$val$y$ order by "baz"



=== TEST 34: default values for vars (override it)
--- sql
select * from $model where col = $value|'val' order by $col
--- in_vars
model=blah
col=baz
value='howdy''!'
--- models: blah
--- cols: col baz
--- vars: model value col
--- unbound:
--- out: select * from "blah" where "col" = $y$'howdy''!'$y$ order by "baz"



=== TEST 35: default values for vars (columns)
--- sql
select * from $model where col = $value|'val' order by $col|id
--- in_vars
model=blah
--- models: blah
--- cols: col id
--- vars: model value col
--- out: select * from "blah" where "col" = $y$val$y$ order by "id"



=== TEST 36: default values for vars (columns)
--- sql
select * from $model where col = $value|'val' order by $col|id
--- in_vars
model=blah
col=baz
--- models: blah
--- cols: col baz
--- vars: model value col
--- unbound:
--- out: select * from "blah" where "col" = $y$val$y$ order by "baz"



=== TEST 37: unbound vars in literals
--- sql
select * from $model_1, $model_2 where $col = $value and $blah = $val2 | 32
--- in_vars
model_1=Cat
--- models: Cat
--- cols:
--- unbound: model_2 col value blah
--- out: select * from "Cat" , "" where "" = $y$$y$ and "" = 32



=== TEST 38: keywords in uppercase
--- sql
SELECT * FROM shangtest WHERE col='value'
--- error
--- models: shangtest
--- cols: col
--- out: select * from "shangtest" where "col" = $y$value$y$



=== TEST 39: keywords in lower and upper case
--- sql
sEleCt * frOM shangtest WHerE col='value'
--- error
--- models: shangtest
--- cols: col
--- out: select * from "shangtest" where "col" = $y$value$y$



=== TEST 40: nude keywords
--- sql
select * from from where select='abc'
--- error
line 1: error: Unexpected input: "from" (VAR or IDENT expected).



=== TEST 41: keywords with "
--- sql
select * from "from" where "select"='abc'
--- error
--- models: from
--- cols: select
--- out: select * from "from" where "select" = $y$abc$y$



=== TEST 42: order by with asc
--- sql
select * from blah order by id asc
--- error
--- out: select * from "blah" order by "id" asc



=== TEST 43: order by with asc/desc
--- sql
select * from blah order by id desc, name asc
--- error
--- out: select * from "blah" order by "id" desc , "name" asc



=== TEST 44:offset & limit with vars
--- sql
select * from blah offset $offset | 0 limit $limit | 32
--- in_vars
--- error
--- out: select * from "blah" offset 0 limit 32



=== TEST 45: column alias
--- sql
select Post.id as ID from Post
--- out: select "Post"."id" as ID from "Post"
--- cols: id
--- models: Post Post



=== TEST 46: union
--- sql
(select Blah) union ( select Foo where id >= 3 )
--- out: ( select "Blah" ) union ( select "Foo" where "id" >= 3 )
--- models:
--- cols: Blah Foo id



=== TEST 47: intersect
--- sql
( select Blah ) intersect (select Foo where id >= 3)
--- out: ( select "Blah" ) intersect ( select "Foo" where "id" >= 3 )
--- models:
--- cols: Blah Foo id



=== TEST 48: except
--- sql
(select Blah) except(  select Foo where id >= 3)
--- out: ( select "Blah" ) except ( select "Foo" where "id" >= 3 )
--- models:
--- cols: Blah Foo id



=== TEST 49: big union
--- sql
        (select id, title
        from Post
        where id > $current
        order by id asc
        limit 1)
      union
        (select id, title
        from Post
        where id < $current
        order by id desc
        limit 1)
--- out: ( select "id" , "title" from "Post" where "id" > $y$$y$ order by "id" asc limit 1 ) union ( select "id" , "title" from "Post" where "id" < $y$$y$ order by "id" desc limit 1 )



=== TEST 50: select literals
--- sql: select 0 as id, 'a' as title, 32
--- out: select 0 as id , $y$a$y$ as title , 32



=== TEST 51: regression in 19-view.t
--- sql: select $select_col from A order by $order_by
--- in_vars
select_col=id
order_by=id
--- out: select "id" from "A" order by "id"


