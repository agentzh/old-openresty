# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#先创建1列有unique = false 属性的，再创建一列没有unique属性的

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
{ "description": "test unique path16","columns": [{ "name":"jx1601","type":"text","label":"jx1601","unique":false}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path16","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1601
--- response
{"name":"jx1601","default":null,"label":"jx1601","type":"text","unique":false}


=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1601": "A1601"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 6: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1601":"A1601"}]


=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1601": "A1601"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 8: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1601":"A1601"},{"id":"2","jx1601":"A1601"}]


=== TEST 9: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1601": "A1601-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}


=== TEST 10: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1601":"A1601"},{"id":"2","jx1601":"A1601"},{"id":"3","jx1601":"A1601-1"}]


=== TEST 11: create a column(without unique attribute)
--- request
POST /=/model/testunique/jx1602
{"type":"text","label":"jx1602"}
--- response
{"success":1,"src":"/=/model/testunique/jx1602"}


=== TEST 12: check the column
--- request
GET /=/model/testunique/jx1602
--- response
{"name":"jx1602","default":null,"label":"jx1602","type":"text"}


=== TEST 13: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1601": "A1601","jx1602":"A1602"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}


=== TEST 14: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1601":"A1601","jx1602":null},{"id":"2","jx1601":"A1601","jx1602":null},{"id":"3","jx1601":"A1601-1","jx1602":null},{"id":"4","jx1601":"A1601","jx1602":"A1602"}]


=== TEST 15: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1601": "A1601","jx1602":"A1602"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}


=== TEST 16: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1601":"A1601","jx1602":null},{"id":"2","jx1601":"A1601","jx1602":null},{"id":"3","jx1601":"A1601-1","jx1602":null},{"id":"4","jx1601":"A1601","jx1602":"A1602"},{"id":"5","jx1601":"A1601","jx1602":"A1602"}]


=== TEST 17: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1601": "A1601","jx1602":"A1602-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/6"}


=== TEST 18: Get record(6 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1601":"A1601","jx1602":null},{"id":"2","jx1601":"A1601","jx1602":null},{"id":"3","jx1601":"A1601-1","jx1602":null},{"id":"4","jx1601":"A1601","jx1602":"A1602"},{"id":"5","jx1601":"A1601","jx1602":"A1602"},{"id":"6","jx1601":"A1601","jx1602":"A1602-1"}]
