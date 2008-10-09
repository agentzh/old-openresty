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

=== TEST 6: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"Num 0","url":"http://zhan.cn.yahoo.com","num":"0"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/3"}



=== TEST 7: Update the def to introduce vars
--- request
PUT /=/action/Query
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
    [{"url":"http://www.carriezh.cn"}]
]



=== TEST 9: Invoke the action
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
PUT /=/action/VarQuery
{
    "parameters":[{"name":"p","type":"literal"}],
    "definition": "select * from Carrie where url = '﻿http://zhan.cn.yahoo.com?p=' || $p"}
--- response
{"success":1}

=== TEST 13: Invoke the action
--- request
GET /=/action/VarQuery/p/0
--- response
[
    {"title":"url var","url":"http://zhan.cn.yahoo.com?p=0","num":"0","id":4}
]



=== TEST 14: insert another record with url var
--- request
POST /=/model/Carrie/~/~.js
{ "title":"中文","url":"http://zhan.cn.yahoo.com","num":"0"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/6"}


=== TEST 15: Update the definition
--- request
PUT /=/action/CNQuery
 "parameters":[{"name":"title","type":"literal"}],
{ "definition": "select * from Carrie where title=$title"}
--- response
{"success":1}

=== TEST 16: Invoke the action
--- request
GET /=/action/CNQuery/title/中文
--- response
[
   {"title":"中文","url":"http://zhan.cn.yahoo.com","num":"0","id":"6"}
]



=== TEST 17: logout
--- request
GET /=/logout
--- response
{"success":1}

