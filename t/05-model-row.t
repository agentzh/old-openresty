# vi:filetype=

use t::OpenResty;

=pod

This test file tests URLs in the form /=/model/xxx/xxx/xxx

TODO
* many...

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 2: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 3: insert data to an nonexistant model
--- request
POST /=/model/Dummy/~/~
{ "name": "foo" }
--- response
{"success":0,"error":"Model \"Dummy\" not found."}



=== TEST 4: Create a model
--- request
POST /=/model/Address
{
    "description": "通讯录",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "name", "type":"text", "label": "名称" },
        { "name": "addr", "type":"text", "label": "地址" }
    ]
}
--- response
{"success":1,"warning":"Column \"id\" reserved. Ignored."}



=== TEST 5: check the model list
--- request
GET /=/model
--- response
[{"src":"/=/model/Address","name":"Address","description":"通讯录"}]



=== TEST 6: insert multiple records at a time
--- request
POST /=/model/Address/~/~
[
    { "name": "Google搜索", "addr": "http://www.google.cn" },
    { "addr": "http://www.baidu.com" },
    { "name": "Perl", "addr": "http://www.perl.com" },
    { "name": "Perl.com", "addr": "Perl" }
]
--- response
{"success":1,"rows_affected":4,"last_row":"/=/model/Address/id/4"}



=== TEST 7: Get rows found 'Perl' in any column
--- request
GET /=/model/Address/~/Perl
--- response
[{"name":"Perl","id":"3","addr":"http://www.perl.com"},{"name":"Perl.com","id":"4","addr":"Perl"}]



=== TEST 8: update id
--- request
PUT /=/model/Address/id/3
{ "id": 99}
--- response
{"success":0,"error":"Column \"id\" reserved."}



=== TEST 9: Use special chars
--- request
PUT /=/model/Address/id/1
{ "name": "\"\\\"" }
--- response
{"success":1,"rows_affected":1}



=== TEST 10: Check the new name
--- request
GET /=/model/Address/id/1
--- response
[{"name":"\"\\\"","id":"1","addr":"http://www.google.cn"}]



=== TEST 11: Use special chars
--- request
PUT /=/model/Address/id/1
{ "addr": "\t\\\n" }
--- response
{"success":1,"rows_affected":1}



=== TEST 12: Check the new addr
--- request
GET /=/model/Address/id/1
--- response
[{"name":"\"\\\"","id":"1","addr":"\t\\\n"}]



=== TEST 13: PUT by selector
--- request
PUT /=/model/Address/name/Perl?op=contain
{"name":"Haskell"}
--- response
{"success":1,"rows_affected":1}



=== TEST 14: PUT by selector (again)
--- request
PUT /=/model/Address/name/Perl?op=contain
{"name":"Haskell"}
--- response
{"success":0,"rows_affected":0}



=== TEST 15: insert a new row
--- request
POST /=/model/Address/~/~
{"name":"安徽"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Address/id/5"}



=== TEST 16: Get that row out by name
--- request
GET /=/model/Address/name/安徽
--- response
[{"name":"安徽","id":"5","addr":null}]



=== TEST 17: Get that row out by uri encoded name
--- request
GET /=/model/Address/name/%E5%AE%89%E5%BE%BD
--- response
[{"name":"安徽","id":"5","addr":null}]



=== TEST 18: PUT by a Chinese selector
--- request
PUT /=/model/Address/name/安徽
{ "name": "上海" }
--- response
{"success":1,"rows_affected":1}



=== TEST 19: Check if 安徽 still exists
--- request
GET /=/model/Address/name/安徽
--- response
[]



=== TEST 20: check if 上海 is there
--- request
GET /=/model/Address/name/上海
--- response
[{"addr":null,"id":"5","name":"上海"}]



=== TEST 21: Delete 上海
--- request
DELETE /=/model/Address/name/上海
--- response
{"rows_affected":1,"success":1}



=== TEST 22: check if 上海 is there
--- request
GET /=/model/Address/name/上海
--- response
[]



=== TEST 23: Insert data with id
--- request
POST /=/model/Address/~/~
{"id":5,"name":"镇江"}
--- response
{"last_row":"/=/model/Address/id/5","rows_affected":1,"success":1}



=== TEST 24: Insert data with id
--- request
POST /=/model/Address/~/~
{"id":6,"name":"无锡"}
--- response
{"last_row":"/=/model/Address/id/6","rows_affected":1,"success":1}



=== TEST 25: Insert data with id
--- request
POST /=/model/Address/~/~
{"name":"无锡2"}
--- response
{"last_row":"/=/model/Address/id/7","rows_affected":1,"success":1}



=== TEST 26: Insert multiple lines of data with explicit id
--- request
POST /=/model/Address/~/~
[
    {"id":8, "name":"foo"},
    {"id":9, "name":"bar"}
]
--- response
{"last_row":"/=/model/Address/id/9","rows_affected":2,"success":1}



=== TEST 27: Insert multiple lines of data with explicit id
--- request
POST /=/model/Address/~/~
[
    {"name":"id10"},
    {"name":"id11"},
    {"name":"id12"}
]
--- response
{"last_row":"/=/model/Address/id/12","rows_affected":3,"success":1}



=== TEST 28: Get id 10
--- request
GET /=/model/Address/id/10
--- response
[{"id":"10","name":"id10","addr":null}]



=== TEST 29: logout
--- request
GET /=/logout
--- response
{"success":1}

