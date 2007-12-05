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
{"name":"A","label":"A","type":"text"}



=== TEST 4: Add a new column
--- request
POST /=/model/laser/B
{type:"integer",label:"b"}
--- response
{"success":1,"src":"/=/model/laser/B"}


=== TEST 5: Check the newly-added column
--- request
GET /=/model/laser/B
--- response
{"name":"B","label":"b","type":"integer"}



=== TEST 6: Check the whole schema
--- request
GET /=/model/laser
--- response
{
    "columns":
        [
          {"name":"id","label":"ID","type":"serial"},
          {"name":"A","label":"A","type":"text"},
          {"name":"B","label":"b","type":"integer"}
        ],
    "name":"laser",
    "description":"test model"
}

--- LAST


=== TEST 7: Add one column twice
--- request
POST /=/model/laser/b
{type:"integer",label:"b"}
--- response
{"success":0,"error":"column \"b\" of relation \"laser\" already exists"}



=== TEST 8: Rename the column
--- request
PUT /=/model/laser/b
{"name":"C"}
--- response
{"success":1}

=== TEST 9: Check the new column
--- request
GET /=/model/laser/C
--- response




=== TEST 9: Check the renamed column



=== TEST 10: Update the column type



=== TEST 11: Check the column with a new type



=== TEST 12: Update the column label



=== TEST 13: Check the column with a new label



=== TEST 14: Remove the column



=== TEST 15: Access the nonexistent column

