# vi:filetype=

# Tests for the OpenResty::RestyScript module.

use Test::Base;

#use Smart::Comments;
use lib 'lib';
use OpenResty::RestyScript;

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

    my $sql = $block->sql or die "$name - No --- sql section found.\n";
    my $view = OpenResty::RestyScript->new('view', $sql);
    my ($frags, $stats);
    eval {
        ($frags, $stats) = $view->compile;
    };
    ### Fragments: $frags
    ### Stats: $stats
    my $res;
    if ($@ && !defined $block->error) { warn $@ }
    elsif (defined $block->error) {
        my $error = $block->error || '';
        $error =~ s/^\s+$//g;
        (my $got = $@) =~ s/^expecting .*\n//ms;
        is $got, $error, "$name - error msg ok";
    }
    #%in_vars,
    my (@models, @cols, @vars, @unbound);
    if ($stats) {
        @models = @{ $stats->{modelList} };
        @vars = grep { defined $_ && $_ ne '' } @{ $res->{vars} };
        @unbound = grep { defined $_ && $_ ne '' } @{ $res->{unbound} };
    }
    ### @models
    my $pgsql = $frags ? (join '', @$frags) : '';
    my $ex_models = $block->models;
    if (defined $ex_models) {
        is join(' ', @models), $block->models, "$name - model list ok";
    }
    my $ex_cols = $block->cols;
    if (defined $ex_cols) {
        is join(' ', @cols), $block->cols, "$name - model cols ok";
    }
    if (defined $block->out) {
        (my $expected = $block->out) =~ s/\n$//g;
        is $pgsql, $expected, "$name - sql emittion ok";
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
"RestyView" (line 1, column 22):
unexpected "b"



=== TEST 5: Unexpected end of input
--- sql
select *
from Carrie
where
--- error
"RestyView" (line 4, column 1):
unexpected end of input



=== TEST 6: Aggregate function 'count'
--- sql
select count(*)
from Carrie
where name='zhxj';
--- error
--- models: Carrie
--- out: select "count"(*) from "Carrie" where "name" = 'zhxj'



=== TEST 7: Group by
--- sql
select sum ( * ) as blah
from People, Blah
where name='zhxj'
group by name
--- error
--- models: People Blah
--- out
select "sum"(*) as "blah" from "People", "Blah" where "name" = 'zhxj' group by "name"



=== TEST 8: Bad ";"
--- sql
select sum ( * )
from People, Blah
where name='zhxj';
group by name
--- error
"RestyView" (line 4, column 1):
unexpected "g"



=== TEST 9: 'and' in where
--- sql
select *
from foo
where name = 'Hi' and age > 4;
--- error
--- models: foo
--- out: select * from "foo" where ("name" = 'Hi' and "age" > 4)



=== TEST 10: 'or' in where
--- sql
select *
from blah
where name = 'Hi' or age <= 3;
--- error
--- models: blah
--- out: select * from "blah" where ("name" = 'Hi' or "age" <= 3)



=== TEST 11: escaped single quotes
--- sql
select *
from blah
where name = '''Hi' or age <= 3;
--- error
--- out: select * from "blah" where ("name" = '''Hi' or "age" <= 3)



=== TEST 12: unmatched single quotes
--- sql
select *
from blah
where name = ''''Hi' or age <= 3;
--- error
"RestyView" (line 3, column 18):
unexpected "H"



=== TEST 13: unmatched single quotes
--- sql
select *
from blah
where name = ''
--- error
--- models: blah
--- out: select * from "blah" where "name" = ''



=== TEST 14: empty string literals
--- sql
select *
from blah
where name = '' or age <= 3;
--- error
--- models: blah
--- out: select * from "blah" where ("name" = '' or "age" <= 3)



=== TEST 15: sql injection
--- sql
select *
from blah
where name = '\'' and #@!##$@ --' or age <= 3;
--- error
"RestyView" (line 3, column 23):
unexpected "#"



=== TEST 16: $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$$ \n\nhehe $q$ and age > 3;
--- error
--- models: blah
--- out: select * from "blah" where ("name" = 'Laser''s gift...$$ \\n\\nhehe ' and "age" > 3)



=== TEST 17: $q$ ... $q$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$q$ update nhehe $q$ and age > 3;
--- error
"RestyView" (line 3, column 36):
unexpected "u"



=== TEST 18: $q$ ... $a$ ... $q$
--- sql
select *
from blah
where name = $q$Laser's gift...$a$ update nhehe $q$ and age > 3;
--- out
select * from "blah" where ("name" = 'Laser''s gift...$a$ update nhehe ' and "age" > 3)



=== TEST 19: $q$q$q$
--- sql
select *
from blah
where name = $q$q$q$ and age > 3;
--- error
--- models: blah
--- out: select * from "blah" where ("name" = 'q' and "age" > 3)



=== TEST 20: empty string literals
--- sql
select *
from Book, Student
where Book.browser = Student.name and Book.title = '' or age <= 3;
--- error
--- models: Book Student
--- out: select * from "Book", "Student" where (("Book"."browser" = "Student"."name" and "Book"."title" = '') or "age" <= 3)


=== TEST 21: offset & limit
--- sql
select * from Carrie limit 1 offset 0
--- error
--- out: select * from "Carrie" limit 1 offset 0



=== TEST 22: proc call
--- sql
select hello(1) from Carrie limit 1 offset 0
--- error
--- out: select "hello"(1) from "Carrie" limit 1 offset 0



=== TEST 23: proc call with more parameters
--- sql
select hello(1, '2') from Carrie limit 1 offset 0
--- error
--- out: select "hello"(1, '2') from "Carrie" limit 1 offset 0



=== TEST 24: proc names with underscores
--- sql
select hello_world(1, '2') from Carrie limit 1 offset 0
--- models: Carrie
--- out: select "hello_world"(1, '2') from "Carrie" limit 1 offset 0



=== TEST 25: from a proc call
--- sql
select * from hello_world(1, '2')
--- models:
--- out: select * from "hello_world"(1, '2')



=== TEST 26: from a proc call
--- sql
select * from foo where bar = 'a''b\'\\' and a >= 3
--- models: foo
--- out: select * from "foo" where ("bar" = 'a''b''\\' and "a" >= 3)



=== TEST 27: Test the literal
--- sql
select * from foo where bar = '\n\t\r\'\\'''
--- error
--- out: select * from "foo" where "bar" = '\n\t\r''\\'''



=== TEST 28: Test the literal
--- sql
select * from foo where bar = $$hi$$
--- error
--- unbound:
--- out: select * from "foo" where "bar" = 'hi'
--- LAST



=== TEST 29: Test the literal
--- sql
select * from foo where bar = $hello$hi$h$$hello$ and a>3
--- error
--- unbound:
--- out: select * from "foo" where "bar" = $y$hi$h$$y$ and "a" > 3



=== TEST 30: variable interpolation
--- sql
select * from $model where $col = 'hello'
--- models:
--- cols:
--- vars: model col
--- unbound: model col
--- out: select * from "" where "" = $y$hello$y$



=== TEST 31: variable interpolation
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



=== TEST 32: variable interpolation
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



=== TEST 33: default values for vars
--- sql
select * from $model where col = $value|'val' order by $col
--- models:
--- cols: col
--- vars: model value col
--- unbound: model col
--- out: select * from "" where "col" = $y$val$y$ order by ""



=== TEST 34: default values for vars
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



=== TEST 35: default values for vars (override it)
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



=== TEST 36: default values for vars (columns)
--- sql
select * from $model where col = $value|'val' order by $col|id
--- in_vars
model=blah
--- models: blah
--- cols: col id
--- vars: model value col
--- out: select * from "blah" where "col" = $y$val$y$ order by "id"



=== TEST 37: default values for vars (columns)
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



=== TEST 38: unbound vars in literals
--- sql
select * from $model_1, $model_2 where $col = $value and $blah = $val2 | 32
--- in_vars
model_1=Cat
--- models: Cat
--- cols:
--- unbound: model_2 col value blah
--- out: select * from "Cat" , "" where "" = $y$$y$ and "" = 32



=== TEST 39: keywords in uppercase
--- sql
SELECT * FROM shangtest WHERE col='value'
--- error
--- models: shangtest
--- cols: col
--- out: select * from "shangtest" where "col" = $y$value$y$



=== TEST 40: keywords in lower and upper case
--- sql
sEleCt * frOM shangtest WHerE col='value'
--- error
--- models: shangtest
--- cols: col
--- out: select * from "shangtest" where "col" = $y$value$y$



=== TEST 41: nude keywords
--- sql
select * from from where select='abc'
--- error
line 1: error: Unexpected input: "from" (VAR or IDENT expected).



=== TEST 42: keywords with "
--- sql
select * from "from" where "select"='abc'
--- error
--- models: from
--- cols: select
--- out: select * from "from" where "select" = $y$abc$y$



=== TEST 43: order by with asc
--- sql
select * from blah order by id asc
--- error
--- out: select * from "blah" order by "id" asc



=== TEST 44: order by with asc/desc
--- sql
select * from blah order by id desc, name asc
--- error
--- out: select * from "blah" order by "id" desc , "name" asc



=== TEST 45:offset & limit with vars
--- sql
select * from blah offset $offset | 0 limit $limit | 32
--- in_vars
--- error
--- out: select * from "blah" offset 0 limit 32



=== TEST 46: column alias
--- sql
select Post.id as ID from Post
--- out: select "Post"."id" as ID from "Post"
--- cols: id
--- models: Post Post



=== TEST 47: union
--- sql
(select Blah) union ( select Foo where id >= 3 )
--- out: ( select "Blah" ) union ( select "Foo" where "id" >= 3 )
--- models:
--- cols: Blah Foo id



=== TEST 48: intersect
--- sql
( select Blah ) intersect (select Foo where id >= 3)
--- out: ( select "Blah" ) intersect ( select "Foo" where "id" >= 3 )
--- models:
--- cols: Blah Foo id



=== TEST 49: except
--- sql
(select Blah) except(  select Foo where id >= 3)
--- out: ( select "Blah" ) except ( select "Foo" where "id" >= 3 )
--- models:
--- cols: Blah Foo id



=== TEST 50: big union
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



=== TEST 51: select literals
--- sql: select 0 as id, 'a' as title, 32
--- out: select 0 as id , $y$a$y$ as title , 32



=== TEST 52: regression in 19-view.t
--- sql: select $select_col from A order by $order_by
--- in_vars
select_col=id
order_by=id
--- out: select "id" from "A" order by "id"



=== TEST 53: union all
--- sql: (select 3) union all (select 4)
--- out: ( select 3 ) union all ( select 4 )



=== TEST 54: date_part
--- sql
select id, title, date_part('day', created) as day
from Post
where date_part('year', created) = 2008
--- out: select "id" , "title" , date_part ( $y$day$y$ , "created" ) as day from "Post" where date_part ( $y$year$y$ , "created" ) = 2008



=== TEST 55: bug
--- sql
select count(*)
from $model
--- out: select count ( * ) from ""
--- models:



=== TEST 56: like and other operators
--- sql
select * from Post where id like '%Hello%'
--- out: select * from "Post" where "id" like $y$%Hello%$y$
--- models: Post



=== TEST 57: random operators
--- sql
select sum(1) as count, sum(3+ 2 * (3 - 5^7)) from Post
--- out: select sum ( 1 ) as count , sum ( 3 + 2 * ( 3 - 5 ^ 7 ) ) from "Post"



=== TEST 58: % and /
--- sql
select 32 % (3 ^ (7- 5) / 25 )
--- out: select 32 % ( 3 ^ ( 7 - 5 ) / 25 )



=== TEST 59: ||
--- sql
select '32' || '56'
--- out: select $y$32$y$ || $y$56$y$



=== TEST 60: || in proc calls
--- sql
select date_part('year', created) || date_part('mon' || 'th', created) from Post
--- out: select date_part ( $y$year$y$ , "created" ) || date_part ( $y$mon$y$ || $y$th$y$ , "created" ) from "Post"
--- models: Post



=== TEST 61: || with vars
--- sql
select * from Post where title like '%' || $keyword || '%'
--- in_vars
keyword=Perl
--- out: select * from "Post" where "title" like $y$%$y$ || $y$Perl$y$ || $y$%$y$



=== TEST 62: blog archive listing
--- sql
    select (date_part('year', created) || '-'
                || date_part('month', created) || '-01')::date
        as year_month,
        sum(1) as count
    from Post
    group by year_month
    order by year_month desc
    offset $offset | 0
    limit $limit | 12
--- out: select ( date_part ( $y$year$y$ , "created" ) || $y$-$y$ || date_part ( $y$month$y$ , "created" ) || $y$-01$y$ ) :: date as year_month , sum ( 1 ) as count from "Post" group by "year_month" order by "year_month" desc offset 0 limit 12



=== TEST 63: try to_char
--- sql
    select to_char(created, 'YYYY-MM-01') :: date as year_month,
        sum(1) as count
    from Post
    group by year_month
    order by year_month desc
    offset $offset | 0
    limit $limit | 12
--- out: select to_char ( "created" , $y$YYYY-MM-01$y$ ) :: date as year_month , sum ( 1 ) as count from "Post" group by "year_month" order by "year_month" desc offset 0 limit 12



=== TEST 64: carrie's view
--- sql
select * from yisou_comments_fetch_results($parentid,'',$orderby,$offset,$count,$child_offset,$child_count,$dsc)
--- in_vars
offset=0
--- out: select * from yisou_comments_fetch_results ( $y$$y$ , $y$$y$ , $y$$y$ , $y$0$y$ , $y$$y$ , $y$$y$ , $y$$y$ , $y$$y$ )



=== TEST 65: for @@ operator
--- sql
select * from table where field @@ to_tsquery('chinesecfg', $keyword)
--- in_vars
keyword='Hello'
--- out: select * from "table" where "field" @@ to_tsquery ( $y$chinesecfg$y$ , $y$'Hello'$y$ )



=== TEST 66: for distinct 
--- sql
select distinct ca, cb from table where ca > 0
--- out: select distinct "ca" , "cb" from "table" where "ca" > 0

