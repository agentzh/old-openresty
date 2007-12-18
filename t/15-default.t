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

