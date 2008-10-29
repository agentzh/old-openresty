# vi:filetype=

##创建 unique 属性为 false 的列，当列里有相同的值时不能修改unique属性从false到true

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
{ "description": "test unique path05","columns": [{"name":"jx05","type":"text","label":"jx05","unique":false}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path05","name": "testunique","src":"/=/model/testunique"}]



=== TEST 4: check the column
--- request
GET /=/model/testunique/jx05
--- response
{"name":"jx05","default":null,"label":"jx05","type":"text","unique":false}



=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx05": "A05"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}



=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx05":"A05"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx05": "A05"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}



=== TEST 8: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx05":"A05"},{"id":"2","jx05":"A05"}]



=== TEST 9: Modify column unique from false to true
--- request
PUT /=/model/testunique/jx05
{"unique": true}
--- response
{"success":0,"error":"column has same value so can't change unique attribute from false to true"}



=== TEST 10: check the column
--- request
GET /=/model/testunique/jx05
--- response
{"name":"jx05","default":null,"label":"jx05","type":"text","unique":false}



=== TEST 11: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx05": "A05"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/3"}



=== TEST 12: Get all records(3 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx05":"A05"},{"id":"2","jx05":"A05"},{"id":"3","jx05":"A05"}]
