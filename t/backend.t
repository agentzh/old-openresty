use strict;
use warnings;
use lib 'lib';
use Test::More tests => 3;
use OpenAPI;

OpenAPI->connect();
ok $OpenAPI::Backend, "database handle okay";
eval {
    OpenAPI->drop_user("agentzh");
};
OpenAPI->add_user("agentzh");
my $res = OpenAPI->do("drop table agentzh._models;");
ok $res, 'drop _models okay';
OpenAPI->drop_user("agentzh");
ok 1, 'done and done';

