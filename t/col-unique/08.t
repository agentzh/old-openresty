# vi:filetype=

##创建 unique 属性为 true 的列，插入两行数据为 null 的列不会违反到 unique 约束 

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model(column with unique attribute is false)
--- request
POST /=/model/testunique
{ "description": "test unique path08","columns": [{"name":"jx08","type":"text","label":"jx08","unique":true}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path08","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx08
--- response
{"name":"jx08","default":null,"label":"jx08","type":"text","unique":true}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx08":null}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx08":null}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx08":null}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 8: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx08":null},{"id":"2","jx08":null}]



=== TEST 9: Modify column unique from true to false
--- request
PUT /=/model/testunique/jx08
{"unique": false}
--- response
{"success":1}



=== TEST 10: check the column
--- request
GET /=/model/testunique/jx08
--- response
{"name":"jx08","default":null,"label":"jx08","type":"text","unique":false}



=== TEST 11: Insert 1 record
--- request
POST /=/model/testunique/~/~
{ "jx08": "A08"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}



=== TEST 12: Get all records(3 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx08":null},{"id":"2","jx08":null},{"id":"3","jx08":"A08"}]



=== TEST 13: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx08": "A08"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}



=== TEST 14: Get all records(4 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx08":null},{"id":"2","jx08":null},{"id":"3","jx08":"A08"},{"id":"4","jx08":"A08"}]



=== TEST 15: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx08": "A08-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}



=== TEST 16: Get all records(5 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx08":null},{"id":"2","jx08":null},{"id":"3","jx08":"A08"},{"id":"4","jx08":"A08"},{"id":"5","jx08":"A08-1"}]

