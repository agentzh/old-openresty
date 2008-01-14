# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login w/o password
--- request
GET /=/login/peee.Admin
--- response
{"success":0,"error":"Password for peee.Admin is required."}



=== TEST 2: Delete existing models (w/o login)
--- request
DELETE /=/model.js
--- response
{"success":0,"error":"Login required."}



=== TEST 3: Login with password
--- request
GET /=/login/peee.Admin/4423037
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 4: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 5: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 6: Create a model
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



=== TEST 7: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Bookmark","name":"Bookmark","description":"我的书签"}]



=== TEST 8: check the column
--- request
GET /=/model/Bookmark.js
--- response
{
  "columns":
   [
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":null,"label":"标题","type":"text"},
    {"name":"url","default":null,"label":"网址","type":"text"}
   ],
  "name":"Bookmark",
  "description":"我的书签"
}



=== TEST 9: access inexistent models
--- request
GET /=/model/Foo.js
--- response
{"success":0,"error":"Model \"Foo\" not found."}



=== TEST 10: insert a single record
--- request
POST /=/model/Bookmark/~/~
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/1"}



=== TEST 11: insert another record
--- request
POST /=/model/Bookmark/~/~.js
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/2"}



=== TEST 12: insert multiple records at a time
--- request
POST /=/model/Bookmark/~/~.js
[
    { title: "Google搜索", url: "http://www.google.cn" },
    { url: "http://www.baidu.com" },
    { title: "Perl.com", url: "http://www.perl.com" }
]
--- response
{"success":1,"rows_affected":3,"last_row":"/=/model/Bookmark/id/5"}



=== TEST 13: read a record
--- request
GET /=/model/Bookmark/id/1.js
--- response
[{"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"}]



=== TEST 14: read another record
--- request
GET /=/model/Bookmark/id/5.js
--- response
[{"url":"http://www.perl.com","title":"Perl.com","id":"5"}]



=== TEST 15: read urls of all the records
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



=== TEST 16: select records
--- request
GET /=/model/Bookmark/url/http://www.yahoo.cn.js
--- response
[
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"}
]



=== TEST 17: read all records
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



=== TEST 18: delete a record
--- request
DELETE /=/model/Bookmark/id/2.js
--- response
{"success":1,"rows_affected":1}



=== TEST 19: check the record just deleted
--- request
GET /=/model/Bookmark/id/2.js
--- response
[]



=== TEST 20: update a nonexistent record
--- request
PUT /=/model/Bookmark/id/2.js
{ title: "Blah blah blah" }
--- response
{"success":0,"rows_affected":0}



=== TEST 21: update an existent record
--- request
PUT /=/model/Bookmark/id/3.js
{ title: "Blah blah blah" }
--- response
{"success":1,"rows_affected":1}



=== TEST 22: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js
--- response
[{"url":"http://www.google.cn","title":"Blah blah blah","id":"3"}]



=== TEST 23: update an existent record using POST
--- request
POST /=/put/model/Bookmark/id/3.js
{ title: "Howdy!" }
--- response
{"success":1,"rows_affected":1}



=== TEST 24: Check the last response
--- request
GET /=/last/response
--- response
{"success":1,"rows_affected":1}



=== TEST 25: Check the last response again
--- request
GET /=/last/response
--- response
{"success":1,"rows_affected":1}



=== TEST 26: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js
--- response
[{"url":"http://www.google.cn","title":"Howdy!","id":"3"}]



=== TEST 27: Check the last response again (GET has no effect)
--- request
GET /=/last/response
--- response
{"success":1,"rows_affected":1}



=== TEST 28: Change the name of the model
--- request
PUT /=/model/Bookmark.js
{ name: "MyFavorites", description: "我的最爱" }
--- response
{"success":1}



=== TEST 29: Check the last response again (PUT has effect)
--- request
GET /=/last/response
--- response
{"success":1}



=== TEST 30: Check the new model
--- request
GET /=/model/MyFavorites.js
--- response
{
  "columns":
   [
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":null,"label":"标题","type":"text"},
    {"name":"url","default":null,"label":"网址","type":"text"}
   ],
  "name":"MyFavorites",
  "description":"我的最爱"
}



=== TEST 31: Change the name and type of title
--- request
PUT /=/model/MyFavorites/title
{ name: "count", type: "text" }
--- response
{"success":1}



=== TEST 32: Get model list
--- request
GET /=/model.js
--- response
[{"src":"/=/model/MyFavorites","name":"MyFavorites","description":"我的最爱"}]

