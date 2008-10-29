# vi:filetype=

#创建不带 unique 属性的列，验证插入两行有相同值的行没有报错

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model(column without unique attribute)
--- request
POST /=/model/testunique
{ "description": "test unique path01","columns": [{ "name":"jx01","type":"text","label":"jx01"}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path01","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx01
--- response
{"name":"jx01","default":null,"label":"jx01","type":"text"}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx01": "A01"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx01":"A01"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx01": "A01"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 8: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx01":"A01"},{"id":"2","jx01":"A01"}]
