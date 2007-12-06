use t::OpenAPI 'no_plan';

run_tests;

__DATA__

=== TEST 1: UTF-8
--- charset: UTF-8
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 2: It hangs or report error
--- charset: Big5
--- request
GET /=/model/Foo/~/~
--- response

