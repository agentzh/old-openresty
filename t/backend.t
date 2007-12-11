use strict;
use warnings;

use lib 'lib';
use Test::More tests => 3;
use OpenAPI;

OpenAPI->connect('Pg');
ok $OpenAPI::Backend, "database handle okay";
eval {
    OpenAPI->drop_user("agentzh");
};

my $res = OpenAPI->add_user("agentzh");
ok $res, "user added okay";

$res = OpenAPI->has_user("agentzh");
ok $res, "user has registered!";

