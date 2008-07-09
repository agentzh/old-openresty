# vi:filetype=

use t::OpenResty;

plan tests => 3 * (blocks() - 1);

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Post
{"description":"Post",
 "columns":[{"name":"name","label":"Name","type":"text","unique":true},
            {"name":"age","label":"Age","type":"integer","unique":false}]
}
--- response
{"success":1}



=== TEST 3: Insert 2 records with the same name
--- debug: 1
--- request
POST /=/model/Post/~/~
[
    {"name":"agentzh","age":23},
    {"name":"agentzh","age":34}
]
--- response_like
duplicate key (?:value )?violates unique constraint \\"Post_name_key\\"



=== TEST 4: Insert 2 records with the same name
--- debug: 0
--- request
POST /=/model/Post
[
    {"name":"agentzh","age":23},
    {"name":"agentzh","age":34}
]
--- response
{"success":0,"error":"Operation failed."}



=== TEST 5: Insert 2 records with the same name
--- debug: 1
--- request
POST /=/model/Post/~/~
[
    {"name":"agentzh","age":23},
    {"name":"yuting","age":23}
]
--- response
{"last_row":"/=/model/Post/id/4","rows_affected":2,"success":1}



=== TEST 6: Modify the uniqueness
XXX TODO...
--- request
PUT /=/model/Post/age
{"unique":true}
--- response
{"error":"Updating column's uniqueness is not implemented yet.","success":0}
--- SKIP



=== TEST 7: logout
--- request
GET /=/logout
--- response
{"success":1}

