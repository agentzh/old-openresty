# vi:filetype=
# 某列的not_null属性不会影响到其他没有not_null属性的列
#同时创建两列，一列有，一列没有 
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
{ "description": "test model","columns": [{ "name":"A","type":"text","label":"A" },{ "name":"B","type":"text","label":"b","not_null":true }]}
--- response
{"success":1}



=== TEST 3: Check the new model
--- request
GET /=/model/account
--- response
{"name":"D","default":null,"label":"b","type":"integer","not_null":true}



=== TEST 4: Insert a record with value of A is null
--- request
POST /=/model/account/~/~
{"B":"b1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"} 



=== TEST 5: Insert a record with value of A is not null
--- request
POST /=/model/account/~/~
{ "A": "a1","B":"b2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/2"}



=== TEST 6: Insert a record with value of B is null
--- request
POST /=/model/account/~/~
{ "A": "a2"}
--- response
{"success":0,"error":"Not null constraint violated"} 



=== TEST 7: Insert a record with value of B is not null
--- request
POST /=/model/account/~/~
{ "A": "a3","B":"b3"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/3"}



=== TEST 8: Insert a record with value of D is not null
--- request
POST /=/model/account/~/~
{ "A": "a4","b":"b4"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/4"}


