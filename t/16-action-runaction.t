# vi:filetype=

my $ExePath;
BEGIN {
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found.\n";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable.\n";
        return;
    }
};
use t::OpenResty $skip ? (skip_all => $skip) : ();

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Carrie.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "type":"text", "label": "标题" },
        { "name": "url", "type":"text", "label": "网址" },
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
GET /=/model/Carrie/~/~.js?_var=hello
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



=== TEST 9: use minisql through GET & RunAction
--- request
GET /=/post/action/RunAction/~/~?_var=foo&_data="select * from Carrie where url = 'http://www.carriezh.cn/' and num=10"
--- response
foo=[[{"id":"1","num":"10","title":"hello carrie","url":"http://www.carriezh.cn/"}]];



=== TEST 10: test for offset & count
--- request
GET /=/post/action/RunAction/~/~?_var=foo&_data="select * from Carrie offset 0 limit 1"
--- response
foo=[[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]];



=== TEST 11: OFFSET & limit in minisql
--- request
GET /=/post/action/RunAction/~/~?_var=foo&_data="select * from Carrie limit 1 offset 0"
--- response
foo=[[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]];



=== TEST 12: OFFSET & limit in minisql
--- request
POST /=/action/RunAction/~/~?_var=foo
"select * from Carrie limit 1 offset 1"
--- response
foo=[[{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]];



=== TEST 13: Try to reference meta models
--- request
POST /=/action/RunAction/~/~?_var=foo
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



=== TEST 25: Insert some more data via actions
--- request
POST /=/action/RunAction/~/~
"POST '/=/model/Carrie' || '/~/~'
[{num: 5, url: 'yahoo.cn', title: 'Yahoo'},
{'num': 6, url: 'google' || '.com', \"title\": 'Google'}]"
--- response
[{"success":1,"rows_affected":2,"last_row":"/=/model/Carrie/id/4"}]



=== TEST 26: three GET in an action
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



=== TEST 27: three GET in an action
--- request
POST /=/action/RunAction/~/~
"GET '/=/model/Carrie' || '/id/4';
GET '/=/blah/blah';
GET '/=/model';"
--- response
[
    [{"id":"4","num":"6","title":"Google","url":"google.com"}],
    {"error":"Handler for the \"blah\" category not found.","success":0},
    [{"description":"我的书签","name":"Carrie","src":"/=/model/Carrie"}]
]



=== TEST 28: delete mixed in 2 GET
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



=== TEST 29: access another account
--- request
POST /=/action/RunAction/~/~
"DELETE '/=/model?_user=$TestAccount2&_password=$TestPass2';
POST '/=/model/Another' {\"description\":\"a model in another account\"};
GET '/=/model';
GET '/=/model?_user=$TestAccount2&_password=$TestPass2'"
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
--- LAST


=== TEST 30: check Test account 2:
--- request
GET /=/model?_user=$TestAccount2&_password=$TestPass2
--- response
[]



=== TEST 31: recheck Test account 1:
--- request
GET /=/model?_user=$TestAccount&_password=$TestPass
--- response
[
    {"src":"/=/model/Carrie","name":"Carrie","description":"我的书签"},
    {"src":"/=/model/Another","name":"Another","description":"a model in another account"}
]



=== TEST 32: logout
--- request
GET /=/logout
--- response
{"success":1}

