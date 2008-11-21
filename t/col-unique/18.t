# vi:filetype=

#某一列的 unique 约束不会影响到其他没有 unique 约束的列
#先创建1列有unique = true属性的，再创建一列unique=false 属性的

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
{ "description": "test unique path18","columns": [{ "name":"jx1801","type":"text","label":"jx1801","unique":true}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path18","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx1801
--- response
{"name":"jx1801","default":null,"label":"jx1801","type":"text","unique":true,"not_null":false}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801"}
--- response
{"error":"duplicate key value violates unique constraint \"testunique_jx1801_key\"","success":0}


=== TEST 8: Get record(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801"}]



=== TEST 9: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}



=== TEST 10: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801"},{"id":"3","jx1801":"A1801-1"}]



=== TEST 11: create a column(with unique attribute is false)
--- request
POST /=/model/testunique/jx1802
{"type":"text","label":"jx1802","unique":false}
--- response
{"success":1,"src":"/=/model/testunique/jx1802"}



=== TEST 12: check the column
--- request
GET /=/model/testunique/jx1802
--- response
{"name":"jx1802","default":null,"label":"jx1802","type":"text","unique":false,"not_null":false}



=== TEST 13: Insert one record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801","jx1802":"A1802"}
--- response
{"error":"duplicate key value violates unique constraint \"testunique_jx1801_key\"","success":0}


=== TEST 14: Get record(2 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801","jx1802":null},{"id":"3","jx1801":"A1801-1","jx1802":null}]



=== TEST 15: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801-2","jx1802":"A1802"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}



=== TEST 16: Get record(3 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801","jx1802":null},{"id":"3","jx1801":"A1801-1","jx1802":null},{"id":"5","jx1801":"A1801-2","jx1802":"A1802"}]



=== TEST 17: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801-3","jx1802":"A1802"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/6"}



=== TEST 18: Get record(4 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801","jx1802":null},{"id":"3","jx1801":"A1801-1","jx1802":null},{"id":"5","jx1801":"A1801-2","jx1802":"A1802"},{"id":"6","jx1801":"A1801-3","jx1802":"A1802"}]



=== TEST 19: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx1801": "A1801-4","jx1802":"A1802-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/7"}



=== TEST 20: Get record(5 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx1801":"A1801","jx1802":null},{"id":"3","jx1801":"A1801-1","jx1802":null},{"id":"5","jx1801":"A1801-2","jx1802":"A1802"},{"id":"6","jx1801":"A1801-3","jx1802":"A1802"},{"id":"7","jx1801":"A1801-4","jx1802":"A1802-1"}]
