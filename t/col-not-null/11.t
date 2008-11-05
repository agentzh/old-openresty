# vi:filetype=
# 某列的not_null属性不会影响到其他没有not_null属性的列
# 先创建两列没有not_null属性的，再将一列not_null属性改为true
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
{ "description": "test model","columns": [{ "name":"A","type":"text","label":"a"},{"name":"B","type":"text","label":"b"}]}
--- response
{"success":1}



=== TEST 3: Check the column A
--- request
GET /=/model/account/A
--- response
{"name":"A","default":null,"label":"a","type":"text","not_null":false,"unique":false}



=== TEST 4: Check the new column B
--- request
GET /=/model/account/B
--- response
{"name":"B","default":null,"label":"b","type":"text","not_null":false,"unique":false}



=== TEST 5: alter B
--- request
PUT /=/model/account/B
{"type":"text","label":"b","not_null":true}
--- response
{"success":1,"src":"/=/model/account/B"}



=== TEST 6: Check the column A
--- request
GET /=/model/account/A
--- response
{"name":"A","default":null,"label":"a","type":"text","not_null":false,"unique":false}



=== TEST 7: Check the new column B
--- request
GET /=/model/account/B
--- response
{"name":"B","default":null,"label":"b","type":"text","not_null":true,"unique":false}



=== TEST 8: Insert a record with value of A is not null
--- request
POST /=/model/account/~/~
{ "A":"a1","B":"b1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"}



=== TEST 9: Insert a record with value of A is null
--- request
POST /=/model/account/~/~
{ "B":"b2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/2"}



=== TEST 10: Insert a record with value of B is null
--- request
POST /=/model/account/~/~
{ "A": "a2"}
--- response
{"success":0,"error":"Not null constraint violated"} 



=== TEST 11: Insert a record with value of B is not null
--- request
POST /=/model/account/~/~
{ "A": "a3","B":"3"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/3"}


