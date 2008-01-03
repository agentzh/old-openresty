# vi:filetype=

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
DELETE /=/model?user=peee&password=4423037
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
{"name":"A","default":null,"label":"A","type":"text"}



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
{"name":"B","default":null,"label":"b","type":"integer"}



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
POST /=/model/laser/B
{type:"integer",labeh:"b"}
--- response
{"success":0,"error":"Column 'B' already exists in model 'laser'."}



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
{"name":"C","default":null,"label":"b","type":"integer"}



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
{"success":1}



=== TEST 15: Check the column with a new type
--- request
GET /=/model/laser/C
--- response
{"name":"C","default":null,"label":"b","type":"real"}



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
{"name":"C","default":null,"label":"c","type":"real"}



=== TEST 18: Check the schema again
--- request
GET /=/model/laser
--- response
{
    "columns":
      [
        {"name":"id","label":"ID","type":"serial"},
        {"name":"A","default":null,"label":"A","type":"text"},
        {"name":"C","default":null,"label":"c","type":"real"}
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



=== TEST 20: Check the newly-added record
--- request
GET /=/model/laser/id/1
--- response
[{"A":null,"C":"3.14159","id":"1"}]



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



=== TEST 26 : Get all the columns
--- request
GET /=/model/laser/~
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"A","default":null,"label":"A","type":"text"}
]



=== TEST 27 : Get a column (invalid char)
--- request
GET /=/model/laser/@
--- response
{"success":0,"error":"Bad column name: \"@\""}



=== TEST 28 : Add a new column with '~'
--- request
POST /=/model/laser/~
{"name":"M","type":"real","label":"M"}
--- response
{"success":1,"src":"/=/model/laser/M"}



=== TEST 29 : Add a new column with invalid char '@'
--- request
POST /=/model/laser/@
{"name":"M","type":"real","label":"M"}
--- response
{"success":0,"error":"Bad column name: \"@\""}



=== TEST 30 : Add a new column
--- request
POST /=/model/laser/N
{"name":"M","type":"text","label":"N"}
--- response
{"success":1,"src":"/=/model/laser/N","warning":"Column name \"M\" Ignored."}



=== TEST 31 : Get a column with other invalid symbol
--- request
GET /=/model/laser/!
--- response
{"success":0,"error":"Bad column name: \"!\""}



=== TEST 32 : Add a new column with other invalid symbol
--- request
POST /=/model/laser/!
{"name":"D","type":"text","label":"D"}
--- response
{"success":0,"error":"Bad column name: \"!\""}



=== TEST 33 : Remove all the columns with other invalid symbol
--- request
DELETE /=/model/laser/!
--- response
{"success":0,"error":"Bad column name: \"!\""}



=== TEST 34 : Remove the reserved column "id"
--- request
DELETE /=/model/laser/id
--- response
{"success":0,"error":"Column \"id\" is reserved."}



=== TEST 35 : Remove all the columns
--- request
DELETE /=/model/laser/~
--- response
{"success":1,"warning":"Column \"id\" is reserved."}



=== TEST 36: Get columns
--- request
GET /=/model/laser/~
--- response
[{"name":"id","label":"ID","type":"serial"}]



=== TEST 37: Re-add an old column
--- request
POST /=/model/laser/~
{"name":"M","type":"real","label":"M"}
--- response
{"success":1,"src":"/=/model/laser/M"}



=== TEST 38: Insert a record
--- request
GET /=/post/model/laser/~/~?data={M:3.14}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/laser/id/2"}



=== TEST 39: query via id
--- request
GET /=/model/laser/id/2
--- response
[{"M":"3.14","id":"2"}]



=== TEST 40: Put a model column with empty hash
--- request
PUT /=/model/laser/M
{}
--- response
{"success":0,"error":"column spec must be a non-empty HASH."}

