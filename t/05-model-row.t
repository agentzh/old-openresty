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
        { name: "name", label: "姓名" },
        { name: "phone", label: "电话" }
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
POST /=/model/Dummy/~/~
[
    { title: "Google搜索", url: "http://www.google.cn" },
    { url: "http://www.baidu.com" },
    { title: "Perl.com", url: "http://www.perl.com" }
]
--- response
{"success":1,"rows_affected":3,"last_row":"/=/model/Bookmark/id/5"}



=== TEST 6: Access records via a bad model name
--- request
GET /=/model/Dummy/~/~
{ name: 'foo' }
--- response
{"success":0,"error":"Model \"Dummy\" not found."}

