# vi:filetype=
# ÐÞ¸Änot_null=falseÊôÐÔÎªtrue
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
{ "description": "test model","columns": [{ "name":"A","type":"text","label":"A" }]}
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
{"name":"C","default":null,"label":"c","type":"integer","not_null":false}



=== TEST 5: Insert a record
--- request
POST /=/model/account/~/~
{ "A": "jingjing2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"}



=== TEST 6: alter C 
--- request
PUT /=/model/account/C
{"type":"integer","label":"c","not_null":true}
--- response
{"success":1,"src":"/=/model/account/C"}



=== TEST 7: Check the  column C
--- request
GET /=/model/account/C
--- response
{"name":"C","default":null,"label":"c","type":"integer","not_null":true}



=== TEST 8: Insert a record with value of C is not null
--- request
POST /=/model/account/~/~
{ "A": "jingjing4","C":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/4"}



=== TEST 9: Insert a record with value of C is not null
--- request
POST /=/model/account/~/~
{ "A": "jingjing4"}
--- response
{"success":0,"error":"Not null constraint violated"} 



