# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=peee&password=4423037&use_cookie=1
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



=== TEST 4: Create model A
--- request
POST /=/model/A
{ description: "A",
  columns: { name: "title", label: "title" }
  }
--- response
{"success":1}



=== TEST 5: Create model B
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



=== TEST 6: Create the view
--- request
POST /=/view/View
{ definition: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1}




=== TEST 7: Create the view
--- request
POST /=/view/Test123
{ name: "Name", definition: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1,"warning":"name \"Name\" in POST content ignored."}



=== TEST 8: Update the view
--- request
PUT /=/view/Test
[{ definition: "select * from A, B where A.id = B.a order by A.title" }]
--- response
{"success":0,"error":"column spec must be a non-empty HASH."}



=== TEST 9: Update the view
--- request
PUT /=/view/Test
"select * from A, B where A.id = B.a order by A.title"
--- response
{"success":0,"error":"column spec must be a non-empty HASH."}



=== TEST 10: Update name of the view
--- request
PUT /=/view/Test
{ name:"Test1" }
--- response
{"success":1}



=== TEST 11: Update name of the view
--- request
PUT /=/view/Test1
{ name:"123" }
--- response
{"success":0,"error":"Bad view name: 123"}



=== TEST 11: Update name of the view
--- request
PUT /=/view/Test1
{ name:"!@#$%#@" }
--- response
{"success":0,"error":"Bad view name: !@#$%#@"}



=== TEST 12: Update name of the view
--- request
PUT /=/view/Test1
{ name:"_Test" }
--- response
{"success":1}



=== TEST 13: Update name of the view
--- request
PUT /=/view/_Test
{ name:"Test123" }
--- response
{"success":1}



=== TEST 14: Update definition of the view
--- request
PUT /=/view/Test123
{ definition:123456 }
--- response
{"success":0,"error":"Bad view definition: 123456"}



=== TEST 15: Update definition of the view
--- request
PUT /=/view/Test123
{ definition:["select * from A, B where A.id = B.a order by A.title"] }
--- response
{"success":0,"error":"Bad view definition: [\"select * from A, B where A.id = B.a order by A.title\"]"}



=== TEST 15: Update definition of the view
--- request
PUT /=/view/Test123
{ definition:"select * from A, B where A.id = B.a order by B.a" }
--- response
{"success":1"}



=== TEST 16: Update description of the view
--- request
PUT /=/view/Test123
{ description:123456 }
--- response
{"success":0,"error":"Bad view description: 123456"}



=== TEST 16: Update description of the view
--- request
PUT /=/view/Test123
{ description:{desc:"blahblah"} }
--- response
{"success":0,"error":"Bad view description: {desc:\"blahblah\"}"}



=== TEST 16: Update description of the view
--- request
PUT /=/view/Test123
{ description:"blahblah" }
--- response
{"success":1}



=== TEST 17: Invoke the Test123 view
--- request
GET /=/view/Test123/~/~
--- response
[]



=== TEST 17: Invoke the Test123 view
--- request
GET /=/view/Test123/description/~
--- response
[]



