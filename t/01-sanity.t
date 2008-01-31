# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks() - 3 * 2;

run_tests;

__DATA__

=== TEST 1: Login w/o password
--- request
GET /=/login/$TestAccount.Admin
--- response
{"success":0,"error":"Password for $TestAccount.Admin is required."}



=== TEST 2: Delete existing models (w/o login)
--- request
DELETE /=/model.js
--- response
{"success":0,"error":"Login required."}



=== TEST 3: Login with password but w/o cookie
--- request
GET /=/login/$TestAccount.Admin/$TestPass
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 4: Delete existing models (wrong way)
--- request
DELETE /=/model.js
--- response
{"success":0,"error":"Login required."}


=== TEST 5: Login with password and cookie
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 6: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 7: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 8: Create a model
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



=== TEST 9: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Bookmark","name":"Bookmark","description":"我的书签"}]



=== TEST 10: check the column
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



=== TEST 11: access inexistent models
--- request
GET /=/model/Foo.js
--- response
{"success":0,"error":"Model \"Foo\" not found."}



=== TEST 12: insert a single record
--- request
POST /=/model/Bookmark/~/~
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/1"}



=== TEST 13: insert another record
--- request
POST /=/model/Bookmark/~/~.js
{ title: "Yahoo Search", url: "http://www.yahoo.cn" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/2"}



=== TEST 14: insert multiple records at a time
--- request
POST /=/model/Bookmark/~/~.js
[
    { title: "Google搜索", url: "http://www.google.cn" },
    { url: "http://www.baidu.com" },
    { title: "Perl.com", url: "http://www.perl.com" }
]
--- response
{"success":1,"rows_affected":3,"last_row":"/=/model/Bookmark/id/5"}



=== TEST 15: read a record
--- request
GET /=/model/Bookmark/id/1.js
--- response
[{"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"}]



=== TEST 16: read another record
--- request
GET /=/model/Bookmark/id/5.js
--- response
[{"url":"http://www.perl.com","title":"Perl.com","id":"5"}]



=== TEST 17: read urls of all the records
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



=== TEST 18: select records
--- request
GET /=/model/Bookmark/url/http://www.yahoo.cn.js
--- response
[
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"}
]



=== TEST 19: read all records
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



=== TEST 20: delete a record
--- request
DELETE /=/model/Bookmark/id/2.js
--- response
{"success":1,"rows_affected":1}



=== TEST 21: check the record just deleted
--- request
GET /=/model/Bookmark/id/2.js
--- response
[]



=== TEST 22: update a nonexistent record
--- request
PUT /=/model/Bookmark/id/2.js
{ title: "Blah blah blah" }
--- response
{"success":0,"rows_affected":0}



=== TEST 23: update an existent record
--- request
PUT /=/model/Bookmark/id/3.js
{ title: "Blah blah blah" }
--- response
{"success":1,"rows_affected":1}



=== TEST 24: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js
--- response
[{"url":"http://www.google.cn","title":"Blah blah blah","id":"3"}]



=== TEST 25: update an existent record using POST
--- request
POST /=/put/model/Bookmark/id/3.js
{ title: "Howdy!" }
--- response
{"success":1,"rows_affected":1}



=== TEST 26: Check the last response
--- request
GET /=/last/response
--- response
{"success":1,"rows_affected":1}



=== TEST 27: Check the last response (with callback)
--- request
GET /=/last/response?callback=foo
--- response
foo({"success":1,"rows_affected":1});



=== TEST 28: Check the last response again
--- request
GET /=/last/response
--- response
{"success":1,"rows_affected":1}



=== TEST 29: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js
--- response
[{"url":"http://www.google.cn","title":"Howdy!","id":"3"}]



=== TEST 30: Check the last response again (GET has no effect)
--- request
GET /=/last/response
--- response
{"success":1,"rows_affected":1}



=== TEST 31: Change the name of the model
--- request
PUT /=/model/Bookmark.js
{ name: "MyFavorites", description: "我的最爱" }
--- response
{"success":1}



=== TEST 32: Check the last response again (PUT has effect)
--- request
GET /=/last/response
--- response
{"success":1}



=== TEST 33: Check the new model
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



=== TEST 34: Change the name and type of title
--- request
PUT /=/model/MyFavorites/title
{ name: "count", type: "text" }
--- response
{"success":1}



=== TEST 35: Get model list
--- request
GET /=/model.js
--- response
[{"src":"/=/model/MyFavorites","name":"MyFavorites","description":"我的最爱"}]



=== TEST 36: Check the new column
--- request
GET /=/model/MyFavorites/count
--- response
{"name":"count","default":null,"label":"标题","type":"text"}



=== TEST 37: Change the name and type of title to incompactible types
--- debug: 1
--- request
PUT /=/model/MyFavorites/count
{ name: "count", type: "real" }
--- response_like
^{"success":0,"error":"DBD::Pg::db (?:do|selectall_arrayref) failed:.*



=== TEST 38: Change the name and type of title to incompactible types
--- debug: 0
--- request
PUT /=/model/MyFavorites/count
{ name: "count", type: "real" }
--- response
{"success":0,"error":"Operation failed."}



=== TEST 39: Change the name and type of title to incompactible types
--- debug: 1
--- request
PUT /=/model/MyFavorites/count
{ type: "real" }
--- response_like
^{"success":0,"error":"DBD::Pg::db (?:do|selectall_arrayref) failed:.*



=== TEST 40: Change the name and type of title to incompactible types
--- debug: 0
--- request
PUT /=/model/MyFavorites/count
{ type: "real" }
--- response
{"success":0,"error":"Operation failed."}

