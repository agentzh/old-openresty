# vi:filetype=
#添加not_null属性为false的列
use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a new model
--- request
POST /=/model/account
{ "description": "test model","columns": [{ "name":"A","type":"text","label":"a" }]}
--- response
{"success":1}



=== TEST 3: Add a new column not null is false
--- request
POST /=/model/account/C
{"type":"integer","label":"c","not_null":false}
--- response
{"success":1,"src":"/=/model/account/C"}



=== TEST 4: Check the new column C
--- request
GET /=/model/account/C
--- response
{"name":"C","default":null,"label":"c","type":"integer","not_null":false,"unique":false}



=== TEST 5: Insert a record
--- request
POST /=/model/account/~/~
{ "A": "jingjing2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"}

