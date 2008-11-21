# vi:filetype=

##创建 unique 属性为 false 的列，插入两行数据为 null 的列不会违反到 unique 约束 

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
{ "description": "test unique path07","columns": [{"name":"jx07","type":"text","label":"jx07","unique":false}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path07","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx07
--- response
{"name":"jx07","default":null,"label":"jx07","type":"text","unique":false,"not_null":false}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx07":null}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx07":null}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx07":null}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 8: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx07":null},{"id":"2","jx07":null}]



=== TEST 9: Modify column unique from false to true
--- request
PUT /=/model/testunique/jx07
{"unique": true}
--- response
{"success":1}



=== TEST 10: check the column
--- request
GET /=/model/testunique/jx07
--- response
{"name":"jx07","default":null,"label":"jx07","type":"text","unique":true,"not_null":false}



=== TEST 11: Insert 1 record
--- request
POST /=/model/testunique/~/~
{ "jx07": "A07"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}



=== TEST 12: Get all records(3 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx07":null},{"id":"2","jx07":null},{"id":"3","jx07":"A07"}]



=== TEST 13: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx07": "A07"}
--- response
{"error":"duplicate key value violates unique constraint \"testunique_jx07_key\"","success":0}


=== TEST 14: Get all records(3 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx07":null},{"id":"2","jx07":null},{"id":"3","jx07":"A07"}]



=== TEST 15: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx07": "A07-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/5"}



=== TEST 16: Get all records(4 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx07":null},{"id":"2","jx07":null},{"id":"3","jx07":"A07"},{"id":"5","jx07":"A07-1"}]

