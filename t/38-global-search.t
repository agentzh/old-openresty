# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks() - 3 * 2;

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a new model
--- request
POST /=/model/Post
{ "description":"Post",
  "columns":
    [
        { "name": "Title", "type":"text", "label": "Title" },
        { "name": "Created", "type":"timestamp (0) without time zone", "label": "Created" }
    ]
}
--- response
{"success":1}



=== TEST 3: Insert some records
--- request
POST /=/model/Post/~/~
[
    {"Title":"Google你好","Created":"2008-08-09 15:36:00"},
    {"Title":"Yahoo你好","Created":"2008-08-10 22:37:00"}
]
--- response
{"last_row":"/=/model/Post/id/2","rows_affected":2,"success":1}



=== TEST 4: Search in all columns
--- request
GET /=/model/Post/~/你好?_op=contains
--- response
[{"Created":"2008-08-09 15:36:00","Title":"Google你好","id":"1"},{"Created":"2008-08-10 22:37:00","Title":"Yahoo你好","id":"2"}]



=== TEST 5: Search timestamp
--- request
GET /=/model/Post/~/2008-08-10?_op=contains
--- response
[{"Created":"2008-08-10 22:37:00","id":"2","Title":"Yahoo你好"}]

