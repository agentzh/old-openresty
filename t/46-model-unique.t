# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model name grade
--- request
POST /=/model/grade
{ "description": "subject grade","columns":[{"name":"student_id","label":"student id","type":"serial"},{"name":"subject_name","label":"subject name","type":"text"},{"name":"grade","label":"subject grade","type":"integer"}]}
--- response
{"success":1}



=== TEST 3: get the model
--- request
GET /=/model/grade
--- response
{"columns":[{"label":"ID","name":"id","type":"serial"},{"default":null,"label":"student id","name":"student_id","type":"serial"},{"default":null,"label":"subject name","name":"subject_name","type":"text"},{"default":null,"label":"subject grade","name":"grade","type":"integer"}],"description":"subject grade","name":"grade"}



=== TEST 4: Insert a record
--- request
POST /=/model/grade/~/~
{ "student_id": "1","subject_name":"数学"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/1"}



=== TEST 5: Insert a record with same id value
--- request
POST /=/model/grade/~/~
{ "student_id": "1","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/2"}



=== TEST 6: Insert a record with same subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/3"}



=== TEST 7: Insert a record with same student id and subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/4"}



=== TEST 8: delete all rows
--- request
DELETE /=/model/grade/~/~
--- response
{"rows_affected":4,"success":1}



=== TEST 9: delete the model
--- request
DELETE /=/model/grade
--- response
{"success":1}



=== TEST 10: add the model with unique attribute
--- request
POST /=/model/grade
{ "description": "subject grade","columns":[{"name":"student_id","label":"student id","type":"serial"},{"name":"subject_name","label":"subject name","type":"text"},{"name":"grade","label":"subject grade","type":"integer"}],"unique": [ "student_id", "subject_name" ]}
--- response
{"success":1}



=== TEST 11: get the model
--- request
GET /=/model/grade
--- response
{"unique":["student_id","subject_name"],"columns":[{"label":"ID","name":"id","type":"serial"},{"default":null,"label":"student id","name":"student_id","type":"serial"},{"default":null,"label":"subject name","name":"subject_name","type":"text"},{"default":null,"label":"subject grade","name":"grade","type":"integer"}],"description":"subject grade","name":"grade"}



=== TEST 12: Insert a record without subject_name value
--- request
POST /=/model/grade/~/~
{ "student_id": "1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/1"}



=== TEST 13: Insert a record without subject_name value again
--- request
POST /=/model/grade/~/~
{ "student_id": "1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/2"}



=== TEST 14: Insert a record
--- request
POST /=/model/grade/~/~
{ "student_id": "1","subject_name":"数学"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/3"}



=== TEST 15: Insert a record with same id value
--- request
POST /=/model/grade/~/~
{ "student_id": "1","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/4"}



=== TEST 16: Insert a record with same subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/5"}



=== TEST 17: Insert a record with same student id and subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"english"}
--- response
{"success":0,"error":"model unique constraint violated"}



=== TEST 18: Insert a record only has grade
--- request
POST /=/model/grade/~/~
{ "grade":"100"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/6"}



=== TEST 19: Insert a record only has grade
--- request
POST /=/model/grade/~/~
{ "grade":"100"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/7"}



=== TEST 20: Insert a record only has grade
--- request
POST /=/model/grade/~/~
{ "grade":"100","student_id":null,"subject_name":null}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/8"}



=== TEST 21: Insert a record only has grade
--- request
POST /=/model/grade/~/~
{ "grade":"100","student_id":null,"subject_name":null}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/9"}



=== TEST 22: delete the unique attribute
--- request
PUT /=/model/grade
{ "description": "subject grade","columns":[{"name":"student_id","label":"student id","type":"serial"},{"name":"subject_name","label":"subject name","type":"text"},{"name":"grade","label":"subject grade","type":"integer"}]}
--- response
{"success":1}



=== TEST 23: get the model
--- request
GET /=/model/grade
--- response
{"unique":["student_id","subject_name"],"columns":[{"label":"ID","name":"id","type":"serial"},{"default":null,"label":"student id","name":"student_id","type":"serial"},{"default":null,"label":"subject name","name":"subject_name","type":"text"},{"default":null,"label":"subject grade","name":"grade","type":"integer"}],"description":"subject grade","name":"grade"}



=== TEST 24: Insert a record with existed student id and subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/10"}



=== TEST 25: add unique attribute
PUT /=/model/grade
{ "unique": ["student_id", "subject_name"] }
--- response
{"success":0,"error":"duplicate rows exist"}



=== TEST 26: delete all rows
--- request
DELETE /=/model/grade/~/~
--- response
{"rows_affected":10,"success":1}



=== TEST 27: add unique attribute
PUT /=/model/grade
{ "unique": ["student_id", "subject_name"] }
--- response
{"success":1}



=== TEST 28: Insert a record with existed student id and subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "1","subject_name":"english"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/1"}



=== TEST 29: Insert a record with existed student id and subject name value
--- request
POST /=/model/grade/~/~
{ "student_id": "1","subject_name":"english"}
--- response
{"success":0,"error":"model unique constraint violated"}



=== TEST 30: Insert a record
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"数学"}
--- response
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/grade/id/2"}



=== TEST 31: Insert a record
--- request
POST /=/model/grade/~/~
{ "student_id": "2","subject_name":"数学"}
--- response
--- response
{"success":0,"error":"model unique constraint violated"}


