use t::OpenAPI 'no_plan';

=pod

This test file tests URLs in the forms /=/model and /=/model/xxx

XXX [TODO]

* Invalid column type in the model schema
* Invalid column label in the model schema
* Unrecoginzed keys in model's { ... }
* Unrecoginzied keys in model column's { ... }
* Too many columns
* Chinese characters in model names which also mach /\w/

=cut

#plan tests => 2 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: Create a new model
--- request
POST /=/model/Human
{ description:"人类",
  columns:
    [ { name: "gender", label: "性别" } ]
}
--- response
{"success":1}



=== TEST 3: Create a model with the same name
--- request
POST /=/model/Human
{ description:"人类",
  columns:
    [ { name: "gender", label: "性别" } ]
}
--- response
{"success":0,"error":"Model \"Human\" already exists."}



=== TEST 4: Create a model with 'name' specified
--- request
POST /=/model/Foo
{
  name: "Blah",
  description:"人类",
  columns:
    [ { name: "gender", label: "性别" } ]
}
--- response
{"success":1,"warning":"name \"Blah\" in POST content ignored."}



=== TEST 5: No description specified
--- request
POST /=/model/Blah
{
  columns:
    [ { name: "gender", label: "性别" } ]
}
--- response
{"success":0,"error":"No 'description' specified for model \"Blah\"."}



=== TEST 6: No label specified for column
--- request
POST /=/model/Blah
{
  description:"人类",
  columns:
    [ { name: "gender" } ]
}
--- response
{"success":0,"error":"No 'label' specified for column \"gender\" in model \"Blah\"."}



=== TEST 7: No column specified for the model
--- request
POST /=/model/Blah
{
  description:"Blah",
  columns:
    []
}
--- response
{"success":1,"warning":"'columns' empty for model \"Blah\"."}



=== TEST 8: Check the model (we have the preserved 'id' column :)
--- request
GET /=/model/Blah
--- response
{
  "columns":
     [{"name":"id","label":"ID","type":"serial"}],
  "name":"Blah",
  "description":"Blah"
}



=== TEST 9: Syntax error in JSON data
--- request
POST /=/model/Baz
{
  description:"BAZ",
}
--- response
{"success":0,"error":"Syntax error found in the JSON input: line 3, column 1."}



=== TEST 10: columns slot is not specified
--- request
POST /=/model/Baz
{
  description:"BAZ"
}
--- response
{"success":1,"warning":"No 'columns' specified for model \"Baz\"."}



=== TEST 11: Check the model (we still have the preserved 'id' column :)
--- request
GET /=/model/Baz
--- response
{
  "columns":
     [{"name":"id","label":"ID","type":"serial"}],
  "name":"Baz",
  "description":"BAZ"
}



=== TEST 12: Check the model list again
--- request
GET /=/model
--- response
[
    {"src":"/=/model/Human","name":"Human","description":"人类"},
    {"src":"/=/model/Foo","name":"Foo","description":"人类"},
    {"src":"/=/model/Blah","name":"Blah","description":"Blah"},
    {"src":"/=/model/Baz","name":"Baz","description":"BAZ"}
]



=== TEST 13: Delete a model with a bad name



=== TEST 14: Delete a non-existent model



=== TEST 15: Delete a specified model



=== TEST 16: Delete all the models



=== TEST 17: Check the model list again (should be empty now)



=== TEST 18: Post model as a list
--- request
POST /=/model/Tiger
[{ description: "Tiger" }]
--- response
{"success":0,"error":"The model schema must be a HASH."}



=== TEST 19: Create a model w/o POST content
--- request
POST /=/model/laser
--- response
{"success":0,"error":"The model schema must be a HASH."}



=== TEST 20: invalid columns in the model schema
--- request
POST /=/model/Tiger
{ description: "Tiger", columns: 32 }
--- response
{"success":0,"error":"Invalid 'columns' value: 32"}



=== TEST 21: invalid 'description' slot value in the schema
--- request
POST /=/model/Tiger
{ description: ["hello"] }
--- response
{"success":0,"error":"Bad 'description' value: [\"hello\"]"}



=== TEST 22: invalid model column name in schema
--- request
POST /=/model/Tiger
{ description: "Tiger", columns:
    [ { name:[32], label:"bad col" } ]
}
--- response
{"success":0,"error":"Bad column name: [32]"}



=== TEST 23: model column name too long
--- request
POST /=/model/Tiger
{ description: "Tiger", columns:
    [ { name:"dddddddddddddddddddddddddddddddd", label:"hiya" } ]
}
--- response
{"success":0,"error":"Column name too long: dddddddddddddddddddddddddddddddd"}



=== TEST 24: model column name JUST NOT too long
--- request
POST /=/model/Tiger
{ description: "Tiger", columns:
    [ { name:"ddddddddddddddddddddddddddddddd", label:"hiya" } ]
}
--- response
{"success":1}



=== TEST 25: model name too long
--- request
POST /=/model/ABCDEFGHIJKLMNOPQRSTUVWXYZ123456
{ description: "Bad model" }
--- response
{"success":0,"error":"Model name too long: ABCDEFGHIJKLMNOPQRSTUVWXYZ123456"}



=== TEST 26: model name JUST NOT too long
--- request
POST /=/model/ABCDEFGHIJKLMNOPQRSTUVWXYZ12345
{ description: "Bad model" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"ABCDEFGHIJKLMNOPQRSTUVWXYZ12345\"."}



=== TEST 27: Unrecoginzed key in model's block (POST)
--- request
POST /=/model/TTT
{ \xFF\xFE: 'key named \xFF\xFE', description: "bad" }
--- response
{"success":0,"error":"Unrecognized key in model schema 'TTT': \\xFF\\xFE"}



=== TEST 28: Unrecoginzed keys in model's block (POST)
--- request
POST /=/model/TTT
{ \xFF\xFE: 'key named \xFF\xFE', \xFF\xFF: 'key named \xFF\xFF', description: "bad" }
--- response
{"success":0,"error":"Unrecognized keys in model schema 'TTT': \\xFF\\xFE, \\xFF\\xFF"}
