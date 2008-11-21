# vi:filetype=
#添加不带not_null属性的列
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



=== TEST 3: Add a new column
--- request
POST /=/model/account/B
{"type":"integer","label":"b"}
--- response
{"success":1,"src":"/=/model/account/B"}



=== TEST 4: Check the new column
--- request
GET /=/model/account/B
--- response
{"name":"B","default":null,"label":"b","type":"integer","not_null":false,"unique":false}



=== TEST 5: Insert a record
--- request
POST /=/model/account/~/~
{ "A": "jingjing1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"}
