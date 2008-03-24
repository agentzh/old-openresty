# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models (bad account name)
--- request
DELETE /=/model?user=.Admin
--- response
{"success":0,"error":"Bad user name: \".Admin\""}



=== TEST 2: Delete existing models (using default Admin role)
--- request
DELETE /=/model?user=$TestAccount
--- response
{"success":0,"error":"Password for $TestAccount.Admin is required."}



=== TEST 3: Delete existing models (using default Admin role)
--- request
DELETE /=/model?user=$TestAccount&password=4423038
--- response
{"success":0,"error":"Password for $TestAccount.Admin is incorrect."}



=== TEST 4: Delete existing models (using default Admin role) but w/o cookie
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass
--- response
{"success":1}



=== TEST 5: Delete existing models
--- request
DELETE /=/model
--- response
{"success":0,"error":"Login required."}



=== TEST 6: Delete existing models (using default Admin role) but with cookie
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
--- response
{"success":1}



=== TEST 7: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 8: Create a model
--- request
POST /=/model/Carrie.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"success":1}



=== TEST 9: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Carrie","name":"Carrie","description":"我的书签"}]
--- LAST



=== TEST 10: insert a record 
--- request
POST /=/model/Carrie/~/~.js
{ "title":"hello carrie","url":"http://www.carriezh.cn/"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/1"}



=== TEST 11: read a record according to url
--- request
GET /=/model/Carrie/url/http://www.carriezh.cn/.js
--- response
[{"url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]



=== TEST 12: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"second","url":"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 13: find out two record assign to var hello
--- request
GET /=/model/Carrie/~/~.js?var=hello
--- response
hello=[{"url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},{"url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 14: the var url param only applies to JSON format
--- request
GET /=/model/Carrie/~/~.yml?var=hello
--- format: YAML
--- response
--- 
- 
  id: 1
  title: hello carrie
  url: http://www.carriezh.cn/
- 
  id: 2
  title: second
  url: http://zhangxiaojue.cn



=== TEST 15: delete a record use "post"
--- request
POST /=/delete/model/Carrie/id/1.js
--- response
{"success":0,"error":"No POST content specified or no \"data\" field found."}



=== TEST 16: delete a record use "post"
--- request
GET /=/delete/model/Carrie/id/1.js
--- response
{"success":1,"rows_affected":1}



=== TEST 17: delete a record in correct way
--- request
GET /=/delete/model/Carrie/id/2.js
--- response
{"success":1,"rows_affected":1}



=== TEST 18: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"second","url":"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/3"}



=== TEST 19: delete all the record
--- request
GET /=/delete/model/Carrie/~/~
--- response
{"success":1,"rows_affected":1}



=== TEST 20: see delete result 
--- request
GET /=/model/Carrie/~/~
--- response
[]



=== TEST 21: Delete model
--- request
GET /=/delete/model/Carrie
--- response
{"success":1}



=== TEST 22: Delete model with user info
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass
--- response
{"success":1}



=== TEST 23: Check the model list
--- request
GET /=/model?user=$TestAccount.Admin&password=$TestPass
--- response
[]



=== TEST 24: Create model with user info
--- request
POST /=/model/Test2?user=$TestAccount&password=$TestPass
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"success":1}



=== TEST 25: insert another record
--- request
POST /=/model/Test2/~/~?user=$TestAccount&password=$TestPass
{ "title":"second","url":"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Test2/id/1"}



=== TEST 26: delete all records with user info
--- request
GET /=/delete/model/Test2/~/~?user=$TestAccount&password=$TestPass
--- response
{"success":1,"rows_affected":1}



=== TEST 27: Check that the records have been indeed removed
--- request
GET /=/model/Test2/~/~?user=$TestAccount&password=$TestPass
--- response
[]



=== TEST 28: delete all records with user info (the wrong way)
--- request
GET /=/delete/Test2/~/~?user=$TestAccount&password=$TestPass
--- response
{"success":0,"error":"Permission denied for the \"Admin\" role."}



=== TEST 29: insert another record
--- request
POST /=/model/Test2/~/~?user=$TestAccount&password=$TestPass
{ "title":"second","url":"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Test2/id/2"}



=== TEST 30: read record using yml
--- format: YAML
--- request
GET /=/model/Test2/~/~.yml?user=$TestAccount&password=$TestPass
--- response
--- 
- 
  id: 2
  title: second
  url: http://zhangxiaojue.cn



=== TEST 31: read record using json
--- request
GET /=/model/Test2/~/~?user=$TestAccount&password=$TestPass
--- response
[{"url":"http://zhangxiaojue.cn","title":"second","id":"2"}]



=== TEST 32: Add column
--- request
POST /=/model/Test2/num?user=$TestAccount&password=$TestPass
{ "type":"integer","label":"num"}
--- response
{"success":1,"src":"/=/model/Test2/num"}



=== TEST 33: Update records
--- request
POST /=/put/model/Test2/~/~?user=$TestAccount&password=$TestPass
{ "num":1 }
--- response
{"success":1,"rows_affected":1}



=== TEST 34: read records
--- request
GET /=/model/Test2/~/~?user=$TestAccount&password=$TestPass
--- response
[{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]



=== TEST 35: Update for adding 1 at the original record
--- request
POST /=/put/model/Test2/id/2?user=$TestAccount&password=$TestPass
{ num:num+1}
--- response
{"success":1,"rows_affected":1}
--- SKIP



=== TEST 36:read records
--- request
GET /=/model/Test2/~/~?user=$TestAccount&password=$TestPass
--- response
[{"num":"2","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]
--- SKIP

