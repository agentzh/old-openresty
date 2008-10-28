# vi:filetype=

#���� unique ����Ϊ true ���У��޸��е�����Ϊfalse����Լ���������ͬvalueֵ

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}


=== TEST 2: create a model(column with unique attribute is true)
--- request
POST /=/model/testunique
{ "description": "test unique path04","columns": [{ "name":"jx04","type":"text","label":"jx04","unique":true}]}
--- response
{"success":1}


=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "test unique path04","name": "testunique","src":"/=/model/testunique"}]


=== TEST 4: check the column
--- request
GET /=/model/testunique/jx04
--- response
{"name":"jx04","default":null,"label":"jx04","type":"text","unique":true}


=== TEST 5: Insert one record
--- request
POST /=/model/testunique/~/~
{"jx04": "A04"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/1"}


=== TEST 6: Get all records(1 record)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx04":"A04"}]


=== TEST 7: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx04": "A04"}
--- response
{"success":0,"error":"Unique constraint violated."}


=== TEST 8: Get all records(1 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx04":"A04"}]


=== TEST 9: Modify column unique from true to false
--- request
PUT /=/model/testunique/jx04
{"unique": false}
--- response
{"success":1}


=== TEST 10: check the column
--- request
GET /=/model/testunique/jx04
--- response
{"name":"jx04","default":null,"label":"jx04","type":"text","unique":false}


=== TEST 11: Insert the same record
--- request
POST /=/model/testunique/~/~
{ "jx04": "A04"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testunique/id/2"}


=== TEST 12: Get all records(2 records)
--- request
GET /=/model/testunique/~/~
--- response
[{"id":"1","jx04":"A04"},{"id":"2","jx04":"A04"}]
