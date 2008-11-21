# vi:filetype=
# 某列的not_null属性不会影响到其他没有not_null的列
# 先后创建两列，先创建的没有not_null,后创建的有not_null 
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



=== TEST 3: Add a new column not null is true
--- request
POST /=/model/account/D
{"type":"integer","label":"d","not_null":true}
--- response
{"success":1,"src":"/=/model/account/D"}



=== TEST 4: Check the column A
--- request
GET /=/model/account/A
--- response
{"name":"A","default":null,"label":"a","type":"text","not_null":false,"unique":false}



=== TEST 5: Check the new column D
--- request
GET /=/model/account/D
--- response
{"name":"D","default":null,"label":"d","type":"integer","not_null":true,"unique":false}



=== TEST 6: Insert a record with value of A is null
--- request
POST /=/model/account/~/~
{ "D":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/1"}



=== TEST 7: Insert a record with value of A is not null
--- request
POST /=/model/account/~/~
{ "A":"a1","D":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/2"}



=== TEST 8: Insert a record with value of D is null
--- request
POST /=/model/account/~/~
{ "A": "a2"}
--- response
{"success":0,"error":"null value in column \"D\" violates not-null constraint"}



=== TEST 9: Insert a record with value of D is not null
--- request
POST /=/model/account/~/~
{ "A": "a3","D":"2"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/4"}


