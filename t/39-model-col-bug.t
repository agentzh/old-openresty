# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a new model
--- request
POST /=/model/Post
{ "description":"Post" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Post\"."}



=== TEST 3: Add a serial column
--- request
POST /=/model/Post/~
{"name":"id2","type":"serial","label":"id2"}
--- response
{"src":"/=/model/Post/id2","success":1}



=== TEST 4: Add a new column with space in it
--- request
POST /=/model/Post/~
{"name":"q a","type":"text","label":"Q & A"}
--- response
{"success":0,"error":"Bad value for \"name\": Identifier expected."}



=== TEST 5: logout
--- request
GET /=/logout
--- response
{"success":1}

