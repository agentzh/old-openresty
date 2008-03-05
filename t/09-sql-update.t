use lib 'lib';
use strict;
use warnings;

use Test::More tests => 6;
BEGIN { use_ok('OpenResty::SQL::Update'); }

sub _Q { "'$_[0]'" }

my $update = OpenResty::SQL::Update->new;
$update->update( 'models' )
       ->set( 'abc' => '"howdy"' );

is $update->generate, <<_EOC_;
update models
set abc = "howdy";
_EOC_

is "$update", <<_EOC_;
update models
set abc = "howdy";
_EOC_

$update->where("table_name", '=', _Q('blah'))->set(foo => 'bar');

is $update->generate, <<_EOC_;
update models
set abc = "howdy", foo = bar
where table_name = 'blah';
_EOC_

$update->where("Foo", '>', 'bar');
is "$update", <<'_EOC_';
update models
set abc = "howdy", foo = bar
where table_name = 'blah' and Foo > bar;
_EOC_

$update->reset( qw<abc> )
       ->set( 'foo' => 3 )->where(name => '"John"');
is $update->generate, <<_EOC_;
update abc
set foo = 3
where name = "John";
_EOC_

