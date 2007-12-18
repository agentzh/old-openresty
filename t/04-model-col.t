use t::OpenAPI;

=pod

This test file tests URLs in the form /=/model/xxx/xxx

TODO
* Delete 'id' column
* Post an existing column
* Post an id column
* Post a column w/o label
* Bad column type in posting a new column

=cut

plan tests => 3 * blocks();

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
          {"name":"A","default":null,"label":"A","type":"text"},
          {"name":"B","default":null,"label":"b","type":"integer"}
        ],
    "name":"laser",
    "description":"test model"
}



=== TEST 7: Add one column twice
--- request
POST /=/model/laser/B
{type:"integer",label:"b"}
--- response
{"success":0,"error":"Column 'B' already exists in model 'laser'."}



=== TEST 8: Add one column twice
--- request
POST /=/model/laser/b
{type:"integer",label:"b"}
--- response
{"success":0,"error":"Column 'b' already exists in model 'laser'."}



=== TEST 9: Rename the column
--- request
PUT /=/model/laser/B
{"name":"C"}
--- response
{"success":1}



=== TEST 10: Check the schema again
--- request
GET /=/model/laser
--- response
{
    "columns":
      [
        {"name":"id","label":"ID","type":"serial"},
        {"name":"A","default":null,"label":"A","type":"text"},
        {"name":"C","default":null,"label":"b","type":"integer"}
      ],
      "name":"laser",
      "description":"test model"
}



=== TEST 11: Check the new column
--- request
GET /=/model/laser/C
--- response
{"name":"C","label":"b","type":"integer"}



=== TEST 12: Check the removed column 'B'
--- request
GET /=/model/laser/B
--- response
{"success":0,"error":"Column 'B' not found."}



=== TEST 13: Try to rename a nonexistent column
--- request
PUT /=/model/laser/B
{"name":"C"}
--- response
{"success":0,"error":"Column 'B' not found."}



=== TEST 14: Try updating type
--- request
PUT /=/model/laser/C
{type:"real"}
--- response
{"success":0,"error":"Changing column type is not supported."}



=== TEST 15: Check the column with a new type
--- request
GET /=/model/laser/C
--- response
{"name":"C","label":"b","type":"integer"}



=== TEST 16: Update the column label
--- request
PUT /=/model/laser/C
{"label":"c"}
--- response
{"success":1}



=== TEST 17: Check the column with a new label
--- request
GET /=/model/laser/C
--- response
{"name":"C","label":"c","type":"integer"}



=== TEST 18: Check the schema again
--- request
GET /=/model/laser
--- response
{
    "columns":
      [
        {"name":"id","label":"ID","type":"serial"},
        {"name":"A","default":null,"label":"A","type":"text"},
        {"name":"C","default":null,"label":"c","type":"integer"}
      ],
      "name":"laser",
      "description":"test model"
}



=== TEST 19: Insert a record
--- request
POST /=/model/laser/~/~
{ C: 3.14159 }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/laser/id/1"}
--- SKIP



=== TEST 20: Check the newly-added record
--- request
GET /=/model/laser/id/1
--- response
[{"c":"3.14159","a":null,"id":"1"}]
--- SKIP



=== TEST 21: Remove the column
--- request
DELETE /=/model/laser/C
--- response
{"success":1}



=== TEST 22: Check the schema again
--- request
GET /=/model/laser
--- response
{
    "columns":
      [
        {"name":"id","label":"ID","type":"serial"},
        {"name":"A","default":null,"label":"A","type":"text"}
      ],
      "name":"laser",
      "description":"test model"
}



=== TEST 23: Remove the column
--- request
DELETE /=/model/laser/C
--- response
{"success":0,"error":"Column 'C' not found."}



=== TEST 24: Access the nonexistent column
--- request
GET /=/model/laser/C
--- response
{"success":0,"error":"Column 'C' not found."}



=== TEST 25 : delete the nonexistent column
--- request
DELETE /=/model/laser/C
--- response
{"success":0,"error":"Column 'C' not found."}

