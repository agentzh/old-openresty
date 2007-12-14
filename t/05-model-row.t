use t::OpenAPI;

=pod

This test file tests URLs in the form /=/model/xxx/xxx/xxx

TODO
* many...

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: insert data to an nonexistant model
--- request
POST /=/model/Dummy/~/~
{ name: 'foo' }
--- response
{"success":0,"error":"Model \"Dummy\" not found."}

