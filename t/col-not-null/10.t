# vi:filetype=
# ĳ�е�not_null���Բ���Ӱ�쵽����û��not_null���Ե���
# �Ⱥ󴴽����У��ȴ�������not_null���󴴽���û��not_null
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
{ "description": "test model","columns": [{ "name":"A","type":"text","label":"a","not_null":true}]}
--- response
{"success":1}



=== TEST 3: Add a new column with no null
--- request
POST /=/model/account/B
{"type":"integer","label":"b"}
--- response
{"success":1,"src":"/=/model/account/B"}



=== TEST 4: Check the column A
--- request
GET /=/model/account/A
--- response
{"name":"A","default":null,"label":"a","type":"integer","not_null":true}



=== TEST 5: Check the new column B
--- request
GET /=/model/account/B
--- response
{"name":"B","default":null,"label":"b","type":"integer","not_null":false}



=== TEST 6: Insert a record with value of A is null
--- request
POST /=/model/account/~/~
{ "B":"1"}
--- response
{"success":0,"error":"Not null constraint violated"}



=== TEST 7: Insert a record with value of A is not null
--- request
POST /=/model/account/~/~
{ "A":"a1","B":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"}



=== TEST 8: Insert a record with value of B is null
--- request
POST /=/model/account/~/~
{ "A": "a2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/2"}



=== TEST 9: Insert a record with value of B is not null
--- request
POST /=/model/account/~/~
{ "A": "a3","B":"2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/3"}


