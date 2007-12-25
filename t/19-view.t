# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 2: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 3: Check the view list
--- request
GET /=/view
--- response
[]



=== TEST 4: Check the view list
--- request
GET /=/view/~
--- response
[]



=== TEST 5: Another way
--- request
DELETE /=/view/~
--- response
{"success":1}



=== TEST 6: Create a view referencing non-existent models
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"A\" not found."}



=== TEST 7: Create model A
--- request
POST /=/model/A
{ description: "A",
  columns: { name: "title", label: "title" }
  }
--- response
{"success":1}



=== TEST 8: Create a view referencing non-existent model B
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"B\" not found."}



=== TEST 9: Create model B
--- request
POST /=/model/B
{ description: "B",
  columns: [
    {name:"body",label:"body"},
    {name:"a",type:"integer",label:"a"}
  ]
}
--- response
{"success":1}



=== TEST 10: Create the view when the models are ready
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1}



=== TEST 11: Check the view list
--- request
GET /=/view
--- response
[
    {
      "name":"View",
      "body":"select * from A, B where A.id = B.a order by A.title"
    }
]



=== TEST 12: Check the View view
--- request
GET /=/view/View
--- response
{
    "name":"View",
    "body":"select * from A, B where A.id = B.a order by A.title"
}



=== TEST 13: Check a non-existent model
--- request
GET /=/view/Dummy
--- response
{"success":0,"error":"View \"Dummy\" not found."}



=== TEST 14: Invoke the view
--- request
GET /=/view/Dummy/~/~
--- response
{"success":0,"error":"View \"Dummy\" not found."}



=== TEST 15: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 16: Insert some data into model A
--- request
POST /=/model/A/~/~
[
  {title:"Yahoo"},{title:"Google"},{title:"Baidu"},
  {title:"Sina"},{title:"Sohu"} ]
--- response
{"success":1,"row_affected":5,"last_row":"/=/model/A/id/5"}



=== TEST 17: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 18: Insert some data into model B
--- request
POST /=/model/B/~/~
[{body:"baidu.com",a:3},{body:"google.com",a:2},
 {body:"sohu.com",a:5},{body:"163.com",a:6},
 {body:"yahoo.cn",a:1}]
--- response
{"success":1,"row_affected":5,"last_row":"/=/model/B/id/5"}



=== TEST 19: Invoke the view again
--- request
GET /=/view/View/~/~
--- response
[XXX]

--- response

