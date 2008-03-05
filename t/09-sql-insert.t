use lib 'lib';
use strict;
use warnings;

use Test::More tests => 4;
BEGIN { use_ok('OpenResty::SQL::Insert'); }

my $insert = OpenResty::SQL::Insert->new;
$insert->insert( 'models' )
       ->values( 'abc' => '"howdy"' );

is $insert->generate, <<_EOC_;
insert into models values (abc, "howdy");
_EOC_

is "$insert", <<_EOC_;
insert into models values (abc, "howdy");
_EOC_

$insert->cols('foo', 'bar');

is $insert->generate, <<_EOC_;
insert into models (foo, bar) values (abc, "howdy");
_EOC_

