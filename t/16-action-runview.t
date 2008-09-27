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



=== TEST 8: The .Select action is now disallowed
--- request
POST /=/action/.Select/lang/minisql
"select * from Carrie where title = 'hello carrie' and num=10;"
--- response
{"error":"Action \".Select\" not found.","success":0}



=== TEST 9: use minisql to find record
--- request
POST /=/action/RunView/~/~
"select * from Carrie where title = 'hello carrie' and num=10;"
--- response
[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]



=== TEST 10: use minisql through GET & .Select
--- request
GET /=/post/action/RunView/~/~?_var=foo&_data="select * from Carrie where url = 'http://www.carriezh.cn/' and num=10"
--- response
foo=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}];



=== TEST 11: test for offset & count
--- request
GET /=/post/action/RunView/~/~?_var=foo&_data="select * from Carrie offset 0 limit 1"
--- response
foo=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}];



=== TEST 12: OFFSET & limit in minisql
--- request
GET /=/post/action/RunView/~/~?_var=foo&_data="select * from Carrie limit 1 offset 0"
--- response
foo=[{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}];



=== TEST 13: OFFSET & limit in minisql
--- request
POST /=/action/RunView/~/~?_var=foo
"select * from Carrie limit 1 offset 1"
--- response
foo=[{"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}];



=== TEST 14: Try to reference meta models
--- request
POST /=/action/RunView/~/~?_var=foo
"select * from _models limit 1 offset 1"
--- response
foo={"error":"\"view\" (line 1, column 15):\nunexpected \"_\"\nexpecting space or model","success":0};



=== TEST 15: Reference nonexistent models
--- request
POST /=/action/RunView/~/~
"select * from BlahBlah limit 1 offset 1"
--- response
{"success":0,"error":"Model \"BlahBlah\" not found."}



=== TEST 16: Empty miniSQL string
--- request
POST /=/action/RunView/~/~
""
--- response
{"error":"Restyscript source must be an non-empty literal string: \"\"","success":0}



=== TEST 17: Empty miniSQL string
--- request
POST /=/action/RunView/~/~
["abc"]
--- response
{"error":"Restyscript source must be an non-empty literal string: [\"abc\"]","success":0}



=== TEST 18: logout
--- request
GET /=/logout
--- response
{"success":1}

