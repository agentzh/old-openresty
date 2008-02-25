# vi:filetype=

use t::OpenAPI;

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
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
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
{ name: 'foo' }
--- response
{"success":0,"error":"Model \"Dummy\" not found."}



=== TEST 4: Create a model
--- request
POST /=/model/Address
{
    description: "通讯录",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "name", label: "名称" },
        { name: "addr", label: "地址" }
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
    { name: "Google搜索", addr: "http://www.google.cn" },
    { addr: "http://www.baidu.com" },
    { name: "Perl", addr: "http://www.perl.com" },
    { name: "Perl.com", addr: "Perl" }
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
{ id: 99}
--- response
{"success":0,"error":"Column \"id\" reserved."}



=== TEST 9: Use special chars
--- request
PUT /=/model/Address/id/1
{ name: "\"\\\"" }
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
{ addr: "\t\\\n" }
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

