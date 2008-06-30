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



=== TEST 2: Delete existing actions
--- request
DELETE /=/action
--- response
{"success":1,"warning":"Builtin actions are skipped."}



=== TEST 3: Create a model
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



=== TEST 4: insert a record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"hello carrie","url":"http://www.carriezh.cn/","num":"10"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/1"}



=== TEST 5: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"second","url":"http://zhangxiaojue.cn","num":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 6: create an action
--- request
POST /=/action/Query
{"definition":
"select * from Carrie where title = 'hello carrie' and num=10; select * from Carrie where title = 'hello carrie' and num=10;"}
--- response
{"success":1}



=== TEST 7: Invoke the action
--- request
GET /=/action/Query/~/~
--- response
[
    [{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}],
    [{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]
]



=== TEST 8: Update the def to introduce vars
--- request
PUT /=/action/Query
{
    "parameters":[{"name":"num","type":"literal"}],
    "definition": "select title from Carrie where num = $num; select url from Carrie where num = $num"}
--- response
{"success":1}



=== TEST 9: Invoke the action
--- request
GET /=/action/Query/num/10
--- response
[
    [{"title":"hello carrie"}],
    [{"url":"http://www.carriezh.cn"}]
]



=== TEST 10: Invoke the action
--- request
GET /=/action/Query/num/1
--- response
[
    [{"title":"second"}],
    [{"url":"http://zhangziaojue.cn"}]
]



=== TEST 11: logout
--- request
GET /=/logout
--- response
{"success":1}

