# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__




=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
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
  "columns": [{ "name": "title", "type":"text", "label": "title" }]
  }
--- response
{"success":1}



=== TEST 5: Create model B
--- request
POST /=/model/B
{ "description": "B",
  "columns": [
    {"name":"body","type":"text", "label":"body"},
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




=== TEST 7: Create the view with duplicate name
--- request
POST /=/view/View
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"View \"View\" already exists."}




=== TEST 8: Create the view with duplicate definition
--- request
POST /=/view/View1
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1}



=== TEST 9: logout
--- request
GET /=/logout
--- response
{"success":1}

