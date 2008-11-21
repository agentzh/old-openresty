# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#先创建1列没有unique属性，有值，再创建1列有unique = true属性的

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
{ "description": "test unique path12","columns": [{ "name":"jx1201","type":"text","label":"jx1201"}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path12","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1201
--- response
{"name":"jx1201","default":null,"label":"jx1201","type":"text","unique":false,"not_null":false"}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 8: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201"},{"id":"2","jx1201":"A1201"}]



=== TEST 9: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}



=== TEST 10: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201"},{"id":"2","jx1201":"A1201"},{"id":"3","jx1201":"A1201-1"}]



=== TEST 11: create a column(with unique attribute is true)
--- request
POST /=/model/testunique/jx1202
{"type":"text","label":"jx1202","unique":true}
--- response
{"success":1,"src":"/=/model/testunique/jx1202"}



=== TEST 12: check the column
--- request
GET /=/model/testunique/jx1202
--- response
{"name":"jx1202","default":null,"label":"jx1202","type":"text","unique":true,"not_null":false}



=== TEST 13: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201","jx1202":"A1202"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}



=== TEST 14: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201","jx1202":null},{"id":"2","jx1201":"A1201","jx1202":null},{"id":"3","jx1201":"A1201-1","jx1202":null},{"id":"4","jx1201":"A1201","jx1202":"A1202"}]



=== TEST 15: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201","jx1202":"A1202"}
--- response
{"success":0,"error":"Unique constraint violated."}



=== TEST 16: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201","jx1202":null},{"id":"2","jx1201":"A1201","jx1202":null},{"id":"3","jx1201":"A1201-1","jx1202":null},{"id":"4","jx1201":"A1201","jx1202":"A1202"}]



=== TEST 17: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201-1","jx1202":"A1202"}
--- response
{"success":0,"error":"Unique constraint violated."}



=== TEST 18: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201","jx1202":null},{"id":"2","jx1201":"A1201","jx1202":null},{"id":"3","jx1201":"A1201-1","jx1202":null},{"id":"4","jx1201":"A1201","jx1202":"A1202"}]



=== TEST 19: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1201": "A1201","jx1202":"A1202-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}



=== TEST 20: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1201":"A1201","jx1202":null},{"id":"2","jx1201":"A1201","jx1202":null},{"id":"3","jx1201":"A1201-1","jx1202":null},{"id":"4","jx1201":"A1201","jx1202":"A1202"},{"id":"5","jx1201":"A1201","jx1202":"A1202-1"}]
