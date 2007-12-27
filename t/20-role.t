# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model/~
--- response
{"success":1}



=== TEST 2: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 3: Delete existing roles
--- request
DELETE /=/view
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 4: Get the role list
--- request
GET /=/role
--- response
[
    {"name":"Admin","description":"Administrator","src":"/=/role/Admin"},
    {"name":"Public","description":"Anonymous","src":"/=/role/Public"}
]



=== TEST 5: Use wildcard to get the role list
--- request
GET /=/role/~
--- response
[
    {"name":"Admin","description":"Administrator","src":"/=/role/Admin"},
    {"name":"Public","description":"Anonymous","src":"/=/role/Public"}
]



=== TEST 6: Get the Admin role
--- request
GET /=/role/Admin
--- response
{
    "name":"Admin",
    "description":"Administrator",
    "login":["password","******"],
    "columns":[
        {"name":"method","type":"text",label:"HTTP method"},
        {"name":"url","type":"text",label:"Resource"}
    ]
}



=== TEST 7: GET the Public role
--- request
GET /=/role/Public
--- response
{
    "name":"Public",
    "description":"Anonymous",
    "login":"anonymous",
    "columns":[
        {"name":"method","type":"text",label:"HTTP method"},
        {"name":"src","type":"text",label:"Resource"}
    ]
}



=== TEST 8: Clear out Public's rules
--- request
DELETE /=/role/Public/~/~
--- response
{"success":1}



=== TEST 9: Get Public's rules
--- request
GET /=/role/Public/~/~
--- response
[]



=== TEST 10: Add a new rule to Public
--- request
POST /=/role/Public/~/~
--- response
[
    {"method":"GET","url":"/=/model"},
    {"method":"POST","url":"/=/model/~"},
    {"method":"POST","url":"/=/model/A/~/~"},
    {"method":"DELETE","url":"/=/model/A/id/~"},
    {"method":"DELETE","url":"/=/model/~/~"}
]



=== TEST 11: Switch to the Public role
GET /=/login/Public
--- response
{"success":1}



=== TEST 12: Create model A
--- request
POST /=/model/~
{name:"A",description:"A",columns:{"name":"title",label:"name"}}
--- response
{"success":1}



=== TEST 13: Create model B
--- request
POST /=/model/B
{description:"B",columns:[
    {name:"title",label:"title"},
    {name:"body",label:"body"}
 ]
}
--- response
{"success":1}



=== TEST 14: Get model list
--- request
GET /=/model
[
    {"name":"A","description":"A","src":"/=/model/A"},
    {"name":"B","description":"B","src":"/=/model/B"}
]



=== TEST 15: Get an individual model (not in rules)
--- request
GET /=/model/A
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 16: Use the other form
--- request
GET /=/model/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



