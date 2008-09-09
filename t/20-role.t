# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: login (w/o password)
--- request
GET /=/login/$TestAccount.Admin
--- response
{"error":"$TestAccount.Admin is not anonymous.","success":0}



=== TEST 2: login
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



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
    {"description":"Administrator","name":"Admin","src":"/=/role/Admin"},
    {"description":"Anonymous","name":"Public","src":"/=/role/Public"}
]



=== TEST 8: Use wildcard to get the role list
--- request
GET /=/role/~
--- response
[
    {"description":"Administrator","name":"Admin","src":"/=/role/Admin"},
    {"description":"Anonymous","name":"Public","src":"/=/role/Public"}
]



=== TEST 9: Get the Admin role
--- request
GET /=/role/Admin
--- response
{
    "columns":[
        {"label":"HTTP method","name":"method","type":"text"},
        {"label":"Resource","name":"url","type":"text"}
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
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
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
"success":1



=== TEST 14: Add more rules
--- request
POST /=/role/Public/~/~
[
    {"method":"POST","url":"/=/model/~"},
    {"method":"POST","url":"/=/model/A/~/~"},
    {"method":"DELETE","url":"/=/model/A/id/~"}
]
--- response_like
{"last_row":"/=/role/Public/id/\d+","rows_affected":3,"success":1}



=== TEST 15: Get the access rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    \{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"},
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"},
    \{"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"}
\]



=== TEST 16: Query by method
--- request
GET /=/role/Public/method/~
--- response_like
\[
    \{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"},
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"},
    \{"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"}
\]



=== TEST 17: Query by method value
--- request
GET /=/role/Public/method/model
--- response
[]



=== TEST 18: Query by method value (don't specify col)
--- request
GET /=/role/Public/~/model
--- response_like
\[{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"}\]



=== TEST 19: Query by method value (don't specify col)
--- request
GET /=/role/Public/~/model?op=contains
--- response_like
\[
    \{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"},
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"},
    \{"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"}
\]



=== TEST 20: use contains op
--- request
GET /=/role/Public/url/A?op=contains
--- response_like
\[
    \{"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"},
    \{"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"}
\]



=== TEST 21: Query by method value GET
--- request
GET /=/role/Public/method/GET
--- response_like
\[{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"}\]



=== TEST 22: Query by method value POST
--- request
GET /=/role/Public/method/POST
--- response_like
\[
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]



=== TEST 23: Query by method value POST
--- request
GET /=/role/Public/~/POST
--- response_like
\[
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]



=== TEST 24: Switch to the Public role
--- request
GET /=/login/.Public
--- response
{"error":"Bad user name: \".Public\"","success":0}



=== TEST 25: Switch to the Public role
--- request
GET /=/login/$TestAccount.Public?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Public","session":"[-\w]+","success":1}$



=== TEST 26: Create model A
--- request
POST /=/model/~
{"columns":[{"name":"title","type":"text", "label":"name"}],"description":"A","name":"A"}
--- response
{"success":1}



=== TEST 27: Create model B
--- request
POST /=/model/B
{"description":"B","columns":[
    {"label":"title","type":"text", "name":"title"},
    {"label":"body","type":"text", "name":"body"}
 ]
}
--- response
{"success":1}



=== TEST 28: Get model list
--- request
GET /=/model
--- response
[
    {"description":"A","name":"A","src":"/=/model/A"},
    {"description":"B","name":"B","src":"/=/model/B"}
]



=== TEST 29: Delete the models
--- request
DELETE /=/model
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 30: Put to models
--- request
PUT /=/model
""
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 31: Get an individual model (not in rules)
--- request
GET /=/model/A
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 32: Use the other form
--- request
GET /=/model/~
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 33: Read the column
--- request
GET /=/model/A/~
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 34: Read the column (be explicit)
--- request
GET /=/model/A/title
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 35: Try to remove the column
--- request
DELETE /=/model/A/title
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 36: Insert rows
--- request
POST /=/model/A/~/~
[ {"title":"Larry"}, {"title":"Patrick"}, {"title":"Audrey"} ]
--- response
{"last_row":"/=/model/A/id/3","rows_affected":3,"success":1}



=== TEST 37: Get the rows
--- request
GET /=/model/A/~/~
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 38: Get a single row
--- request
GET /=/model/A/id/3
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 39: Delete rows
--- request
DELETE /=/model/A/~/~
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 40: Delete rows
--- request
DELETE /=/model/A/title/Audrey
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 41: Update a row
--- request
PUT /=/model/A/id/3
{"title":"fglock"}
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 42: Delete a row
--- request
DELETE /=/model/A/id/3
--- response
{"rows_affected":1,"success":1}



=== TEST 43: Delete a row again
--- request
DELETE /=/model/A/id/3
--- response
{"rows_affected":0,"success":1}



=== TEST 44: Delete all the rows
--- request
DELETE /=/model/A/id/~
--- response
{"rows_affected":2,"success":1}



=== TEST 45: Delete all the rows in model B
--- request
DELETE /=/model/B/id/~
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 46: Add a new column to A
--- request
POST /=/model/A/foo
{"label":"foo"}
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 47: Delete the newly added column
--- request
DELETE /=/model/A/bar
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 48: Get the view list
--- request
GET /=/view
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 49: Try to create a view
--- request
POST /=/view/MyView
{"body":"select * from A"}
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 50: Switch back to the Admin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 51: Check the records in A
--- request
GET /=/model/A/~/~
--- response
[]



=== TEST 52: Create a new role w/o description
--- request
POST /=/role/Poster
{
    "login": "password",
    "password": "$TestPass"
}
--- response
{"error":"Field 'description' is missing.","success":0}



=== TEST 53: Create a new role w/o login
--- request
POST /=/role/Poster
{
    "description":"Comment poster"
}
--- response
{"error":"No 'login' field specified.","success":0}



=== TEST 54: Create a new role w/o password
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "password"
}
--- response
{"error":"No password given when 'login' is 'password'.","success":0}



=== TEST 55: unknown login method
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "blah"
}
--- response
{"error":"Unknown login method: blah","success":0}



=== TEST 56: blank password not allowed
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "password",
    "password": ""
}
--- response
{"error":"Password too short; at least 6 chars required.","success":0}



=== TEST 57: too short password not allowed
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "password",
    "password": "12345"
}
--- response
{"error":"Password too short; at least 6 chars required.","success":0}



=== TEST 58: Create a new role in the right way
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "password",
    "password": "4417935"
}
--- response
{"success":1}



=== TEST 59: Create the same role for a second time
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "password",
    "password": "4417935"
}
--- response
{"error":"Role \"Poster\" already exists.","success":0}



=== TEST 60: Add a rule to read model list
--- request
POST /=/role/Poster/~/~
{"url":"/=/model"}
--- response_like
\{"last_row":"/=/role/Poster/id/\d+","rows_affected":1,"success":1\}



=== TEST 61: Add a rule to insert new rows to A (missing column 'url')
--- request
POST /=/role/Poster/~/~
{"method":"POST","src":"/=/model/A/~/~"}
--- response
{"error":"row 1: Column \"url\" is missing.","success":0}



=== TEST 62: Add a rule to insert new rows to A (the right way)
--- request
POST /=/role/Poster/~/~
{"method":"POST","url":"/=/model/A/~/~"}
--- response_like
^\{"last_row":"/=/role/Poster/id/\d+"\,"rows_affected":1,"success":1}$



=== TEST 63: Check the rule list
--- request
GET /=/role/Poster/~/~
--- response_like
^\[
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]$



=== TEST 64: Log into the new role
--- request
GET /=/login/$TestAccount.Poster
--- response
{"error":"$TestAccount.Poster is not anonymous.","success":0}



=== TEST 65: Log into the new role
--- request
GET /=/login/$TestAccount.Poster/4417935?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Poster","session":"[-\w]+","success":1}$



=== TEST 66: Try to do something
--- request
GET /=/model
--- response
[
    {"description":"A","name":"A","src":"/=/model/A"},
    {"description":"B","name":"B","src":"/=/model/B"}
]



=== TEST 67: Try to get model list by another way
--- request
GET /=/model/~
--- response
{"error":"Permission denied for the \"Poster\" role.","success":0}



=== TEST 68: Try to create a new model
--- request
POST /=/model/C
{ "description": "C" }
--- response
{"error":"Permission denied for the \"Poster\" role.","success":0}



=== TEST 69: Try to access minisql
--- request
POST /=/action/.Select/lang/minisql
"select * from A"
--- response
{"error":"Permission denied for the \"Poster\" role.","success":0}



=== TEST 70: Try to delete itself
--- request
DELETE /=/role/Poster
--- response
{"error":"Permission denied for the \"Poster\" role.","success":0}



=== TEST 71: Switch back to the Amin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 72: Drop the Poster role
--- request
DELETE /=/role/Poster
--- response
{"success":1}



=== TEST 73: Access the Poster role again
--- request
GET /=/role/Poster
--- response
{"error":"Role \"Poster\" not found.","success":0}



=== TEST 74: Try to drop the Admin role
--- request
DELETE /=/role/Admin
--- response
{"error":"Role \"Admin\" reserved.","success":0}



=== TEST 75: Access the Admin role again
--- request
GET /=/role/Admin
--- response
{
    "columns":[
        {"label":"HTTP method","name":"method","type":"text"},
        {"label":"Resource","name":"url","type":"text"}
    ],
    "name":"Admin",
    "description":"Administrator",
    "login":"password"
}



=== TEST 76: Try to drop the Public role
--- request
DELETE /=/role/Public
--- response
{"error":"Role \"Public\" reserved.","success":0}



=== TEST 77: Access the Public role again
--- request
GET /=/role/Public
--- response
{
    "columns":[
        {"label":"HTTP method","name":"method","type":"text"},
        {"label":"Resource","name":"url","type":"text"}
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
    \{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/~"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"},
    {"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"}
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
    \{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"}
\]



=== TEST 81: Try to update id of rule in Public
--- request
PUT /=/role/Public/id/~
{ "id": "521" }
--- response
{"error":"Column \"id\" reserved.","success":0}



=== TEST 82: Update urls of rules
--- request
PUT /=/role/Public/method/GET
{ "url": "/=/model/A/~" }
--- response
{"success":1}



=== TEST 83: Check the new rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"},
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model/A/~"}
]



=== TEST 84: Update methods of rules
--- request
PUT /=/role/Public/method/GET
{ "method": "POST" }
--- response_like
{"success":1}



=== TEST 85: Check the new rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~"}
]



=== TEST 86: Update methods & urls of rules
--- request
PUT /=/role/Public/method/POST
{ "method": "GET","url": "/=/model" }
--- response_like
{"success":1}



=== TEST 87: Check the new rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"id":"\d+","method":"DELETE","prohibiting":false,"url":"/=/model/A/id/~"},
    \{"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"}
\]



=== TEST 88: Create a new role in the right way
--- request
POST /=/role/Poster
{
    "description":"Comment poster",
    "login": "password",
    "password": "4417935"
}
--- response
{"success":1}



=== TEST 89: get 'Poster' role
--- request
GET /=/role/Poster
--- response
{
  "columns":[
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
  ],
  "name":"Poster",
  "description":"Comment poster",
  "login":"password"
}



=== TEST 90: Add a rule to read model list
--- request
POST /=/role/Poster/~/~
{"url":"/=/model"}
--- response_like
\{"last_row":"/=/role/Poster/id/\d+"\,"rows_affected":1,"success":1}



=== TEST 91: Add a rule to insert new rows to A (the right way)
--- request
POST /=/role/Poster/~/~
{"method":"POST","url":"/=/model/A/~/~"}
--- response_like
^\{"last_row":"/=/role/Poster/id/\d+"\,"rows_affected":1,"success":1}$



=== TEST 92: Check the rule list
--- request
GET /=/role/Poster/~/~
--- response_like
^\[
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]$



=== TEST 93: update the name
--- request
PUT /=/role/Poster
{
    "name":"Newposter"
}
--- response
{"success":1}



=== TEST 94: Get the 'Poster' role
--- request
GET /=/role/Poster
--- response
{"error":"Role \"Poster\" not found.","success":0}



=== TEST 95: Get the role list
--- request
GET /=/role
--- response
[
    {"description":"Administrator","name":"Admin","src":"/=/role/Admin"},
    {"description":"Anonymous","name":"Public","src":"/=/role/Public"},
    {"description":"Comment poster","name":"Newposter","src":"/=/role/Newposter"}
]



=== TEST 96: get 'Newposter' role
--- request
GET /=/role/Newposter
--- response
{
  "columns":[
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
  ],
  "name":"Newposter",
  "description":"Comment poster",
  "login":"password"
}



=== TEST 97: Check the rule list
--- request
GET /=/role/Newposter/~/~
--- response_like
^\[
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]$



=== TEST 98: update the description
--- request
PUT /=/role/Newposter
{
    "description":"my description"
}
--- response
{"success":1}



=== TEST 99: get 'Newposter' role
--- request
GET /=/role/Newposter
--- response
{
  "columns":[
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
  ],
  "name":"Newposter",
  "description":"my description",
  "login":"password"
}



=== TEST 100: update the name and the description
--- request
PUT /=/role/Newposter
{
    "name":"Newname",
    "description":"Newdescription"
}
--- response
{"success":1}



=== TEST 101: get 'Newname' role
--- request
GET /=/role/Newname
--- response
{
  "columns":[
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
  ],
  "name":"Newname",
  "description":"Newdescription",
  "login":"password"
}



=== TEST 102: Check the rule list
--- request
GET /=/role/Newname/~/~
--- response_like
^\[
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]$



=== TEST 103: update the password when login == password
--- request
PUT /=/role/Newname
{
    "password":"123456789"
}
--- response
{"success":1}



=== TEST 104: login with the new role
--- request
GET /=/login/$TestAccount.Newname/123456789
--- response_like
^{"account":"$TestAccount","role":"Newname","session":"[-\w]+","success":1}$



=== TEST 105: Switch back to the Amin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 106: update the login(normal)
--- request
PUT /=/role/Newname
{
    "login":"captcha"
}
--- response
{"success":1}



=== TEST 107: get 'Newname' role
--- request
GET /=/role/Newname
--- response
{
  "columns":[
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
  ],
  "name":"Newname",
  "description":"Newdescription",
  "login":"captcha"
}



=== TEST 108: Check the rule list
--- request
GET /=/role/Newname/~/~
--- response_like
^\[
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]$



=== TEST 109: test the validity of login
--- request
PUT /=/role/Newname
{
    "login":{"blah":"blah"}
}
--- response
{"error":"Bad login method: {\"blah\":\"blah\"}","success":0}



=== TEST 110: test the validity of login
--- request
PUT /=/role/Newname
{
    "login":[1234]
}
--- response
{"error":"Bad login method: [1234]","success":0}



=== TEST 111: test the validity of login
--- request
PUT /=/role/Newname
{
    "login":"blah"
}
--- response
{"error":"Bad login method: blah","success":0}



=== TEST 112: test the validity of description
--- request
PUT /=/role/Newname
{
    "description":{"blah":"blah"}
}
--- response
{"error":"Bad role definition: {\"blah\":\"blah\"}","success":0}



=== TEST 113: test the validity of description
--- request
PUT /=/role/Newname
{
    "description":[1234]
}
--- response
{"error":"Bad role definition: [1234]","success":0}



=== TEST 114: test the validity of description
--- request
PUT /=/role/Newname
{
    "description":"blah"
}
--- response
{"success":1}



=== TEST 115: try to update the password when login != password
--- request
PUT /=/role/Newname
{
    "password":"987654321"
}
--- response
{"success":1}



=== TEST 116: update all the info
--- request
PUT /=/role/Newname
{
    "name":"Poster",
    "description":"Comment poster",
    "login":"password",
    "password":"4417935"
}
--- response
{"success":1}



=== TEST 117: get 'Poster' role
--- request
GET /=/role/Poster
--- response
{
  "columns":[
    {"label":"HTTP method","name":"method","type":"text"},
    {"label":"Resource","name":"url","type":"text"}
  ],
  "name":"Poster",
  "description":"Comment poster",
  "login":"password"
}



=== TEST 118: Check the rule list
--- request
GET /=/role/Poster/~/~
--- response_like
^\[
    {"id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"},
    {"id":"\d+","method":"POST","prohibiting":false,"url":"/=/model/A/~/~"}
\]$



=== TEST 119: test for the login and the password(1/10)
--- request
PUT /=/role/Poster
{
    "login":"password",
    "password":"123456789"
}
--- response
{"success":1}



=== TEST 120: login with the new password
--- request
GET /=/login/$TestAccount.Poster/123456789
--- response_like
^{"account":"$TestAccount","role":"Poster","session":"[-\w]+","success":1}$



=== TEST 121: Switch back to the Amin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 122: test for the login and the password(2/10)
--- request
PUT /=/role/Poster
{
    "password":"789456213"
}
--- response
{"success":1}



=== TEST 123: login with the new password
--- request
GET /=/login/$TestAccount.Poster/789456213
--- response_like
^{"account":"$TestAccount","role":"Poster","session":"[-\w]+","success":1}$



=== TEST 124: Switch back to the Amin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 125: test for the login and the password(3/10)
--- request
PUT /=/role/Poster
{
    "login":"password"
}
--- response
{"error":"No password given when 'login' is 'password'.","success":0}



=== TEST 126: test for the login and the password(4/10)
--- request
PUT /=/role/Poster
{
    "login":"captcha",
    "password":"123456789"
}
--- response
{"error":"Password given when 'login' is not 'password'.","success":0}



=== TEST 127: test for the login and the password(5/10)
--- request
PUT /=/role/Poster
{
    "login":"captcha"
}
--- response
{"success":1}



=== TEST 128: test for the login and the password(6/10)
--- request
PUT /=/role/Poster
{
    "password":"456978321"
}
--- response
{"success":1}



=== TEST 129: test for the login and the password(7/10)
--- request
PUT /=/role/Poster
{
    "login":"captcha",
    "password":"321987465"
}
--- response
{"error":"Password given when 'login' is not 'password'.","success":0}



=== TEST 130: test for the login and the password(8/10)
--- request
PUT /=/role/Poster
{
    "login":"anonymous"
}
--- response
{"success":1}



=== TEST 131: test for the login and the password(9/10)
--- request
PUT /=/role/Poster
{
    "login":"password"
}
--- response
{"error":"No password given when 'login' is 'password'.","success":0}



=== TEST 132: test for the login and the password(10/10)
--- request
PUT /=/role/Poster
{
    "login":"password",
    "password":"shangerdi"
}
--- response
{"success":1}



=== TEST 133: login with the new password
--- request
GET /=/login/$TestAccount.Poster/shangerdi
--- response_like
^{"account":"$TestAccount","role":"Poster","session":"[-\w]+","success":1}$



=== TEST 134: Switch back to the Amin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 135: test the validity of the password
--- request
PUT /=/role/Poster
{
    "password":"shangerdi1984"
}
--- response
{"success":1}



=== TEST 136: test the validity of the password
--- request
PUT /=/role/Poster
{
    "password":"_1984"
}
--- response
{"error":"Password too short; at least 6 chars are required.","success":0}
--- SKIP



=== TEST 137: test the validity of the password
--- request
PUT /=/role/Poster
{
    "password":"_1984_1984"
}
--- response
{"success":1}



=== TEST 138: test the validity of the password
--- request
PUT /=/role/Poster
{
    "password":"shang_erdi"
}
--- response
{"success":1}



=== TEST 139: test the validity of the password
--- request
PUT /=/role/Poster
{
    "password":"SHANG1984_shangerdi_1984_shang_er_di_19841984"
}
--- response
{"success":1}



=== TEST 140: login with the new password
--- request
GET /=/login/$TestAccount.Poster/SHANG1984_shangerdi_1984_shang_er_di_19841984
--- response_like
^{"account":"$TestAccount","role":"Poster","session":"[-\w]+","success":1}$



=== TEST 141: Switch back to the Amin role
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



=== TEST 142: Drop the Poster role
--- request
DELETE /=/role/Poster
--- response
{"success":1}



=== TEST 143: logout
--- request
GET /=/logout
--- response
{"success":1}

