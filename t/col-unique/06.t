# vi:filetype=

##创建 unique 属性为 false 的列，当列里没有相同的值时可以修改unique属性从false到true

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
{ "description": "test unique path06","columns": [{"name":"jx06","type":"text","label":"jx06","unique":false}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path06","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx06
--- response
{"name":"jx06","default":null,"label":"jx06","type":"text","unique":false}


=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx06": "A06"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx06":"A06"}]


=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx06": "A06"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 8: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx06":"A06"},{"id":"2","jx06":"A06"}]


=== TEST 9: Modify column unique from false to true
--- request
PUT /=/model/testunique/jx06
{"unique": true}
--- response
{"success":0,"error":"column has same value so can't change unique attribute from false to true"}


=== TEST 10: check the column
--- request
GET /=/model/testunique/jx06
--- response
{"name":"jx06","default":null,"label":"jx06","type":"text","unique":false}


=== TEST 11: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx06": "A06"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}


=== TEST 12: Get all records(3 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx06":"A06"},{"id":"2","jx06":"A06"},{"id":"3","jx06":"A06"}]


=== TEST 13: Delete record
--- request
DELETE /=/model/testunique/id/2
--- response
{"success":1,"rows_affected":1}


=== TEST 14: Delete record
--- request
DELETE /=/model/testunique/id/3
--- response
{"success":1,"rows_affected":1}


=== TEST 15: Get all records(1 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx06":"A06"}]


=== TEST 16: Modify column unique from false to true
--- request
PUT /=/model/testunique/jx06
{"unique": true}
--- response
{"success":1}


=== TEST 17: check the column
--- request
GET /=/model/testunique/jx06
--- response
{"name":"jx06","default":null,"label":"jx06","type":"text","unique":true}


=== TEST 18: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx06": "A06"}
--- response
{"success":0,"error":"Unique constraint violated."}


=== TEST 19: Get all records(1 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx06":"A06"}]


=== TEST 20: Insert different record
--- request
POST /=/model/testunique/~/~
{ "jx06": "A06-1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/4"}


=== TEST 21: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx06":"A06"},{"id":"4","jx06":"A06-1"}]
