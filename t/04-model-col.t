# vi:filetype=

use t::OpenResty;

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
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model
--- request
POST /=/model/laser
{ "description": "test model", "columns": [{ "name":"A","type":"text","label":"A" }] }
--- response
{"success":1}



=== TEST 3: Check one column
--- request
GET /=/model/laser/A
--- response
{"name":"A","default":null,"label":"A","type":"text"}



=== TEST 4 : delete the nonexistent column
--- request
DELETE /=/model/laser/C
--- response
{"success":0,"error":"Column 'C' not found."}



=== TEST 5 : Get all the columns
--- request
GET /=/model/laser/~
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"A","default":null,"label":"A","type":"text"}
]



=== TEST 6 : Get a column (invalid char)
--- request
GET /=/model/laser/@
--- response
{"success":0,"error":"Bad column name: \"@\""}



=== TEST 7 : Add a new column with '~'
--- request
POST /=/model/laser/~
{"name":"M","type":"real","label":"M"}
--- response
{"success":1,"src":"/=/model/laser/M"}



=== TEST 8 : Add a new column with invalid char '@'
--- request
POST /=/model/laser/@
{"name":"M","type":"real","label":"M"}
--- response
{"success":0,"error":"Bad column name: \"@\""}



=== TEST 9 : Add a new column
--- request
POST /=/model/laser/N
{"name":"M","type":"text","label":"N"}
--- response
{"success":1,"src":"/=/model/laser/N","warning":"Column name \"M\" Ignored."}



=== TEST 10 : Get a column with other invalid symbol
--- request
GET /=/model/laser/!
--- response
{"success":0,"error":"Bad column name: \"!\""}



=== TEST 11 : Add a new column with other invalid symbol
--- request
POST /=/model/laser/!
{"name":"D","type":"text","label":"D"}
--- response
{"success":0,"error":"Bad column name: \"!\""}



=== TEST 12 : Remove all the columns with other invalid symbol
--- request
DELETE /=/model/laser/!
--- response
{"success":0,"error":"Bad column name: \"!\""}



=== TEST 13 : Remove the reserved column "id"
--- request
DELETE /=/model/laser/id
--- response
{"success":0,"error":"Column \"id\" is reserved."}



=== TEST 14 : Remove all the columns
--- request
DELETE /=/model/laser/~
--- response
{"success":1,"warning":"Column \"id\" is reserved."}



=== TEST 15: Get columns
--- request
GET /=/model/laser/~
--- response
[{"name":"id","label":"ID","type":"serial"}]



=== TEST 16: Re-add an old column
--- request
POST /=/model/laser/~
{"name":"M","type":"real","label":"M"}
--- response
{"success":1,"src":"/=/model/laser/M"}



=== TEST 17: Insert a record
--- request
GET /=/post/model/laser/~/~?_data={"M":3.14}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/laser/id/2"}



=== TEST 18: query via id
--- request
GET /=/model/laser/id/2
--- response
[{"M":"3.14","id":"2"}]



=== TEST 19: Put a model column with empty hash
--- request
PUT /=/model/laser/M
{}
--- response
{"error":"Hash cannot be empty.","success":0}



=== TEST 20: create a column without type
--- request
POST /=/model/laser/title
{"label":"Title"}
--- response
{"error":"Value for \"type\" required.","success":0}



=== TEST 21: logout
--- request
GET /=/logout
--- response
{"success":1}

