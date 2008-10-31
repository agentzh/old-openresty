# vi:filetype=

#创建1列，其References指向一个存在的model中存在的列
#reference的列里原来有一个值
#model创建成功,有外键的列创建成功
#向model列里插入一个值其外键与reference列里的值相同，成功
#删除reference的列里原来的那条记录(失败)


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



=== TEST 7: create a model
--- request
POST /=/model/testreferences
{"description": "test references path10","columns":[{"name":"jx1001","type":"text","label":"jx1001"}]}
--- response
{"success":1}



=== TEST 8: check the model
--- request
GET /=/model/testreferences
--- response
{"description": "test references path10","name": "testreferences","columns":[{"name":"id","type":"serial","label":"ID"},{"name":"jx1001","type":"text","label":"jx1001","default":null}]}



=== TEST 9: check the column
--- request
GET /=/model/testreferences/jx1001
--- response
{"name":"jx1001","default":null,"label":"jx1001","type":"text"}



=== TEST 10: create a column
--- request
POST /=/model/testreferences/jx1002
{"name":"jx1002","type":"integer","label":"jx1002","references":{"model": "referencesmodel","column":"referencesid"}}
--- response
{"success":1,"src":"/=model/testreferences/jx1002"}



=== TEST 11: check the column
--- request
GET /=/model/testreferences/jx1002
--- response
{"name":"jx1002","default":null,"type":"integer","label":"jx1002","references":{"model": "referencesmodel","column":"referencesid"}}



=== TEST 12: Insert one record into model
--- request
POST /=/model/testreferences/~/~
{"jx1001":"A1001","jx1002": 1}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testreferences/id/1"}



=== TEST 13: Get all records(1 record)
--- request
GET /=/model/testreferences/~/~
--- response
[{"id":"1","jx1001":"A1001","jx1002": 1}]



=== TEST 14: Delete record in referencesmodel
--- request
DELETE /=/model/referencesmodel/referencesid/1
--- response
{"success":0,"error":"can not delete the reference id!"}
