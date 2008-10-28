# vi:filetype=

##创建 unique 属性为 false 的列，插入数据为空字符串 "" 的列会违反到 unique 约束

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
{ "description": "test unique path09","columns": [{"name":"jx09","type":"text","label":"jx09","unique":false}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path09","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx09
--- response
{"name":"jx09","default":null,"label":"jx09","type":"text","unique":false}


=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx09":""}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx09":""}]


=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx09":""}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 8: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx09":""},{"id":"2","jx09":""}]


=== TEST 9: Modify column unique from false to true
--- request
PUT /=/model/testunique/jx09
{"unique": true}
--- response
{"success":0,"error":"column has same value so can't change unique attribute from false to true"}


=== TEST 10: check the column
--- request
GET /=/model/testunique/jx09
--- response
{"name":"jx09","default":null,"label":"jx09","type":"text","unique":false}


=== TEST 11: Insert 1 record
--- request
POST /=/model/testunique/~/~
{ "jx09": ""}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}


=== TEST 12: Get all records(3 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx09":""},{"id":"2","jx09":""},{"id":"3","jx09":""}]


=== TEST 13: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx09": "A09"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}


=== TEST 14: Get all records(4 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx09":""},{"id":"2","jx09":""},{"id":"3","jx09":""},{"id":"4","jx09":"A09"}]
