use strict;
use warnings;
use Test::More tests => 3;
use OpenAPI;

OpenAPI->connect();
ok $OpenAPI::dbh, "database handle okay";
OpenAPI->drop_user("agentzh");
OpenAPI->new_user("agentzh");
my $res = OpenAPI->do("drop table agentzh._models;");
ok $res, 'drop _models okay';
OpenAPI->drop_user("agentzh");
ok 1, 'done and done';

