use t::OpenAPI;

=pod

This test file tests URLs in the form /=/model/xxx/xxx/xxx

TODO
* many...

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 2: insert data to an nonexistant model
--- request
POST /=/model/Dummy/~/~
{ name: 'foo' }
--- response
{"success":0,"error":"Model \"Dummy\" not found."}



=== TEST 3: Create a model
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



=== TEST 4: check the model list
--- request
GET /=/model
--- response
[{"src":"/=/model/Address","name":"Address","description":"通讯录"}]



=== TEST 5: insert multiple records at a time
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



=== TEST 6: Get rows found 'Perl' in any column
--- request
GET /=/model/Address/~/Perl
--- response
[{"name":"Perl","id":"3","addr":"http://www.perl.com"},{"name":"Perl.com","id":"4","addr":"Perl"}]

