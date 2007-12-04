use t::OpenAPI;

plan tests => 2 * blocks();

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
POST /=/model/Carrie/*/*.js
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
POST /=/model/Carrie/*/*.js
{ title:'second',url:"http://zhangxiaojue.cn"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 7: find out two record assign to var hello
--- request
GET /=/model/Carrie/*/*.js?var=hello
--- response
var hello=[{"url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},{"url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 8: delete a record use "post" (incorrect way)
--- request
POST /=/delete/model/Carrie/id/1.js
--- response
{"success":1,"rows_affected":1}


=== TEST 9: delete a record in correct way
--- request
GET /=/delete/model/Carrie/id/2.js
--- response
{"success":1,"rows-affected":1}
