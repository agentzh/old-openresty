# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create the Human model
--- request
POST /=/model/Human
{ "description":"Human" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Human\"."}



=== TEST 3: Create the Cat model
--- request
POST /=/model/Cat
{ "description":"Cat" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Cat\"."}



=== TEST 4: Create the Cow model
--- request
POST /=/model/Cow
{ "description":"Cow" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Cow\"."}



=== TEST 5: Show the model list
--- request
GET /=/model
--- response
[
    {"src":"/=/model/Human","name":"Human","description":"Human"},
    {"src":"/=/model/Cat","name":"Cat","description":"Cat"},
    {"src":"/=/model/Cow","name":"Cow","description":"Cow"}
]



=== TEST 6: Show the model list order by id
--- request
GET /=/model?order_by=id
--- response
[
    {"src":"/=/model/Human","name":"Human","description":"Human"},
    {"src":"/=/model/Cat","name":"Cat","description":"Cat"},
    {"src":"/=/model/Cow","name":"Cow","description":"Cow"}
]



=== TEST 7: Show the model list order by id desc
XXX TODO
--- request
GET /=/model?order_by=id:desc
--- response
[
    {"src":"/=/model/Cow","name":"Cow","description":"Cow"},
    {"src":"/=/model/Cat","name":"Cat","description":"Cat"},
    {"src":"/=/model/Human","name":"Human","description":"Human"}
]
--- SKIP

