# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing views
--- request
DELETE /=/view?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a view with builtin vars
--- request
POST /=/view/Foo
{ "description": "test builtin vars", "definition":"select $_ACCOUNT as account, $_ROLE as role;" }
--- response
{"success":1}



=== TEST 3: Invoke the view with explicit variable binding
--- request
GET /=/view/Foo/_ACCOUNT/32?_ROLE=56
--- response
[{"account":"tester","role":"Admin"}]



=== TEST 4: Invoke the view w/o binding
--- request
GET /=/view/Foo/~/~
--- response
[{"account":"tester","role":"Admin"}]

