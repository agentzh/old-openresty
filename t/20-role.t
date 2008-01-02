# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: login
--- request
GET /=/login/peee.Admin
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 2: Delete existing models
--- request
DELETE /=/model/~
--- response
{"success":1}



=== TEST 3: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 4: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 5: Delete existing roles (using wildcard)
--- request
DELETE /=/role/~
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 6: Get the role list
--- request
GET /=/role
--- response
[
    {"src":"/=/role/Admin","name":"Admin","description":"Administrator"},
    {"src":"/=/role/Public","name":"Public","description":"Anonymous"}
]



=== TEST 7: Use wildcard to get the role list
--- request
GET /=/role/~
--- response
[
    {"src":"/=/role/Admin","name":"Admin","description":"Administrator"},
    {"src":"/=/role/Public","name":"Public","description":"Anonymous"}
]



=== TEST 8: Get the Admin role
--- request
GET /=/role/Admin
--- response
{
    "columns":[
        {"name":"method","label":"HTTP method","type":"text"},
        {"name":"url","label":"Resource","type":"text"}
    ],
    "name":"Admin",
    "description":"Administrator",
    "login":"password"
}



=== TEST 9: GET the Public role
--- request
GET /=/role/Public
--- response
{
  "columns":[
    {"name":"method","label":"HTTP method","type":"text"},
    {"name":"url","label":"Resource","type":"text"}
  ],
  "name":"Public",
  "description":"Anonymous",
  "login":"anonymous"
}



=== TEST 10: Clear out Public's rules
--- request
DELETE /=/role/Public/~/~
--- response
{"success":1}



=== TEST 11: Get Public's rules
--- request
GET /=/role/Public/~/~
--- response
[]



=== TEST 12: Add a new rule to Public
--- request
POST /=/role/Public/~/~
{"method":"GET","url":"/=/model"}
--- response_like
{"success":1,"rows_affected":1,"last_row":"/=/role/Public/id/\d+"}



=== TEST 13: Add more rules
--- request
POST /=/role/Public/~/~
[
    {"method":"POST","url":"/=/model/~"},
    {"method":"POST","url":"/=/model/A/~/~"},
    {"method":"DELETE","url":"/=/model/A/id/~"}
]
--- response_like
{"success":1,"rows_affected":3,"last_row":"/=/role/Public/id/\d+"}



=== TEST 14: Get the access rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    \{"url":"/=/model/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 15: Query by method
--- request
GET /=/role/Public/method/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    \{"url":"/=/model/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 16: Query by method value
--- request
GET /=/role/Public/method//=/model
--- response
[]



=== TEST 17: Query by method value (don't specify col)
--- request
GET /=/role/Public/~//=/model
--- response_like
\[{"url":"/=/model","method":"GET","id":"\d+"}\]



=== TEST 18: Query by method value (don't specify col)
--- request
GET /=/role/Public/~/model?op=contains
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    \{"url":"/=/model/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 19: use contains op
--- request
GET /=/role/Public/url/A?op=contains
--- response_like
\[
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 20: Query by method value GET
--- request
GET /=/role/Public/method/GET
--- response_like
\[{"url":"/=/model","method":"GET","id":"\d+"}\]



=== TEST 21: Query by method value POST
--- request
GET /=/role/Public/method/POST
--- response_like
\[
    {"url":"/=/model/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"}
\]



=== TEST 22: Query by method value POST
--- request
GET /=/role/Public/~/POST
--- response_like
\[
    {"url":"/=/model/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"}
\]



=== TEST 23: Switch to the Public role
--- request
GET /=/login/.Public
--- response
{"success":1,"account":"peee","role":"Public"}



=== TEST 24: Create model A
--- request
POST /=/model/~
{name:"A",description:"A",columns:{"name":"title",label:"name"}}
--- response
{"success":1}



=== TEST 25: Create model B
--- request
POST /=/model/B
{description:"B",columns:[
    {name:"title",label:"title"},
    {name:"body",label:"body"}
 ]
}
--- response
{"success":1}



=== TEST 26: Get model list
--- request
GET /=/model
--- response
[
    {"src":"/=/model/A","name":"A","description":"A"},
    {"src":"/=/model/B","name":"B","description":"B"}
]



=== TEST 27: Delete the models
--- request
DELETE /=/model
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 28: Put to models
--- request
PUT /=/model
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 29: Get an individual model (not in rules)
--- request
GET /=/model/A
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 30: Use the other form
--- request
GET /=/model/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 31: Read the column
--- request
GET /=/model/A/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 32: Read the column (be explicit)
--- request
GET /=/model/A/title
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 33: Try to remove the column
--- request
DELETE /=/model/A/title
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 34: Insert rows
--- request
POST /=/model/A/~/~
[ {"title":"Audrey"}, {"title":"Larry"}, {"title":"Patrick"} ]
--- response
{"success":1,"rows_affected":3,"last_row":"/=/model/A/id/3"}



=== TEST 35: Get the rows
--- request
GET /=/model/A/~/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 36: Get a single row
--- request
GET /=/model/A/id/3
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 37: Delete rows
--- request
DELETE /=/model/A/~/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 38: Delete rows
--- request
DELETE /=/model/A/title/Audrey
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 39: Update a row
--- request
PUT /=/model/A/id/3
{"title":"fglock"}
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 40: Delete a row
--- request
DELETE /=/model/A/id/3
--- response
{"success":1,"rows_affected":1}



=== TEST 41: Delete a row again
--- request
DELETE /=/model/A/id/3
--- response
{"success":1,"rows_affected":0}



=== TEST 42: Delete all the rows
--- request
DELETE /=/model/A/id/~
--- response
{"success":1,"rows_affected":2}



=== TEST 43: Delete all the rows in model B
--- request
DELETE /=/model/B/id/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 44: Add a new column to A
--- request
POST /=/model/A/foo
{"label":"foo"}
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 45: Delete the newly added column
--- request
DELETE /=/model/A/bar
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 46: Get the view list
--- request
GET /=/view
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 47: Try to create a view
--- request
POST /=/view/MyView
{"body":"select * from A"}
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 48: Switch back to the Amin role
--- request
GET /=/login/.Admin
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 49: Check the records in A
--- request
GET /=/model/A/~/~
--- response
[]



=== TEST 50: Create a new role w/o description
--- request
POST /=/role/Poster
{
    login: "password",
    password: "4423037"
}
--- response
{"success":0,"error":"Field 'description' is missing."}



=== TEST 51: Create a new role w/o login
--- request
POST /=/role/Poster
{
    "description":"Comment poster"
}
--- response
{"success":0,"error":"No 'login' field specified."}



=== TEST 52: Create a new role w/o password
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password"
}
--- response
{"success":0,"error":"No password given when 'login' is 'password'."}



=== TEST 53: unknown login method
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "blah"
}
--- response
{"success":0,"error":"Unknown login method: blah"}



=== TEST 54: blank password not allowed
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: ""
}
--- response
{"success":0,"error":"Password too short; at least 6 chars required."}



=== TEST 55: too short password not allowed
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: "12345"
}
--- response
{"success":0,"error":"Password too short; at least 6 chars required."}



=== TEST 56: Create a new role in the right way
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: "4423037"
}
--- response
{"success":1}



=== TEST 57: Add a rule to read model list
--- request
POST /=/role/Poster/~/~
{"url":"/=/model"}
--- response_like
\{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"\}



=== TEST 58: Add a rule to insert new rows to A (missing column 'url')
--- request
POST /=/role/Poster/~/~
{"method":"POST","src":"/=/model/A/~/~"}
--- response
{"success":0,"error":"row 1: Column \"url\" is missing."}



=== TEST 59: Add a rule to insert new rows to A (the right way)
--- request
POST /=/role/Poster/~/~
{"method":"POST","url":"/=/model/A/~/~"}
--- response_like
^\{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"\}$



=== TEST 60: Check the rule list
--- request
GET /=/role/Poster/~/~
--- response_like
^\[
    {"url":"/=/model","method":"GET","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"}
\]$



=== TEST 61: Log into the new role
--- request
GET /=/login/.Poster
--- response
{"success":1,"account":"peee","role":"Poster"}



=== TEST 62: Try to do something
--- request
GET /=/model
--- response
[
    {"src":"/=/model/A","name":"A","description":"A"},
    {"src":"/=/model/B","name":"B","description":"B"}
]



=== TEST 63: Try to get model list by another way
--- request
GET /=/model/~
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 64: Try to create a new model
--- request
POST /=/model/C
{ description: "C" }
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 65: Try to access minisql
--- request
POST /=/action/.Select/lang/minisql
"select * from A"
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 66: Try to delete itself
--- request
DELETE /=/role/Poster
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 67: Switch back to the Amin role
--- request
GET /=/login/.Admin
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 68: Drop the Poster role
--- request
DELETE /=/role/Poster
--- response
{"success":1}



=== TEST 69: Access the Poster role again
--- request
GET /=/role/Poster
--- response
{"success":0,"error":"Role \"Poster\" not found."}



=== TEST 70: Try to drop the Admin role
--- request
DELETE /=/role/Admin
--- response
{"success":0,"error":"Role \"Admin\" reserved."}



=== TEST 71: Access the Admin role again
--- request
GET /=/role/Admin
--- response
{
    "columns":[
        {"name":"method","label":"HTTP method","type":"text"},
        {"name":"url","label":"Resource","type":"text"}
    ],
    "name":"Admin",
    "description":"Administrator",
    "login":"password"
}



=== TEST 72: Try to drop the Public role
--- request
DELETE /=/role/Public
--- response
{"success":0,"error":"Role \"Public\" reserved."}



=== TEST 73: Access the Public role again
--- request
GET /=/role/Public
--- response
{
    "columns":[
        {"name":"method","label":"HTTP method","type":"text"},
        {"name":"url","label":"Resource","type":"text"}
    ],
    "name":"Public",
    "description":"Anonymous",
    "login":"anonymous"
}



=== TEST 74: Get access rules in Public
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    {"url":"/=/model/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 75: Delete rules with POST method
--- request
DELETE /=/role/Public/method/POST
--- response
{"success":1}



=== TEST 76: Get access rules in Public again
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]


