use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Carrie.js
{
    description: "我的书签",
    columns: [
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":1}



=== TEST 3: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Carrie","name":"Carrie","description":"我的书签"}]



=== TEST 4: insert a record 
--- request
POST /=/model/Carrie/~/~.js
{ title:'hello carrie',url:"http://www.carriezh.cn/"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/1"}



=== TEST 5: read a record according to url
--- request
GET /=/model/Carrie/url/http://www.carriezh.cn/.js
--- response
[{"url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]



=== TEST 6: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ title:'second',url:"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 7: find out two record assign to var hello
--- request
GET /=/model/Carrie/~/~.js?var=hello
--- response
var hello=[{"url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},{"url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 8: the var url param only applies to JSON format
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



=== TEST 9: delete a record use "post"
--- request
POST /=/delete/model/Carrie/id/1.js
--- response
{"success":1,"rows_affected":1}



=== TEST 10: delete a record in correct way
--- request
GET /=/delete/model/Carrie/id/2.js
--- response
{"success":1,"rows_affected":1}



=== TEST 11: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ title:'second',url:"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/3"}



=== TEST 12: delete all the record
--- request
GET /=/delete/model/Carrie/~/~
--- response
{"success":1,"rows_affected":1}



=== TEST 13: see delete result 
--- request
GET /=/model/Carrie/~/~
--- response
[]



=== TEST 14: Delete model
--- request
GET /=/delete/model/Carrie
--- response
{"success":1}



=== TEST 15: Delete model with user info
--- request
DELETE /=/model?user=tester2
--- response
{"success":1}



=== TEST 16: Create model with user info
--- request
POST /=/model/Test2?user=tester2
{
    description: "我的书签",
    columns: [
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":1}



=== TEST 17: insert another record
--- request
POST /=/model/Test2/~/~?user=tester2
{ title:'second',url:"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Test2/id/1"}



=== TEST 18: delete all records with user info
--- request
GET /=/delete/model/Test2/~/~?user=tester2
--- response
{"success":1,"rows_affected":1}



=== TEST 19: Check that the records have been indeed removed
--- request
GET /=/model/Test2/~/~?user=tester2
--- response
[]



=== TEST 20: delete all records with user info (the wrong way)
--- request
GET /=/delete/Test2/~/~?user=tester2
--- response
{"success":0,"error":"Unknown URL catagory: Test2"}


=== TEST 21: insert another record
--- request
POST /=/model/Test2/~/~?user=tester2
{ title:'second',url:"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Test2/id/2"}



=== TEST 22: read record using yml
--- format: YAML
--- request
GET /=/model/Test2/~/~.yml?user=tester2
--- response
--- 
- 
  id: 2
  title: second
  url: http://zhangxiaojue.cn



=== TEST 23: read record using json
--- request
GET /=/model/Test2/~/~?user=tester2
--- response
[{"url":"http://zhangxiaojue.cn","title":"second","id":"2"}]

