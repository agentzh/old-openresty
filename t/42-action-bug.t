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



=== TEST 2: Delete existing actions
--- request
DELETE /=/action
--- response
{"success":1,"warning":"Builtin actions were skipped."}



=== TEST 3: Create a model
--- request
POST /=/model/Carrie.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "type":"text","label": "标题" },
        { "name": "url","type":"text", "label": "网址" },
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



=== TEST 6: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"Num 0","url":"http://zhan.cn.yahoo.com","num":"0"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/3"}



=== TEST 7: Update the def to introduce vars
--- request
POST /=/action/Query
{
    "parameters":[{"name":"num","type":"literal"}],
    "definition": "select title from Carrie where num = $num; select url from Carrie where num = $num"}
--- response
{"success":1}



=== TEST 8: Invoke the action
--- request
GET /=/action/Query/num/10
--- response
[
    [{"title":"hello carrie"}],
    [{"url":"http://www.carriezh.cn/"}]
]



=== TEST 9: Invoke the action with a 0 param value
--- request
GET /=/action/Query/num/0
--- response
[
    [{"title":"Num 0"}],
    [{"url":"http://zhan.cn.yahoo.com"}]
]



=== TEST 10: insert another record with url var
--- request
POST /=/model/Carrie/~/~.js
{ "title":"url var","url":"http://zhan.cn.yahoo.com?p=0","num":"0"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/4"}



=== TEST 11: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"url var","url":"http://zhan.cn.yahoo.com?p=1","num":"0"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/5"}



=== TEST 12: def action with var
--- request
POST /=/action/VarQuery
{
    "parameters":[{"name":"p","type":"literal"}],
    "definition": "select * from Carrie where url = 'http://zhan.cn.yahoo.com?p=' || $p"}
--- response
{"success":1}



=== TEST 13: Invoke the action using a 0 param value
--- request
GET /=/action/VarQuery/p/0
--- response
[[{"id":"4","num":"0","title":"url var","url":"http://zhan.cn.yahoo.com?p=0"}]]



=== TEST 14: insert another record with url var
--- request
POST /=/model/Carrie/~/~.js
{ "title":"中文","url":"http://zhan.cn.yahoo.com","num":"0"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/6"}



=== TEST 15: def action with paraments in Chinese
--- request
POST /=/action/CNQuery
{
 "parameters":[{"name":"title","type":"literal"}],
 "definition": "select * from Carrie where title=$title"}
--- response
{"success":1}



=== TEST 16: Invoke the action
--- request
GET /=/action/CNQuery/title/中文
--- response
[
   [{"title":"中文","url":"http://zhan.cn.yahoo.com","num":"0","id":"6"}]
]



=== TEST 17: define a recursive action
--- request
PUT /=/action/CNQuery
{
 "definition": "POST '/=/action/CNQuery/~/~' { title: $title }" }
--- response
{"success":1}



=== TEST 18: Call this action recursively
--- request
GET /=/action/CNQuery/title/英文
--- response
[[[{"success":0,"error":"Action calling chain is too deep. (The limit is 3.)"}]]]



=== TEST 19: define an action that does POST model rows
--- request
PUT /=/action/CNQuery
{
 "definition": "POST '/=/model/Carrie/~/~' { title: $title }" }
--- response
{"success":1}



=== TEST 20: Call this action with Chinese chars
--- request
GET /=/action/CNQuery/title/英文
--- response
[{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/7"}]



=== TEST 21: Check the rows to see if the chars got right
--- request
GET /=/model/Carrie/title/英文
--- response
[{"num":null,"url":null,"title":"英文","id":"7"}]



=== TEST 22: logout
--- request
GET /=/logout
--- response
{"success":1}

