# vi:filetype=

#创建1列，其References指向一个存在的model中存在的列
#reference的列里原来有一个值
#model创建成功,有外键的列创建成功
#向model列里插入一个值其外键与reference列里的值相同，成功
#删除掉新增的这条记录，成功
#删除reference的列里原来的那条记录(成功)


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
{"description": "test references path11","columns":[{"name":"jx1101","type":"text","label":"jx1101"}]}
--- response
{"success":1}



=== TEST 8: check the model
--- request
GET /=/model/testreferences
--- response
{"description": "test references path11","name": "testreferences","columns":[{"name":"id","type":"serial","label":"ID"},{"name":"jx1101","type":"text","label":"jx1101","default":null}]}



=== TEST 9: check the column
--- request
GET /=/model/testreferences/jx1101
--- response
{"name":"jx1101","default":null,"label":"jx1101","type":"text"}



=== TEST 10: create a column
--- request
POST /=/model/testreferences/jx1102
{"name":"jx1102","type":"integer","label":"jx1102","references":{"model": "referencesmodel","column":"referencesid"}}
--- response
{"success":1,"src":"/=model/testreferences/jx1102"}



=== TEST 11: check the column
--- request
GET /=/model/testreferences/jx1102
--- response
{"name":"jx1102","default":null,"type":"integer","label":"jx1102","references":{"model": "referencesmodel","column":"referencesid"}}



=== TEST 12: Insert one record into model
--- request
POST /=/model/testreferences/~/~
{"jx1101":"A1101","jx1102": 1}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/testreferences/id/1"}



=== TEST 13: Get all records(1 record)
--- request
GET /=/model/testreferences/~/~
--- response
[{"id":"1","jx1101":"A1101","jx1102": 1}]



=== TEST 14: Delete record in testreferences
--- request
DELETE /=/model/testreferences/jx1102/1
--- response
{"success":1,"rows_affected":1}



=== TEST 15: Delete record in referencesmodel
--- request
DELETE /=/model/referencesmodel/referencesid/1
--- response
{"success":1,"rows_affected":1}

