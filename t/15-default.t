use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 2: default in create model
--- request
POST /=/model/Foo
{
  description:"Foo",
  columns: [
    {name:"title", label: "title", default:"No title"},
    {name:"content", label: "content", default:"No content" }
  ]
}
--- response
{"success":1}



=== TEST 3: Check the model def
--- request
GET /=/model/Foo
--- response
{
  "columns":
    [
      {"name":"id","label":"ID","type":"serial"},
      {"name":"title","default":"No title","label":"title","type":"text"},
      {"name":"content","default":"No content","label":"content","type":"text"}
    ],
    "name":"Foo",
    "description":"Foo"
}



=== TEST 4: Insert a row (wrong way)
--- request
POST /=/model/Foo/~/~
{}
--- response
{"success":0,"error":"No column specified in row 1."}



=== TEST 5: Insert a row
--- request
POST /=/model/Foo/~/~
{ title: "Howdy!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/1"}



=== TEST 6: Check that it has the default value
--- request
GET /=/model/Foo/id/1
--- response
[{"content":"No content","title":"Howdy!","id":"1"}]



=== TEST 7: Add a column with default now()
--- request
POST /=/model/Foo/~
{ name: "created", label: "创建日期", type: "timestamp", default: ["now"] }
--- response
{"success":1,"src":"/=/model/Foo/created"}



=== TEST 8: Insert a row w/o setting "created"
--- request
POST /=/model/Foo/~/~
{ title: "Hi!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/2"}



=== TEST 9: Check the newly added row
--- request
GET /=/model/Foo/id/2
--- response_like
\[\{"created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","content":"No content","title":"Hi!","id":"2"\}\]



=== TEST 10: Insert another row
--- request
POST /=/model/Foo/~/~
{ title: "Bah!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/3"}



=== TEST 11: Check the newly added row
--- request
GET /=/model/Foo/id/3
--- response_like
\[\{"created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","content":"No content","title":"Bah!","id":"3"\}\]


