# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login w/o password
--- request
GET /=/login/$TestAccount.Admin?callback=foo
--- response
foo({"success":0,"error":"$TestAccount.Admin is not anonymous."});



=== TEST 2: Delete existing models (w/o login)
--- request
DELETE /=/model.js?callback=foo
--- response
foo({"success":0,"error":"Login required."});



=== TEST 3: Login with password
--- request
GET /=/login/$TestAccount.Admin/$TestPass?callback=foo&use_cookie=1
--- response_like
^foo\({"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}\);$



=== TEST 4: Delete existing models
--- request
DELETE /=/model.js?callback=foo
--- response
foo({"success":1});



=== TEST 5: Get model list
--- request
GET /=/model.js?callback=foo
--- response
foo([]);



=== TEST 6: Create a model
--- request
POST /=/model/Bookmark.js?callback=foo
{
    "description": "我的书签",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "type":"text", "label": "标题" },
        { "name": "url", "type":"text", "label": "网址" }
    ]
}
--- response
foo({"success":1,"warning":"Column \"id\" reserved. Ignored."});



=== TEST 7: check the model list again
--- request
GET /=/model.js?callback=foo
--- response
foo([{"src":"/=/model/Bookmark","name":"Bookmark","description":"我的书签"}]);



=== TEST 8: check the column
--- request
GET /=/model/Bookmark.js?callback=foo
--- response
foo({
  "columns":
   [
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":null,"label":"标题","type":"text"},
    {"name":"url","default":null,"label":"网址","type":"text"}
   ],
  "name":"Bookmark",
  "description":"我的书签"
});



=== TEST 9: access inexistent models
--- request
GET /=/model/Foo.js?callback=foo
--- response
foo({"success":0,"error":"Model \"Foo\" not found."});



=== TEST 10: insert a single record
--- request
POST /=/model/Bookmark/~/~?callback=foo
{ "title": "Yahoo Search", "url": "http://www.yahoo.cn" }
--- response
foo({"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/1"});



=== TEST 11: insert another record
--- request
POST /=/model/Bookmark/~/~.js?callback=foo
{ "title": "Yahoo Search", "url": "http://www.yahoo.cn" }
--- response
foo({"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/2"});



=== TEST 12: insert multiple records at a time
--- request
POST /=/model/Bookmark/~/~.js?callback=foo
[
    { "title": "Google搜索", "url": "http://www.google.cn" },
    { "url": "http://www.baidu.com" },
    { "title": "Perl.com", "url": "http://www.perl.com" }
]
--- response
foo({"success":1,"rows_affected":3,"last_row":"/=/model/Bookmark/id/5"});



=== TEST 13: read a record
--- request
GET /=/model/Bookmark/id/1.js?callback=foo
--- response
foo([{"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"}]);



=== TEST 14: read another record
--- request
GET /=/model/Bookmark/id/5.js?callback=foo
--- response
foo([{"url":"http://www.perl.com","title":"Perl.com","id":"5"}]);



=== TEST 15: read urls of all the records
--- request
GET /=/model/Bookmark/url/~.js?callback=foo
--- response
foo([
    {"url":"http://www.yahoo.cn"},
    {"url":"http://www.yahoo.cn"},
    {"url":"http://www.google.cn"},
    {"url":"http://www.baidu.com"},
    {"url":"http://www.perl.com"}
]);



=== TEST 16: select records
--- request
GET /=/model/Bookmark/url/http://www.yahoo.cn.js?callback=foo
--- response
foo([
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"}
]);



=== TEST 17: read all records
--- request
GET /=/model/Bookmark/~/~.js?callback=foo
--- response
foo([
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"1"},
    {"url":"http://www.yahoo.cn","title":"Yahoo Search","id":"2"},
    {"url":"http://www.google.cn","title":"Google搜索","id":"3"},
    {"url":"http://www.baidu.com","title":null,"id":"4"},
    {"url":"http://www.perl.com","title":"Perl.com","id":"5"}
]);



=== TEST 18: delete a record
--- request
DELETE /=/model/Bookmark/id/2.js?callback=foo
--- response
foo({"success":1,"rows_affected":1});



=== TEST 19: check the record just deleted
--- request
GET /=/model/Bookmark/id/2.js?callback=foo
--- response
foo([]);



=== TEST 20: update a nonexistent record
--- request
PUT /=/model/Bookmark/id/2.js?callback=foo
{ "title": "Blah blah blah" }
--- response
foo({"success":0,"rows_affected":0});



=== TEST 21: update an existent record
--- request
PUT /=/model/Bookmark/id/3.js?callback=foo
{ "title": "Blah blah blah" }
--- response
foo({"success":1,"rows_affected":1});



=== TEST 22: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js?callback=foo
--- response
foo([{"url":"http://www.google.cn","title":"Blah blah blah","id":"3"}]);



=== TEST 23: update an existent record using POST
--- request
POST /=/put/model/Bookmark/id/3.js?callback=foo
{ "title": "Howdy!" }
--- response
foo({"success":1,"rows_affected":1});



=== TEST 24: check if the record is indeed changed
--- request
GET /=/model/Bookmark/id/3.js?callback=foo
--- response
foo([{"url":"http://www.google.cn","title":"Howdy!","id":"3"}]);



=== TEST 25: Change the name of the model
--- request
PUT /=/model/Bookmark.js?callback=foo
{ "name": "MyFavorites", "description": "我的最爱" }
--- response
foo({"success":"1"});



=== TEST 26: Check the new model
--- request
GET /=/model/MyFavorites.js?callback=foo
--- response
foo({
  "columns":
   [
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":null,"label":"标题","type":"text"},
    {"name":"url","default":null,"label":"网址","type":"text"}
   ],
  "name":"MyFavorites",
  "description":"我的最爱"
});



=== TEST 27: Change the name and type of title
--- request
PUT /=/model/MyFavorites/title?callback=foo
{ "name": "count", "type": "text" }
--- response
foo({"success":1});



=== TEST 28: Get model list
--- request
GET /=/model.js?callback=foo
--- response
foo([{"src":"/=/model/MyFavorites","name":"MyFavorites","description":"我的最爱"}]);



=== TEST 29: logout
--- request
GET /=/logout
--- response
{"success":1}

