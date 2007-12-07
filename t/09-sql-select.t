use lib 'lib';
use strict;
use warnings;

use Test::More 'no_plan';
BEGIN { use_ok('SQL::Select'); }

sub _Q { "'$_[0]'" }

my $select = SQL::Select->new;
$select->select( qw<name type label> )
       ->from( '_columns' );

is $select->generate, <<_EOC_;
select name,type,label
from _columns;
_EOC_

is "$select", <<_EOC_;
select name,type,label
from _columns;
_EOC_

$select->where("table_name", '=', _Q('blah'));

is $select->generate, <<_EOC_;
select name,type,label
from _columns
where table_name = 'blah';
_EOC_

$select->order_by("foo");

is $select->generate, <<_EOC_;
select name,type,label
from _columns
where table_name = 'blah'
order by foo;
_EOC_

$select->where("Foo", '>', 'bar');
is "$select", <<'_EOC_';
select name,type,label
from _columns
where table_name = 'blah' and Foo > bar
order by foo;
_EOC_

$select = SQL::Select->new( qw<name type label> )
       ->from( '_columns' )->limit(5)->offset(29);
is $select->generate, <<_EOC_;
select name,type,label
from _columns
limit 5
offset 29;
_EOC_

