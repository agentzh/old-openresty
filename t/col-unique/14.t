# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#先创建1列没有unique属性，有值，再创建1列有unique = false属性的

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
{ "description": "test unique path14","columns": [{ "name":"jx1401","type":"text","label":"jx1401"}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path14","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1401
--- response
{"name":"jx1401","default":null,"label":"jx1401","type":"text","not_null":false}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1401": "A1401"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1401":"A1401"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1401": "A1401"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 8: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1401":"A1401"},{"id":"2","jx1401":"A1401"}]



=== TEST 9: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1401": "A1401-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}



=== TEST 10: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1401":"A1401"},{"id":"2","jx1401":"A1401"},{"id":"3","jx1401":"A1401-1"}]



=== TEST 11: create a column(with unique attribute is false)
--- request
POST /=/model/testunique/jx1402
{"type":"text","label":"jx1402","unique":false}
--- response
{"success":1,"src":"/=/model/testunique/jx1402"}



=== TEST 12: check the column
--- request
GET /=/model/testunique/jx1402
--- response
{"name":"jx1402","default":null,"label":"jx1402","type":"text","unique":false,"not_null":false}



=== TEST 13: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1401": "A1401","jx1402":"A1402"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}



=== TEST 14: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1401":"A1401","jx1402":null},{"id":"2","jx1401":"A1401","jx1402":null},{"id":"3","jx1401":"A1401-1","jx1402":null},{"id":"4","jx1401":"A1401","jx1402":"A1402"}]



=== TEST 15: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1401": "A1401","jx1402":"A1402"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}



=== TEST 16: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1401":"A1401","jx1402":null},{"id":"2","jx1401":"A1401","jx1402":null},{"id":"3","jx1401":"A1401-1","jx1402":null},{"id":"4","jx1401":"A1401","jx1402":"A1402"},{"id":"5","jx1401":"A1401","jx1402":"A1402"}]



=== TEST 17: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1401": "A1401","jx1402":"A1402-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/6"}



=== TEST 18: Get record(6 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1401":"A1401","jx1402":null},{"id":"2","jx1401":"A1401","jx1402":null},{"id":"3","jx1401":"A1401-1","jx1402":null},{"id":"4","jx1401":"A1401","jx1402":"A1402"},{"id":"5","jx1401":"A1401","jx1402":"A1402"},{"id":"6","jx1401":"A1401","jx1402":"A1402-1"}]
