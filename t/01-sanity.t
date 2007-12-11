use t::OpenAPI;

plan tests => 3 * blocks();

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
POST /=/model/Bookmark.js
{
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
{
  "columns":
   [
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","label":"标题","type":"text"},
    {"name":"url","label":"网址","type":"text"}
   ],
  "name":"Bookmark",
  "description":"我的书签"
}



=== TEST 6: access inexistent models
--- request
GET /=/model/Foo.js
--- response
{"success":0,"error":"Model \"Foo\" not found."}



=== TEST 7: insert a single record
--- request
POST /=/model/Bookmark/~/~
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/1"}



=== TEST 8: insert another record
--- request
POST /=/model/Bookmark/~/~.js
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/2"}



=== TEST 9: insert multiple records at a time
--- request
POST /=/model/Bookmark/~/~.js
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
GET /=/model/Bookmark/url/~.js
--- response
[
    {"url":"http://www.yahoo.cn"},
    {"url":"http://www.yahoo.cn"},
    {"url":"http://www.google.cn"},
    {"url":"http://www.baidu.com"},
    {"url":"http://www.perl.com"}
]



=== TEST 13: select records
--- request
GET /=/model/Bookmark/url/http://www.yahoo.cn.js
--- response
[
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"}
]



=== TEST 14: read all records
--- request
GET /=/model/Bookmark/~/~.js
--- response
[
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"},
    {"url":"http://www.google.cn","title":"Google搜索","id":"3"},
    {"url":"http://www.baidu.com","title":null,"id":"4"},
    {"url":"http://www.perl.com","title":"Perl.com","id":"5"}
]



=== TEST 15: delete a record
--- request
DELETE /=/model/Bookmark/id/2.js
--- response
{"success":1,"rows_affected":1}



=== TEST 16: check the record just deleted
--- request
GET /=/model/Bookmark/id/2.js
--- response
[]



=== TEST 17: update a nonexistent record
--- request
PUT /=/model/Bookmark/id/2.js
{ title: "Blah blah blah" }
--- response
{"success":0,"rows_affected":0}



=== TEST 18: update an existent record
--- request
PUT /=/model/Bookmark/id/3.js
{ title: "Blah blah blah" }
--- response
{"success":1,"rows_affected":1}



=== TEST 19: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js
--- response
[{"url":"http://www.google.cn","title":"Blah blah blah","id":"3"}]



=== TEST 20: update an existent record using POST
--- request
POST /=/put/model/Bookmark/id/3.js
{ title: "Howdy!" }
--- response
{"success":1,"rows_affected":1}



=== TEST 21: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js
--- response
[{"url":"http://www.google.cn","title":"Howdy!","id":"3"}]



=== TEST 22: Change the name of the model
--- request
PUT /=/model/Bookmark.js
{ name: "MyFavorites", description: "我的最爱" }
--- response
{"success":1}



=== TEST 23: Check the new model
--- request
GET /=/model/MyFavorites.js
--- response
{
  "columns":
   [
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","label":"标题","type":"text"},
    {"name":"url","label":"网址","type":"text"}
   ],
  "name":"MyFavorites",
  "description":"我的最爱"
}



=== TEST 24: Change the name and type of title
--- request
PUT /=/model/MyFavorites/title
{ name: "count", type: "integer" }
--- response
{"success":0,"error":"column \"count\" cannot be cast to type \"pg_catalog.int4\""}



=== TEST 25: Get model list
--- request
GET /=/model.js
--- response
[{"src":"/=/model/MyFavorites","name":"MyFavorites","description":"我的最爱"}]

