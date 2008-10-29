# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#两列同时创建且第二列的unique=true

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
{ "description": "test unique path11","columns": [{ "name":"jx1101","type":"text","label":"jx1101"}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path11","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1101
--- response
{"name":"jx1101","default":null,"label":"jx1101","type":"text"}



=== TEST 5: create a column(with unique attribute is true)
--- request
POST /=/model/testunique/jx1102
{"type":"text","label":"jx1102","unique":true}
--- response
{"success":1,"src":"/=/model/testunique/jx1102"}



=== TEST 6: check the column
--- request
GET /=/model/testunique/jx1102
--- response
{"name":"jx1102","default":null,"label":"jx1102","type":"text","unique":true}



=== TEST 7: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1101": "A1101","jx1102":"A1102"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 8: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1101":"A1101","jx1102":"A1102"}]



=== TEST 9: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1101": "A1101","jx1102":"A1102"}
--- response
{"success":0,"error":"Unique constraint violated."}



=== TEST 10: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1101":"A1101","jx1102":"A1102"}]



=== TEST 11: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1101": "A1101-1","jx1102":"A1102"}
--- response
{"success":0,"error":"Unique constraint violated."}



=== TEST 12: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1101":"A1101","jx1102":"A1102"}]



=== TEST 13: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1101": "A1101","jx1102":"A1102-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 14: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1101":"A1101","jx1102":"A1102"},{"id":"2","jx1101":"A1101","jx1102":"A1102-1"}]
