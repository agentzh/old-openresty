use strict;
use warnings;

use lib 'lib';
use Test::More tests => 8;
use OpenAPI;

OpenAPI->connect('PgFarm');
ok $OpenAPI::Backend, "database handle okay";
eval {
	OpenAPI->set_user("agentzh");
	OpenAPI->do("drop table test cascade");
    OpenAPI->drop_user("agentzh");
};

my $res = OpenAPI->add_user("agentzh");
ok $res, "user added okay";

$res = OpenAPI->has_user("agentzh");
ok $res, "user has registered!";

$res = OpenAPI->set_user("agentzh");
ok $res, "user switched";

$res=OpenAPI->do("create table test(id serial,body text)");
ok $res, "table created";

$res = OpenAPI->do("insert into test (body) values ('hello world')");
ok $res, "insert a record";

$res = OpenAPI->last_insert_id("test");
ok $res, "get last insert id";

$res = OpenAPI->do("drop table test cascade");
ok $res, "table dropped";

