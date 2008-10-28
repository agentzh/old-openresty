# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#先创建1列有unique = true属性的，再创建一列没有unique属性的

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
{ "description": "test unique path15","columns": [{ "name":"jx1501","type":"text","label":"jx1501","unique":true}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path15","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1501
--- response
{"name":"jx1501","default":null,"label":"jx1501","type":"text","unique":true}


=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 6: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501"}]


=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501"}
--- response
{"success":0,"error":"Unique constraint violated."}


=== TEST 8: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501"}]


=== TEST 9: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 10: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501"},{"id":"2","jx1501":"A1501-1"}]


=== TEST 11: create a column(without unique attribute)
--- request
POST /=/model/testunique/jx1502
{"type":"text","label":"jx1502"}
--- response
{"success":1,"src":"/=/model/testunique/jx1502"}


=== TEST 12: check the column
--- request
GET /=/model/testunique/jx1502
--- response
{"name":"jx1502","default":null,"label":"jx1502","type":"text"}


=== TEST 13: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501","jx1502":"A1502"}
--- response
{"success":0,"error":"Unique constraint violated."}


=== TEST 14: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501","jx1502",null},{"id":"2","jx1501":"A1501-1","jx1502":null}]


=== TEST 15: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501-2","jx1502":"A1502"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}


=== TEST 16: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501","jx1502":null},{"id":"2","jx1501":"A1501-1","jx1502":null},{"id":"3","jx1501":"A1501-2","jx1502":"A1502"}]


=== TEST 17: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501-3","jx1502":"A1502"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}


=== TEST 18: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501","jx1502":null},{"id":"2","jx1501":"A1501-1","jx1502":null},{"id":"3","jx1501":"A1501-2","jx1502":"A1502"},{"id":"4","jx1501":"A1501-3","jx1502":"A1502"}]


=== TEST 19: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1501": "A1501-4","jx1502":"A1502-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}


=== TEST 20: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1501":"A1501","jx1502":null},{"id":"2","jx1501":"A1501-1","jx1502":null},{"id":"3","jx1501":"A1501-2","jx1502":"A1502"},{"id":"4","jx1501":"A1501-3","jx1502":"A1502"},{"id":"5","jx1501":"A1501-4","jx1502":"A1502-1"}]
