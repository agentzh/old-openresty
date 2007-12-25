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



=== TEST 3: Another way
--- request
DELETE /=/view/~
--- response
{"success":1}



=== TEST 4: Create a view referencing non-existent models
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"A\" not found."}



=== TEST 5: Create model A
--- request
{ description: "A",
  columns: { name: "title", lable: "title" }
  }
--- response
{"success":1}



=== TEST 6: Create a view referencing non-existent model B
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"B\" not found."}


