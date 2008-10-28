# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#两列同时创建且第二列的unique=false

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
{ "description": "test unique path13","columns": [{ "name":"jx1301","type":"text","label":"jx1301"}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path13","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1301
--- response
{"name":"jx1301","default":null,"label":"jx1301","type":"text"}


=== TEST 5: create a column(with unique attribute is false)
--- request
POST /=/model/testunique/jx1302
{"type":"text","label":"jx1302","unique":false}
--- response
{"success":1,"src":"/=/model/testunique/jx1302"}


=== TEST 6: check the column
--- request
GET /=/model/testunique/jx1302
--- response
{"name":"jx1302","default":null,"label":"jx1302","type":"text","unique":false}


=== TEST 7: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1301": "A1301","jx1302":"A1302"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 8: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1301":"A1301","jx1302":"A1302"}]


=== TEST 9: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1301": "A1301","jx1302":"A1302"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 10: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1301":"A1301","jx1302":"A1302"},{"id":"2","jx1301":"A1301","jx1302":"A1302"}]


=== TEST 11: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1301": "A1301-1","jx1302":"A1302-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}


=== TEST 12: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1301":"A1301","jx1302":"A1302"},{"id":"2","jx1301":"A1301","jx1302":"A1302"},{"id":"3","jx1301":"A1301-1","jx1302":"A1302-1"}]


=== TEST 13: Insert different record
--- request
POST /=/model/testunique/~/~
{"jx1302":"A1302"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}


=== TEST 14: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1301":"A1301","jx1302":"A1302"},{"id":"2","jx1301":"A1301","jx1302":"A1302"},{"id":"3","jx1301":"A1301-1","jx1302":"A1302-1"},{"id":"4","jx1301":null,"jx1302":"A1302"}]


=== TEST 15: Insert different record
--- request
POST /=/model/testunique/~/~
{"jx1301":"A1301"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}


=== TEST 16: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1301":"A1301","jx1302":"A1302"},{"id":"2","jx1301":"A1301","jx1302":"A1302"},{"id":"3","jx1301":"A1301-1","jx1302":"A1302-1"},{"id":"4","jx1301":null,"jx1302":"A1302"},{"id":"5","jx1301":"A1301","jx1302":null}]
