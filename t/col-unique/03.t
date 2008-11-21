# vi:filetype=

#创建 unique 属性为 true 的列，验证插入两行带相同值的行会报"Unique constraint violated."的错误

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model(column with unique attribute is true)
--- request
POST /=/model/testunique
{ "description": "test unique path03","columns": [{ "name":"jx03","type":"text","label":"jx03","unique":true}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path03","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx03
--- response
{"name":"jx03","default":null,"label":"jx03","type":"text","unique":true,"not_null":false}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx03": "A03"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx03":"A03"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx03": "A03"}
--- response
{"success":0,"error":"Unique constraint violated."}



=== TEST 8: Get all records(1 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx03":"A03"}]
