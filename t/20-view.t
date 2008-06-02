# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
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
{ "description": "A",
  "columns": { "name": "title", "label": "title" }
  }
--- response
{"success":1}



=== TEST 5: Create model B
--- request
POST /=/model/B
{ "description": "B",
  "columns": [
    {"name":"body","label":"body"},
    {"name":"a","type":"integer","label":"a"}
  ]
}
--- response
{"success":1}



=== TEST 6: Create the view
--- request
POST /=/view/View
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1}



=== TEST 7: Create the view
--- request
POST /=/view/Test
{ "name": "Name", "definition": "select * from A, B" }
--- response
{"success":1,"warning":"name \"Name\" in POST content ignored."}



=== TEST 8: Update the view
--- request
PUT /=/view/Test
[{ "definition": "select * from A, B where A.id = B.a order by A.title" }]
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
{ "name":"Test1" }
--- response
{"success":1}



=== TEST 11: Update name of the view
--- request
PUT /=/view/Test1
{ "name":"123" }
--- response
{"success":0,"error":"Bad view name: \"123\""}



=== TEST 12: Update name of the view
--- request
PUT /=/view/Test1
{ "name":"!@#$%#@" }
--- response
{"success":0,"error":"Bad view name: \"!@#$%#@\""}



=== TEST 13: Update name of the view
--- request
PUT /=/view/Test1
{ "name":"_Test" }
--- response
{"success":0,"error":"Bad view name: \"_Test\""}



=== TEST 14: Update name of the view
--- request
PUT /=/view/Test1
{ "name":"Test123!@#" }
--- response
{"success":0,"error":"Bad view name: \"Test123!@#\""}



=== TEST 15: Update name of the view
--- request
PUT /=/view/Test1
{ "name":"Test123" }
--- response
{"success":1}



=== TEST 16: Update definition of the view
--- request
PUT /=/view/Test123
{ "definition":123456 }
--- response
{"success":1}



=== TEST 17: Update definition of the view
--- request
PUT /=/view/Test123
{ "definition":["select * from A, B where A.id = B.a order by A.title"] }
--- response
{"success":0,"error":"Bad view definition: [\"select * from A, B where A.id = B.a order by A.title\"]"}



=== TEST 18: Update definition of the view
--- request
PUT /=/view/Test123
{ "definition":"select * from A, B where A.id = B.a order by B.a" }
--- response
{"success":1}



=== TEST 19: Update description of the view
--- request
PUT /=/view/Test123
{ "description":123456 }
--- response
{"success":1}



=== TEST 20: Update description of the view
--- request
PUT /=/view/Test123
{ "description":{"desc":"blahblah"} }
--- response
{"success":0,"error":"Bad view description: {\"desc\":\"blahblah\"}"}



=== TEST 21: Update description of the view
--- request
PUT /=/view/Test123
{ "description":"blahblah" }
--- response
{"success":1}



=== TEST 22: Invoke the Test123 view
--- request
GET /=/view/Test123/~/~
--- response
[]



=== TEST 23: Invoke the Test123 view
--- request
GET /=/view/Test123/description/~
--- response
[]



=== TEST 24: Definition a view for default value test
--- request
POST /=/view/Test2
{ "definition":"select * from A limit $t | 1" }
--- response
{"success":1}



=== TEST 25: Insert data for testing 
--- request
POST /=/model/A/~/~
[
	{ "title": "test1" },
	{ "title": "test2" },
	{ "title": "test3" },
	{ "title": "test4" },
	{ "title": "test5" },
	{ "title": "test6" }
]
--- response
{"last_row":"/=/model/A/id/6","rows_affected":6,"success":1}



=== TEST 26: Default value test
--- request
GET /=/view/Test2/~/~?t=
--- response
[{"id":"1","title":"test1"}]

