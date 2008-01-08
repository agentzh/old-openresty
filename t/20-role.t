# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: login (w/o password)
--- request
GET /=/login/peee.Admin
--- response
{"success":0,"error":"Password for peee.Admin is required."}



=== TEST 2: login
--- request
GET /=/login/peee.Admin/4423037
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 3: Delete existing models
--- request
DELETE /=/model/~
--- response
{"success":1}



=== TEST 4: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 5: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 6: Delete existing roles (using wildcard)
--- request
DELETE /=/role/~
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 7: Get the role list
--- request
GET /=/role
--- response
[
    {"src":"/=/role/Admin","name":"Admin","description":"Administrator"},
    {"src":"/=/role/Public","name":"Public","description":"Anonymous"}
]



=== TEST 8: Use wildcard to get the role list
--- request
GET /=/role/~
--- response
[
    {"src":"/=/role/Admin","name":"Admin","description":"Administrator"},
    {"src":"/=/role/Public","name":"Public","description":"Anonymous"}
]



=== TEST 9: Get the Admin role
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



=== TEST 10: GET the Public role
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



=== TEST 11: Clear out Public's rules
--- request
DELETE /=/role/Public/~/~
--- response
{"success":1}



=== TEST 12: Get Public's rules
--- request
GET /=/role/Public/~/~
--- response
[]



=== TEST 13: Add a new rule to Public
--- request
POST /=/role/Public/~/~
{"method":"GET","url":"/=/model"}
--- response_like
{"success":1,"rows_affected":1,"last_row":"/=/role/Public/id/\d+"}



=== TEST 14: Add more rules
--- request
POST /=/role/Public/~/~
[
    {"method":"POST","url":"/=/model/~"},
    {"method":"POST","url":"/=/model/A/~/~"},
    {"method":"DELETE","url":"/=/model/A/id/~"}
]
--- response_like
{"success":1,"rows_affected":3,"last_row":"/=/role/Public/id/\d+"}



=== TEST 15: Get the access rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    \{"url":"/=/model/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 16: Query by method
--- request
GET /=/role/Public/method/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    \{"url":"/=/model/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 17: Query by method value
--- request
GET /=/role/Public/method//=/model
--- response
[]



=== TEST 18: Query by method value (don't specify col)
--- request
GET /=/role/Public/~//=/model
--- response_like
\[{"url":"/=/model","method":"GET","id":"\d+"}\]



=== TEST 19: Query by method value (don't specify col)
--- request
GET /=/role/Public/~/model?op=contains
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    \{"url":"/=/model/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 20: use contains op
--- request
GET /=/role/Public/url/A?op=contains
--- response_like
\[
    \{"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    \{"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 21: Query by method value GET
--- request
GET /=/role/Public/method/GET
--- response_like
\[{"url":"/=/model","method":"GET","id":"\d+"}\]



=== TEST 22: Query by method value POST
--- request
GET /=/role/Public/method/POST
--- response_like
\[
    {"url":"/=/model/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"}
\]



=== TEST 23: Query by method value POST
--- request
GET /=/role/Public/~/POST
--- response_like
\[
    {"url":"/=/model/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"}
\]



=== TEST 24: Switch to the Public role
--- request
GET /=/login/.Public
--- response
{"success":0,"error":"Bad user name: \".Public\""}



=== TEST 25: Switch to the Public role
--- request
GET /=/login/peee.Public
--- response
{"success":1,"account":"peee","role":"Public"}



=== TEST 26: Create model A
--- request
POST /=/model/~
{name:"A",description:"A",columns:{"name":"title",label:"name"}}
--- response
{"success":1}



=== TEST 27: Create model B
--- request
POST /=/model/B
{description:"B",columns:[
    {name:"title",label:"title"},
    {name:"body",label:"body"}
 ]
}
--- response
{"success":1}



=== TEST 28: Get model list
--- request
GET /=/model
--- response
[
    {"src":"/=/model/A","name":"A","description":"A"},
    {"src":"/=/model/B","name":"B","description":"B"}
]



=== TEST 29: Delete the models
--- request
DELETE /=/model
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 30: Put to models
--- request
PUT /=/model
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 31: Get an individual model (not in rules)
--- request
GET /=/model/A
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 32: Use the other form
--- request
GET /=/model/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 33: Read the column
--- request
GET /=/model/A/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 34: Read the column (be explicit)
--- request
GET /=/model/A/title
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 35: Try to remove the column
--- request
DELETE /=/model/A/title
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 36: Insert rows
--- request
POST /=/model/A/~/~
[ {"title":"Audrey"}, {"title":"Larry"}, {"title":"Patrick"} ]
--- response
{"success":1,"rows_affected":3,"last_row":"/=/model/A/id/3"}



=== TEST 37: Get the rows
--- request
GET /=/model/A/~/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 38: Get a single row
--- request
GET /=/model/A/id/3
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 39: Delete rows
--- request
DELETE /=/model/A/~/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 40: Delete rows
--- request
DELETE /=/model/A/title/Audrey
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 41: Update a row
--- request
PUT /=/model/A/id/3
{"title":"fglock"}
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 42: Delete a row
--- request
DELETE /=/model/A/id/3
--- response
{"success":1,"rows_affected":1}



=== TEST 43: Delete a row again
--- request
DELETE /=/model/A/id/3
--- response
{"success":1,"rows_affected":0}



=== TEST 44: Delete all the rows
--- request
DELETE /=/model/A/id/~
--- response
{"success":1,"rows_affected":2}



=== TEST 45: Delete all the rows in model B
--- request
DELETE /=/model/B/id/~
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 46: Add a new column to A
--- request
POST /=/model/A/foo
{"label":"foo"}
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 47: Delete the newly added column
--- request
DELETE /=/model/A/bar
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 48: Get the view list
--- request
GET /=/view
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 49: Try to create a view
--- request
POST /=/view/MyView
{"body":"select * from A"}
--- response
{"success":0,"error":"Permission denied for the \"Public\" role."}



=== TEST 50: Switch back to the Amin role
--- request
GET /=/login/peee.Admin/4423037
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 51: Check the records in A
--- request
GET /=/model/A/~/~
--- response
[]



=== TEST 52: Create a new role w/o description
--- request
POST /=/role/Poster
{
    login: "password",
    password: "4423037"
}
--- response
{"success":0,"error":"Field 'description' is missing."}



=== TEST 53: Create a new role w/o login
--- request
POST /=/role/Poster
{
    "description":"Comment poster"
}
--- response
{"success":0,"error":"No 'login' field specified."}



=== TEST 54: Create a new role w/o password
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password"
}
--- response
{"success":0,"error":"No password given when 'login' is 'password'."}



=== TEST 55: unknown login method
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "blah"
}
--- response
{"success":0,"error":"Unknown login method: blah"}



=== TEST 56: blank password not allowed
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: ""
}
--- response
{"success":0,"error":"Password too short; at least 6 chars required."}



=== TEST 57: too short password not allowed
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: "12345"
}
--- response
{"success":0,"error":"Password too short; at least 6 chars required."}



=== TEST 58: Create a new role in the right way
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: "4417935"
}
--- response
{"success":1}



=== TEST 59: Create the same role for a second time
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    login: "password",
    password: "4417935"
}
--- response
{"success":0,"error":"Role \"Poster\" already exists."}



=== TEST 60: Add a rule to read model list
--- request
POST /=/role/Poster/~/~
{"url":"/=/model"}
--- response_like
\{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"\}



=== TEST 61: Add a rule to insert new rows to A (missing column 'url')
--- request
POST /=/role/Poster/~/~
{"method":"POST","src":"/=/model/A/~/~"}
--- response
{"success":0,"error":"row 1: Column \"url\" is missing."}



=== TEST 62: Add a rule to insert new rows to A (the right way)
--- request
POST /=/role/Poster/~/~
{"method":"POST","url":"/=/model/A/~/~"}
--- response_like
^\{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"\}$



=== TEST 63: Check the rule list
--- request
GET /=/role/Poster/~/~
--- response_like
^\[
    {"url":"/=/model","method":"GET","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"}
\]$



=== TEST 64: Log into the new role
--- request
GET /=/login/peee.Poster
--- response
{"success":0,"error":"Password for peee.Poster is required."}



=== TEST 65: Log into the new role
--- request
GET /=/login/peee.Poster/4417935
--- response
{"success":1,"account":"peee","role":"Poster"}



=== TEST 66: Try to do something
--- request
GET /=/model
--- response
[
    {"src":"/=/model/A","name":"A","description":"A"},
    {"src":"/=/model/B","name":"B","description":"B"}
]



=== TEST 67: Try to get model list by another way
--- request
GET /=/model/~
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 68: Try to create a new model
--- request
POST /=/model/C
{ description: "C" }
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 69: Try to access minisql
--- request
POST /=/action/.Select/lang/minisql
"select * from A"
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 70: Try to delete itself
--- request
DELETE /=/role/Poster
--- response
{"success":0,"error":"Permission denied for the \"Poster\" role."}



=== TEST 71: Switch back to the Amin role
--- request
GET /=/login/peee.Admin/4423037
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 72: Drop the Poster role
--- request
DELETE /=/role/Poster
--- response
{"success":1}



=== TEST 73: Access the Poster role again
--- request
GET /=/role/Poster
--- response
{"success":0,"error":"Role \"Poster\" not found."}



=== TEST 74: Try to drop the Admin role
--- request
DELETE /=/role/Admin
--- response
{"success":0,"error":"Role \"Admin\" reserved."}



=== TEST 75: Access the Admin role again
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



=== TEST 76: Try to drop the Public role
--- request
DELETE /=/role/Public
--- response
{"success":0,"error":"Role \"Public\" reserved."}



=== TEST 77: Access the Public role again
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



=== TEST 78: Get access rules in Public
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    {"url":"/=/model/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/~/~","method":"POST","id":"\d+"},
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 79: Delete rules with POST method
--- request
DELETE /=/role/Public/method/POST
--- response
{"success":1}



=== TEST 80: Get access rules in Public again
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"url":"/=/model","method":"GET","id":"\d+"},
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"}
\]



=== TEST 81: Try to update id of rule in Public
--- request
PUT /=/role/Public/id/~
{ id: "521" }
--- response
{"success":0,"error":"Column \"id\" reserved."}



=== TEST 82: Update urls of rules
--- request
PUT /=/role/Public/method/GET
{ url: "/=/model/A/~" }
--- response
{"success":1}



=== TEST 83: Check the new rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"},
    {"url":"/=/model/A/~","method":"GET","id":"\d+"}
]



=== TEST 84: Update methods of rules
--- request
PUT /=/role/Public/method/GET
{ method: "POST" }
--- response_like
{"success":1}



=== TEST 85: Check the new rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"},
    {"url":"/=/model/A/~","method":"POST","id":"\d+"}
]



=== TEST 86: Update methods & urls of rules
--- request
PUT /=/role/Public/method/POST
{ method: "GET",url: "/=/model" }
--- response_like
{"success":1}



=== TEST 87: Check the new rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"url":"/=/model/A/id/~","method":"DELETE","id":"\d+"},
    \{"url":"/=/model","method":"GET","id":"\d+"}
\]



=== TEST 88: Create a new role in the right way
--- request
POST /=/role/Poster
{
    description:"Comment poster",
    login: "password",
    password: "4417935"
}
--- response
{"success":1}



=== TEST 89: update the name
--- request
PUT /=/role/Poster
{
    name:"Newposter"
}
--- response
{"success":1}



=== TEST 90: update the description
--- request
PUT /=/role/Newposter
{
    description:"my description"
}
--- response
{"success":1}



=== TEST 91: update the name and the description
--- request
PUT /=/role/Newposter
{
    name:"Newname",
    description:"Newdescription"
}
--- response
{"success":1}



=== TEST 92: update the password when login == password
--- request
PUT /=/role/Newname
{
    password:"123456789"
}
--- response
{"success":1}



=== TEST 93: update the login
--- request
PUT /=/role/Newname
{
    login:"captcha"
}
--- response
{"success":1}



=== TEST 94: try to update the password when login != password
--- request
PUT /=/role/Newname
{
    password:"987654321"
}
--- response
{"success":0,"error":"could not update the password when login != 'password'."}



=== TEST 95: update the all the info
--- request
PUT /=/role/Newname
{
    name:"Poster",
    description:"Comment poster",
    login:"anonymous"
}
--- response
{"success":1}



=== TEST 96: Drop the Poster role
--- request
DELETE /=/role/Poster
--- response
{"success":1}


