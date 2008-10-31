# vi:filetype=

#创建1列，其References指向一个存在的model中存在的列
#References列里存在两个相同的值
#外键创建不成功

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model(referencesmodel)
--- request
POST /=/model/referencesmodel
{"description": "referencesmodel","columns": [{"name":"referencesid","type":"integer","label":"referencesid"}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/referencesmodel
--- response
{"description": "referencesmodel","name": "referencesmodel","columns": [{"name":"id","type":"serial","label":"ID"},{"name":"referencesid","type":"integer","label":"referencesid","default":null}]}



=== TEST 4: check the column
--- request
GET /=/model/referencesmodel/referencesid
--- response
{"name":"referencesid","default":null,"label":"referencesid","type":"integer"}



=== TEST 5: Insert one record
--- request
POST /=/model/referencesmodel/~/~
{"referencesid": 1}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/referencesmodel/id/1"}



=== TEST 6: Get all records(1 record)
--- request
GET /=/model/referencesmodel/~/~
--- response
[{"id":"1","referencesid":"1"}]



=== TEST 7: Insert the same record
--- request
POST /=/model/referencesmodel/~/~
{"referencesid": 1}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/referencesmodel/id/2"}



=== TEST 8: Get all records(2 record)
--- request
GET /=/model/referencesmodel/~/~
--- response
[{"id":"1","referencesid":"1"},{"id":"2","referencesid":"1"}]



=== TEST 9: create a model
--- request
POST /=/model/testreferences
{"description": "test references path05","columns": [{"name":"jx0501","type":"integer","label":"jx0501","references":{"model": "referencesmodel","column":"referencesid"}}]}
--- response
{"success":0,"error":"create reference column failed!"}