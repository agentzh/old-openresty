# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Carrie.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" },
        { "name": "num", "type": "integer", "label": "num" }
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
{ "title":"hello carrie","url":"http://www.carriezh.cn/","num":"10"}
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
{ "title":"second","url":"http://zhangxiaojue.cn","num":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 7: find out two record assign to var hello
--- request
GET /=/model/Carrie/~/~.js?var=hello
--- response
hello=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 8: use minisql to find record
--- request
POST /=/action/RunAction/~/~
"select * from Carrie where title = 'hello carrie' and num=10;
select * from Carrie where title = 'hello carrie' and num=10;"
--- response
[
    [{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}],
    [{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]
]



=== TEST 9: use minisql through GET & .Select
--- request
GET /=/post/action/RunAction/~/~?var=foo&data="select * from Carrie where url = 'http://www.carriezh.cn/' and num=10"
--- response
foo=[[{"id":"1","num":"10","title":"hello carrie","url":"http://www.carriezh.cn/"}]];



=== TEST 10: test for offset & count
--- request
GET /=/post/action/RunAction/~/~?var=foo&data="select * from Carrie offset 0 limit 1"
--- response
foo=[[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]];



=== TEST 11: OFFSET & limit in minisql
--- request
GET /=/post/action/RunAction/~/~?var=foo&data="select * from Carrie limit 1 offset 0"
--- response
foo=[[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]];



=== TEST 12: OFFSET & limit in minisql
--- request
POST /=/action/RunAction/~/~?var=foo
"select * from Carrie limit 1 offset 1"
--- response
foo=[[{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]];



=== TEST 13: Try to reference meta models
--- request
POST /=/action/RunAction/~/~?var=foo
"select * from _models limit 1 offset 1"
--- response
foo={"error":"\"action\" (line 1, column 15):\nunexpected \"_\"\nexpecting space or model","success":0};



=== TEST 14: Reference nonexistent models
--- request
POST /=/action/RunAction/~/~
"select * from BlahBlah limit 1 offset 1"
--- response
{"success":0,"error":"Model \"BlahBlah\" not found."}



=== TEST 15: Empty miniSQL string
--- request
POST /=/action/RunAction/~/~
""
--- response
{"error":"Restyscript source must be an non-empty literal string: \"\"","success":0}



=== TEST 16: Invalid POST content
--- request
POST /=/action/RunAction/~/~
["abc"]
--- response
{"error":"Restyscript source must be an non-empty literal string: [\"abc\"]","success":0}



=== TEST 17: GET rows
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 18: Update some rows
--- request
POST /=/action/RunAction/~/~
"update Carrie set num=5 where num=10 or num=1"
--- response
[{"success":1,"rows_affected":2}]



=== TEST 19: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"5","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"5","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 20: run the action again
--- request
POST /=/action/RunAction/~/~
"update Carrie set num=5 where num=10 or num=1"
--- response
[{"success":1,"rows_affected":0}]



=== TEST 21: Do two updates
--- request
POST /=/action/RunAction/~/~
"update Carrie set num=7 where id=1;
update Carrie set num=8 where id=2"
--- response
[{"rows_affected":1,"success":1},{"rows_affected":1,"success":1}]



=== TEST 22: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"7","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 23: Delete rows
--- request
POST /=/action/RunAction/~/~
"delete from Carrie\n where num = 7;;"
--- response
[{"success":1,"rows_affected":1}]



=== TEST 24: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[{"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]

