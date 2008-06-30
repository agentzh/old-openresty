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



=== TEST 11: Reference nonexistent models
--- request
PUT /=/action/Query
{ "definition":
"select * from BlahBlah limit 1 offset 1"}
--- response
{"success":0,"error":"Model \"BlahBlah\" not found."}



=== TEST 12: Try to reference meta models
--- request
PUT /=/action/Query
{ "definition":
"select * from _models limit 1 offset 1"}
--- response
{"error":"\"action\" (line 1, column 15):\nunexpected \"_\"\nexpecting space or model","success":0};



=== TEST 13: Empty restyscript string
--- request
PUT /=/action/RunAction/~/~
{"definition":""}
--- response
{"error":"Restyscript source must be an non-empty literal string: \"\"","success":0}



=== TEST 14: GET rows
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 15: Update some rows
--- request
PUT /=/action/Query
{
  "definition":
    "update Carrie set num=$num where num=10 or num=1",
"parameters":
    [{"name":"num","type":"literal","default":"5"}]
}
--- response
{"success":1}



=== TEST 16: Invoke the new Query action
--- request
GET /=/action/Query/~/~
--- response
[{"success":1,"rows_affected":2}]



=== TEST 17: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"5","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"5","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 18: run the action again
--- request
GET /=/action/Query/~/~
--- response
[{"success":1,"rows_affected":0}]



=== TEST 19: run the action again (with argument)
--- request
GET /=/action/Query/num/7
--- response
[{"success":1,"rows_affected":0}]



=== TEST 20: Do two updates
--- request
PUT /=/action/Query
{"definition":
    "update $model set num=7 where id=1; update $model set num=8 where id=2",
    "parameters":[{"name":"model","type":"symbol"}]}
--- response
{"success":1}



=== TEST 21: Run the action w/o arguments
--- request
GET /=/action/Query/~/~
--- response
{"success":0,"error":"Arguments required: model"}



=== TEST 22: Run the action with arguments
--- request
POST /=/action/Query/~/~
{"model":"Blah"}
--- response
{"success":0,"error":"Model \"Blah\" not found."}



=== TEST 23: Run the action with invalid arguments
--- request
POST /=/action/Query/~/~
{"model":"@#@@$^^#@"}
--- response
{"success":0,"error":"Invalid symbol for parameter \"model\": "@#@@$^^#@"}



=== TEST 24: Run the action in the right way
--- request
POST /=/action/Query/~/~
{"model":"Carrie"}
--- response
[{"rows_affected":1,"success":1},{"rows_affected":1,"success":1}]



=== TEST 25: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"7","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 26: Delete rows
--- request
PUT /=/action/Query
{"definition":"delete from Carrie\n where num = $num;;",
    "parameters":[{"name":"num","type":"literal"}]
}
--- response
{"success":1}



=== TEST 27: Invoke the action
--- request
GET /=/action/Query/num/7
--- response
[{"success":1,"rows_affected":1}]




=== TEST 28: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[{"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]



=== TEST 29: Insert some more data via actions
--- request
PUT /=/action/Query
{"definition":
"POST '/=/model/Carrie' || '/~/~' [{num: 5, url: 'yahoo.cn', title: $Yahoo}, {'num': 6, url: 'google' || '.com', \"title\": $Google}]",
    "parameters": [
        {"name":"Yahoo","type":"literal"},
        {"name":"Google","type":"literal"}
    ]
}
--- response
{"success":1}


=== TEST 30: Invoke it
--- request
GET /=/action/Query/Yahoo/Yahoo?Google=Google
--- response
[{"success":1,"rows_affected":2,"last_row":"/=/model/Carrie/id/4"}]

--- LAST


=== TEST 30: three GET in an action
[{"success":1,"rows_affected":2,"last_row":"/=/model/Carrie/id/4"}]
--- request
POST /=/action/RunAction/~/~
"GET '/=/model/Carrie' || '/id/4';
GET '/=/model/Carrie/id/3';
GET '/=/model/Carrie/id/2';"
--- response
[
    [{"num":"6","url":"google.com","title":"Google","id":"4"}],
    [{"num":"5","url":"yahoo.cn","title":"Yahoo","id":"3"}],
    [{"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]
]



=== TEST 31: three GET in an action
--- request
POST /=/action/RunAction/~/~
"GET '/=/model/Carrie' || '/id/4';
GET '/=/blah/blah';
GET '/=/model';"
--- response
[
    [{"id":"4","num":"6","title":"Google","url":"google.com"}],
    {"error":"Unknown URL catagory: blah","success":0},
    [{"description":"我的书签","name":"Carrie","src":"/=/model/Carrie"}]
]



=== TEST 32: delete mixed in 2 GET
--- request
POST /=/action/RunAction/~/~
"DELETE '/=/model/Carrie' || '/id/4';
GET ('/=/model/Carrie/~/~') ; delete from Carrie where id = 3
;GET '/=/' || ('model/' || 'Carrie/~/~')
"
--- response
[
    {"rows_affected":1,"success":1},
    [
        {"id":"2","num":"8","title":"second","url":"http://zhangxiaojue.cn"},
        {"id":"3","num":"5","title":"Yahoo","url":"yahoo.cn"}
    ],
    {"rows_affected":1,"success":1},
    [{"id":"2","num":"8","title":"second","url":"http://zhangxiaojue.cn"}]
]



=== TEST 33: access another account
--- request
POST /=/action/RunAction/~/~
"DELETE '/=/model?user=$TestAccount2&password=$TestPass2';
POST '/=/model/Another' {\"description\":\"a model in another account\"};
GET '/=/model';
GET '/=/model?user=$TestAccount2&password=$TestPass2'"
--- response
[
    {"success":1},
    {"success":1,"warning":"No 'columns' specified for model \"Another\"."},
    [
      {"description":"我的书签","name":"Carrie","src":"/=/model/Carrie"},
      {"description":"a model in another account","name":"Another","src":"/=/model/Another"}
    ],
    []
]



=== TEST 34: check Test account 2:
--- request
GET /=/model?user=$TestAccount2&password=$TestPass2
--- response
[]



=== TEST 35: recheck Test account 1:
--- request
GET /=/model?user=$TestAccount&password=$TestPass
--- response
[
    {"src":"/=/model/Carrie","name":"Carrie","description":"我的书签"},
    {"src":"/=/model/Another","name":"Another","description":"a model in another account"}
]



=== TEST 36: logout
--- request
GET /=/logout
--- response
{"success":1}

