use strict;
use warnings;

use lib 'lib';
use Test::More 'no_plan';
use OpenAPI;
use Data::Dumper;
use subs 'dump';

OpenAPI->connect('PgFarm');
ok $OpenAPI::Backend, "database handle okay";
eval {
#    OpenAPI->do("drop table test cascade");
    OpenAPI->drop_user("yuting");
};

my $res = OpenAPI->add_user("yuting");
cmp_ok $res, '>', -1, "user added okay";

OpenAPI->set_user("yuting");

$res = OpenAPI->has_user("yuting");
ok $res, "user has registered!";

$res = OpenAPI->set_user("yuting");
#ok $res, "user switched";

$res = OpenAPI->do("create table test (id serial, body text)");
#ok $res, "table created";
cmp_ok $res, '>', -1;

$res = OpenAPI->do("insert into test (body) values ('hello world')");
#ok $res, "insert a record";
is $res, '1', 'rows affected';

$res = OpenAPI->last_insert_id("test");
ok $res, "get last insert id";
is $res, 1, "last id okay";

$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 0;
$res = OpenAPI->select('select * from test');
is dump($res), "[['1','hello world']];";

$res = OpenAPI->select('select * from test', { use_hash => 1 });
is dump($res), "[{'body' => 'hello world','id' => '1'}];";

$res = OpenAPI->do("insert into test (body) values ('hello world');\ninsert into test (body) values ('blah');");
ok $res, "insert 2 records";
is $res, '1', 'rows affected';

$res = OpenAPI->do("update test set body=body||'aaa';");
ok $res, "insert 2 records";
is $res, '3', 'rows affected';

$res = OpenAPI->select('select * from test');
is dump($res), "[['1','hello worldaaa'],['2','hello worldaaa'],['3','blahaaa']];";

$res = OpenAPI->select('select * from test', {use_hash => 1});
is dump($res), "[{'body' => 'hello worldaaa','id' => '1'},{'body' => 'hello worldaaa','id' => '2'},{'body' => 'blahaaa','id' => '3'}];";

$res = OpenAPI->do("insert into test (body) values (null);");
ok $res;

$res = OpenAPI->select('select * from test', {use_hash => 1});
is dump($res), "[{'body' => 'hello worldaaa','id' => '1'},{'body' => 'hello worldaaa','id' => '2'},{'body' => 'blahaaa','id' => '3'},{'body' => undef,'id' => '4'}];";

$res = OpenAPI->do("drop table test cascade");
is $res+0, '0', "table dropped";

sub dump {
    my $var = shift;
    my $s = Dumper($var);
    $s =~ s/^\$VAR1\s*=\s*//;
    $s
}

