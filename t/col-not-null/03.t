# vi:filetype=
#添加not_null属性为true的列
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
{"type":"integer","label":"d","not_null":true, "unique":false}
--- response
{"success":1,"src":"/=/model/account/D"}



=== TEST 4: Check the new column D
--- request
GET /=/model/account/D
--- response
{"name":"D","default":null,"label":"d","type":"integer","not_null":true,"unique":false}



=== TEST 5: Insert a record with value of D is null
--- request
POST /=/model/account/~/~
{ "A": "jingjing3"}
--- response
{"success":0,"error":"null value in column \"D\" violates not-null constraint"}



=== TEST 6: Insert a record with value of D is not null
--- request
POST /=/model/account/~/~
{ "A": "jingjing3","D":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/account/id/2"}

