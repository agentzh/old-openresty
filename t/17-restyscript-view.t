# vi:filetype=

# Tests for the OpenResty::RestyScript module. (View part)

my $skip;
my $ExePath;
BEGIN {
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found.\n";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable.\n";
        return;
    }
};
use Test::Base $skip ? (skip_all => $skip) : ();

#use Smart::Comments;
use lib 'lib';
use OpenResty::RestyScript;

#plan tests => 3 * blocks();

plan tests => 117;

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
        my @m;
        for my $model (@models) {
            if ($model =~ s/^\$//) {
                if (defined $in_vars{$model}) {
                    push @m, $in_vars{$model};
                } else {
                    push @m, '$'.$model;
                }
            } else {
                push @m, $model;
            }
        }
        @models = @m;
    }
    ### @models
    my $ex_models = $block->models;
    if (defined $ex_models) {
        is join(' ', @models), $block->models, "$name - model list ok";
    }

    my @bits;
    for my $frag (@$frags) {
        if (ref $frag) {  # being a variable
            my ($var, $type) = @$frag;
            my $quote = $type eq 'symbol' ? \&quote_ident : \&quote;
            push @vars, $var;
            if (!defined $in_vars{$var}) {
                push @unbound, $var;
                push @bits, $quote->('');
            } else {
                push @bits, $quote->($in_vars{$var});
            }
        } else {
            push @bits, $frag;
        }
    }

    my $pgsql = @bits ? (join '', @bits) : '';
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
"view" (line 1, column 22):
unexpected "b"



=== TEST 5: Unexpected end of input
--- sql
select *
from Carrie
where
--- error
"view" (line 4, column 1):
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
"view" (line 4, column 1):
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
"view" (line 3, column 18):
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
"view" (line 3, column 23):
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
"view" (line 3, column 36):
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



=== TEST 29: Test the literal
--- sql
select * from foo where bar = $hello$hi$h$$hello$ and a>3
--- error
--- unbound:
--- out: select * from "foo" where ("bar" = 'hi$h$' and "a" > 3)



=== TEST 30: variable interpolation
--- sql
select * from $model where $col = 'hello'
--- models: $model
--- vars: model col
--- unbound: model col
--- out: select * from "" where $y$$y$ = 'hello'



=== TEST 31: variable interpolation
--- sql
select * from $model where $col = 'hello'
--- in_vars
model=blah
col=foo
--- models: blah
--- vars: model col
--- unbound:
--- out: select * from "blah" where $y$foo$y$ = 'hello'



=== TEST 32: variable interpolation
--- sql
select * from $model where col = $value order by $col
--- in_vars
model=blah
col=baz
value='howdy'
--- models: blah
--- vars: model value col
--- unbound:
--- out: select * from "blah" where "col" = $y$'howdy'$y$ order by "baz" asc



=== TEST 33: unbound vars in literals
--- sql
select * from $model_1, $model_2 where $col = $value and $blah = $val2
--- in_vars
model_1=Cat
--- models: Cat $model_2
--- unbound: model_2 col value blah val2
--- out: select * from "Cat", "" where ($y$$y$ = $y$$y$ and $y$$y$ = $y$$y$) 



=== TEST 34: nude keywords
--- sql
select * from from where select='abc'
--- out
select * from "from" where "select" = 'abc'



=== TEST 35: keywords with "
--- sql
select * from "from" where "select"='abc'
--- error
--- models: from
--- out: select * from "from" where "select" = 'abc'



=== TEST 36: order by with asc
--- sql
select * from blah order by id asc
--- error
--- out: select * from "blah" order by "id" asc



=== TEST 37: order by with asc/desc
--- sql
select * from blah order by id desc, name asc
--- error
--- out: select * from "blah" order by "id" desc, "name" asc



=== TEST 38: | default is now invalid
--- sql
select * from blah offset $offset | 0 limit $limit | 32
--- in_vars
--- error
"view" (line 1, column 35):
unexpected "|"



=== TEST 39: offset & limit
--- sql
select * from blah offset $offset limit $limit
--- in_vars
offset=2
limit=3
--- out
select * from "blah" offset $y$2$y$ limit $y$3$y$



=== TEST 40: column alias
--- sql
select Post.id as ID from Post
--- out: select "Post"."id" as "ID" from "Post"
--- models: Post



=== TEST 41: union
--- sql
(select Blah) union ( select Foo where id >= 3 )
--- out: ((select "Blah") union (select "Foo" where "id" >= 3))
--- models:



=== TEST 42: intersect
--- sql
( select Blah ) intersect (select Foo where id >= 3)
--- out: ((select "Blah") intersect (select "Foo" where "id" >= 3))
--- models:



=== TEST 43: except
--- sql
(select Blah) except(  select Foo where id >= 3)
--- out: ((select "Blah") except (select "Foo" where "id" >= 3))
--- models:



=== TEST 44: big union
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
--- out: ((select "id", "title" from "Post" where "id" > $y$$y$ order by "id" asc limit 1) union (select "id", "title" from "Post" where "id" < $y$$y$ order by "id" desc limit 1))



=== TEST 45: select literals
--- sql: select 0 as id, 'a' as title, 32
--- out: select 0 as "id", 'a' as "title", 32



=== TEST 46: regression in 19-view.t
--- sql: select $select_col from A order by $order_by
--- in_vars
select_col=id
order_by=id
--- out: select $y$id$y$ from "A" order by "id" asc



=== TEST 47: union all
--- sql: (select 3) union all (select 4)
--- out: ((select 3) union all (select 4))



=== TEST 48: date_part
--- sql
select id, title, date_part('day', created) as day
from Post
where date_part('year', created) = 2008
--- out: select "id", "title", "date_part"('day', "created") as "day" from "Post" where "date_part"('year', "created") = 2008



=== TEST 49: bug
--- sql
select count(*)
from $model
--- out: select "count"(*) from ""
--- models: $model



=== TEST 50: like and other operators
--- sql
select * from Post where id like '%Hello%'
--- out: select * from "Post" where "id" like '%Hello%'
--- models: Post



=== TEST 51: random operators
--- sql
select sum(1) as count, sum(3+ 2 * (3 - 5^7)) from Post
--- out: select "sum"(1) as "count", "sum"((3 + (2 * (3 - (5 ^ 7))))) from "Post"



=== TEST 52: % and /
--- sql
select 32 % (3 ^ (7- 5) / 25 )
--- out: select (32 % ((3 ^ (7 - 5)) / 25))



=== TEST 53: ||
--- sql
select '32' || '56'
--- out: select ('32' || '56')



=== TEST 54: || in proc calls
--- sql
select date_part('year', created) || date_part('mon' || 'th', created) from Post
--- out: select ("date_part"('year', "created") || "date_part"(('mon' || 'th'), "created")) from "Post"
--- models: Post



=== TEST 55: || with vars
--- sql
select * from Post where title like '%' || $keyword || '%'
--- in_vars
keyword=Perl
--- out: select * from "Post" where "title" like (('%' || $y$Perl$y$) || '%')



=== TEST 56: blog archive listing
--- sql
    select (date_part('year', created) || '-'
                || date_part('month', created) || '-01')::date
        as year_month,
        sum(1) as count
    from Post
    group by year_month
    order by year_month desc
    offset $offset
    limit $limit
--- in_vars
offset=0
limit=12
--- out: select ((("date_part"('year', "created") || '-') || "date_part"('month', "created")) || '-01')::"date" as "year_month", "sum"(1) as "count" from "Post" group by "year_month" order by "year_month" desc offset $y$0$y$ limit $y$12$y$



=== TEST 57: try to_char
--- sql
    select to_char(created, 'YYYY-MM-01') :: date as year_month,
        sum(1) as count
    from Post
    group by year_month
    order by year_month desc
    offset $offset
    limit $limit
--- in_vars
offset=0
limit=12
--- out: select "to_char"("created", 'YYYY-MM-01')::"date" as "year_month", "sum"(1) as "count" from "Post" group by "year_month" order by "year_month" desc offset $y$0$y$ limit $y$12$y$



=== TEST 58: carrie's view
--- sql
select * from yisou_comments_fetch_results($parentid,'',$orderby,$offset,$count,$child_offset,$child_count,$dsc)
--- in_vars
offset=0
--- out: select * from "yisou_comments_fetch_results"($y$$y$, '', $y$$y$, $y$0$y$, $y$$y$, $y$$y$, $y$$y$, $y$$y$)



=== TEST 59: for @@ operator
--- sql
select * from table where field @@ to_tsquery('chinesecfg', $keyword)
--- in_vars
keyword='Hello'
--- out: select * from "table" where "field" @@ "to_tsquery"('chinesecfg', $y$'Hello'$y$)



=== TEST 60: for distinct
--- sql
select distinct ca, cb from table where ca > 0
--- out: select distinct "ca", "cb" from "table" where "ca" > 0

