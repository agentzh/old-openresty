# vi:filetype=

use t::OpenResty;

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



=== TEST 3: Create a model with various types
--- request
POST /=/model/Foo
{
    "description": "transaction testing",
    "columns": [
        {"name": "name", "label": "Name", "type": "text"},
        {"name": "age", "label": "Age", "type": "integer"}
    ]
}
--- response
{"success":1}



=== TEST 4: Insert various records
--- request
POST /=/model/Foo/~/~
[{"name":"Marry","age":17},{"name":"Bob","age":"invalid"}]
--- response_like
{"success":0,"error":



=== TEST 5: Check if the first record has been inserted
--- request
GET /=/model/Foo/~/~
--- response
[]

