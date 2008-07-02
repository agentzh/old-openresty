# vi:filetype=

use lib 'lib';
#use Smart::Comments '###';
use Test::Base 'no_plan';

use OpenResty::RestyScript::ViewUpgrade;

run {
    my $block = shift;
    my $name = $block->name;
    my $upgrade = OpenResty::RestyScript::ViewUpgrade->new;
    my $old = $block->old;
    if (!$old) { die "No --- old specified.\n" }
    my $res = $upgrade->parse($old);
    ### $res
    is $res->{newdef}, $block->newdef, "$name - newdef ok";
    my $vars = $res->{vars};
    my $s;
    for my $var (@$vars) {
        $s .=  join(' ', @$var) . "\n";
    }
    is $s, $block->params, "$name - params okay";
};

__DATA__

=== TEST 1: hello world
--- old
select * from $foo where $bar | 3> $blah|'hi'
--- newdef
select *
from $foo
where $bar > $blah
--- params
$foo symbol
$bar literal 3
$blah literal hi



=== TEST 2: lhs?
--- old
select * from $foo where $bar> $blah
--- newdef
select *
from $foo
where $bar > $blah
--- params
$foo symbol
$bar symbol
$blah literal




