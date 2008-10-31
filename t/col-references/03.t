# vi:filetype=

#创建1列，其References指向一个存在的model中属性值不匹配的列

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
{"description": "referencesmodel","columns": [{ "name":"referencesid","type":"integer","label":"referencesid"}]}
--- response
{"success":1}



=== TEST 3: check the model
--- request
GET /=/model/
--- response
[{"description": "referencesmodel","name": "referencesmodel","src":"/=/model/referencesmodel"}]



=== TEST 4: check the column
--- request
GET /=/model/referencesmodel/referencesid
--- response
{"name":"referencesid","default":null,"label":"referencesid","type":"integer"}



=== TEST 5: create a model
--- request
POST /=/model/testreferences
{"description": "test references path03","columns": [{ "name":"jx03","type":"text","label":"jx03","references":{"model": "referencesmodel","column":"referencesid"}}]}
--- response
{"success":0,"error":"the type of \"jx03\" is not match of references \"referencesid\"!"}