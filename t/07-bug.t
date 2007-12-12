use t::OpenAPI 'no_plan';

=pod

TODO

* Test model descriptions with ':' in them
* Test model column descriptions with ':' in them
* Test special chars in column values, ie. ", ', @, \, (, ), and --.

=cut

run_tests;

__DATA__

=== TEST 1: UTF-8
--- charset: UTF-8
--- request
DELETE /=/model
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

