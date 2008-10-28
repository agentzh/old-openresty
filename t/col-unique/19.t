# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#先创建1列有unique = false 属性的，有值，再创建1列有unique = true属性的

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
{ "description": "test unique path19","columns": [{"name":"jx1901","type":"text","label":"jx1901","unique":false}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path19","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1901
--- response
{"name":"jx1901","default":null,"label":"jx1901","type":"text","unique":false}


=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 6: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901"}]


=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 8: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901"},{"id":"2","jx1901":"A1901"}]


=== TEST 9: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}


=== TEST 10: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901"},{"id":"2","jx1901":"A1901"},{"id":"3","jx1901":"A1901-1"}]


=== TEST 11: create a column(with unique attribute is true)
--- request
POST /=/model/testunique/jx1902
{"type":"text","label":"jx1902","unique":true}
--- response
{"success":1,"src":"/=/model/testunique/jx1902"}


=== TEST 12: check the column
--- request
GET /=/model/testunique/jx1902
--- response
{"name":"jx1902","default":null,"label":"jx1902","type":"text","unique":true}


=== TEST 13: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901","jx1902":"A1902"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}


=== TEST 14: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901","jx1902":null},{"id":"2","jx1901":"A1901","jx1902":null},{"id":"3","jx1901":"A1901-1","jx1902":null},{"id":"4","jx1901":"A1901","jx1902":"A1902"}]


=== TEST 15: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901","jx1902":"A1902"}
--- response
{"success":0,"error":"Unique constraint violated."}


=== TEST 16: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901","jx1902":null},{"id":"2","jx1901":"A1901","jx1902":null},{"id":"3","jx1901":"A1901-1","jx1902":null},{"id":"4","jx1901":"A1901","jx1902":"A1902"}]


=== TEST 17: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901-1","jx1902":"A1902"}
--- response
{"success":0,"error":"Unique constraint violated."}


=== TEST 18: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901","jx1902":null},{"id":"2","jx1901":"A1901","jx1902":null},{"id":"3","jx1901":"A1901-1","jx1902":null},{"id":"4","jx1901":"A1901","jx1902":"A1902"}]


=== TEST 19: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1901": "A1901","jx1902":"A1902-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}


=== TEST 20: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1901":"A1901","jx1902":null},{"id":"2","jx1901":"A1901","jx1902":null},{"id":"3","jx1901":"A1901-1","jx1902":null},{"id":"4","jx1901":"A1901","jx1902":"A1902"},{"id":"5","jx1901":"A1901","jx1902":"A1902-1"}]
