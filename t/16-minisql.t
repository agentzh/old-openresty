# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=peee&password=4423037
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Carrie.js
{
    description: "我的书签",
    columns: [
        { name: "title", label: "标题" },
        { name: "url", label: "网址" },
        { name: "num", type: "integer", label: "num" }
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
{ title:'hello carrie',url:"http://www.carriezh.cn/",num:"10"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/1"}



=== TEST 5: read a record according to url
--- request
GET /=/model/Carrie/url/http://www.carriezh.cn/.js
--- response
[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]



=== TEST 6: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ title:'second',url:"http://zhangxiaojue.cn",num:"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 7: find out two record assign to var hello
--- request
GET /=/model/Carrie/~/~.js?var=hello
--- response
var hello=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 8: use minisql to find record
--- request
POST /=/action/.Select/lang/minisql
"select * from Carrie where title = 'hello carrie' and num=10;"
--- response
[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]



=== TEST 9: use minisql through GET & .Select
--- request
GET /=/post/action/.Select/lang/minisql?var=foo&data="select * from Carrie where url = 'http://www.carriezh.cn/' and num=10"
--- response
var foo=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}];



=== TEST 10: test for offset & count
--- request
GET /=/post/action/.Select/lang/minisql?var=foo&offset=0&count=1&data="select * from Carrie"
--- response
var foo=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}];



=== TEST 11: OFFSET & limit in minisql
--- request
GET /=/post/action/.Select/lang/minisql?var=foo&data="select * from Carrie limit 1 offset 0"
--- response
var foo=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}];



=== TEST 12: OFFSET & limit in minisql
--- request
POST /=/action/.Select/lang/minisql?var=foo
"select * from Carrie limit 1 offset 1"
--- response
var foo=[{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 13: Try to reference meta models
--- request
POST /=/action/.Select/lang/minisql?var=foo
"select * from _models limit 1 offset 1"
--- response
var foo={"success":0,"error":"line 1: error: Unexpected input: \"_\" (VAR or IDENT expected)."};



=== TEST 14: Reference nonexistent models
--- request
POST /=/action/.Select/lang/minisql
"select * from BlahBlah limit 1 offset 1"
--- response
{"success":0,"error":"Model \"BlahBlah\" not found."}



=== TEST 15: Empty miniSQL string
--- request
POST /=/action/.Select/lang/minisql
""
--- response
{"success":0,"error":"miniSQL must be an non-empty literal string: \"\""}

