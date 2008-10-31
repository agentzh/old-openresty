# vi:filetype=

#创建1列，其References指向一个存在的model中存在的列
#插入一个在References列中不存在的数值

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



=== TEST 5: create a model
--- request
POST /=/model/testreferences
{"description": "test references path04","columns": [{"name":"jx0401","type":"integer","label":"jx0401","references":{"model": "referencesmodel","column":"referencesid"}}]}
--- response
{"success":1}



=== TEST 6: check the model
--- request
GET /=/model/testreferences
--- response
{"description": "test references path04","name": "testreferences","columns": [{"name":"id","type":"serial","label":"ID"},{"name":"jx0401","type":"integer","label":"jx0401","references":{"model": "referencesmodel","column":"referencesid"}}]}



=== TEST 7: check the column
--- request
GET /=/model/testreferences/jx0401
--- response
{"name":"jx0401","label":"jx0401","type":"integer","references":{"model": "referencesmodel","column":"referencesid"}}



=== TEST 8: create a column
--- request
POST /=/model/testreferences/jx0402
{"type":"text","label":"jx0402"}
--- response
{"success":1,"src":"/=model/testreferences/jx0402"}



=== TEST 9: check the column
--- request
GET /=/model/testreferences/jx0402
--- response
{"name":"jx0402","default":null,"label":"jx0402","type":"text"}



=== TEST 10: Insert one record
--- request
POST /=/model/testreferences/~/~
{"jx0401": 1,"jx0402":"A0402"}
--- response
{"success":0,"error":"reference has no value!"}


