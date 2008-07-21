# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: UTF-8
--- charset: UTF-8
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: It hangs or report error
--- request
GET /=/model/Foo/~/~
--- response
{"success":0,"error":"Model \"Foo\" not found."}



=== TEST 3: It hangs or report error
--- request
GET /blah
--- response
{"success":0,"error":"URLs must be led by '='."}
--- SKIP



=== TEST 4: logout
--- request
GET /=/logout
--- response
{"success":1}

