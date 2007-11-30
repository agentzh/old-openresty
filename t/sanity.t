use t::OpenAPI;

plan tests => 2 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 3: Create a model
--- request
POST /=/model.js
{
    name: "Bookmark",
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":1,"warning":"Column \"id\" reserved. Ignored."}



=== TEST 4: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Bookmark","name":"Bookmark","description":"我的书签"}]



=== TEST 5: check the column
--- request
GET /=/model/Bookmark.js
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","label":"标题","type":"text"},
    {"name":"url","label":"网址","type":"text"}
]



=== TEST 6: access inexistent models
--- request
GET /=/model/Foo.js
--- response
{"success":0,"error":"Model \"Foo\" not found."}



=== TEST 7: insert a single record
--- request
POST /=/model/Bookmark.js
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/1"}



=== TEST 8: insert another record
--- request
POST /=/model/Bookmark.js
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/2"}



=== TEST 9: insert multiple records at a time
--- request
POST /=/model/Bookmark.js
[
    { title: "Google搜索", url: "http://www.google.cn" },
    { url: "http://www.baidu.com" },
    { title: "Perl.com", url: "http://www.perl.com" }
]
--- response
{"success":1,"rows_affected":3,"last_row":"/=/model/Bookmark/id/5"}



=== TEST 10: read a record
--- request
GET /=/model/Bookmark/id/1.js
--- response
[{"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"}]



=== TEST 11: read another record
--- request
GET /=/model/Bookmark/id/5.js
--- response
[{"url":"http://www.perl.com","title":"Perl.com","id":"5"}]



=== TEST 12: read urls of all the records
--- request
GET /=/model/Bookmark/url.js
--- response
[
    {"url":"http://www.baidu.com"},
    {"url":"http://www.google.cn"},
    {"url":"http://www.perl.com"},
    {"url":"http://www.yahoo.cn"}
]



=== TEST 13: select records
--- request
GET /=/model/Bookmark/url/http://www.yahoo.cn.js
--- response
[
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"}
]

