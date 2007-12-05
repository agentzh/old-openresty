use t::OpenAPI 'no_plan';

=pod

This test file tests URLs in the form /=/model/xxx/xxx

TODO
* Post an existing column
* Post an id column
* Post a column w/o label
* Bad column type in posting a new column

=cut

#plan tests => 2 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: create a model
--- request
POST /=/model/laser
{ description: "test model", columns: [{ name:"A",label:"A" }] }
--- response
{"success":1}



=== TEST 3: Check one column
--- request
GET /=/model/laser/A
--- response
{"name":"a","label":"A","type":"text"}


=== TEST 4: Add a new column
--- request
POST /=/model/laser/B
{type:"integer",label:"b"}
--- response
{"success":1,"src":"/=/model/laser/b"}



=== TEST 5: Check the newly-added column



=== TEST 6: Rename the column



=== TEST 7: Check the renamed column



=== TEST 8: Update the column type



=== TEST 9: Check the column with a new type



=== TEST 10: Update the column label



=== TEST 11: Check the column with a new label



=== TEST 12: Remove the column



=== TEST 13: Access the nonexistent column

