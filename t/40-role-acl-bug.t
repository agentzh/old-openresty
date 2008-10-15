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



=== TEST 2: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 3: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 4: Create a reader role
--- request
POST /=/role/Reader
{"description":"reader only role",
"login":"password",
"password": "hello1234" }
--- response
{"success":1}



=== TEST 5: Add the rules
--- request
POST /=/role/Reader/~/~
[
{"url":"/=/~"},
{"url":"/=/~/~"},
{"url":"/=/~/~/~"},
{"url":"/=/~/~/~/~"},
{"url":"/=/action/RunView/~/~"}
]
--- response_like
\{"success":1,"rows_affected":5,"last_row":"/=/role/Reader/id/\d+"\}



=== TEST 6: logout
--- request
GET /=/logout
--- response
{"success":1}



=== TEST 7: query the model list
--- request
GET /=/model?_user=$TestAccount.Reader&_password=hello1234&_use_cookie=1
--- response
[]



=== TEST 8: query the model Foo
--- request
GET /=/model/Foo
--- response
{"error":"Model \"Foo\" not found.","success":0}



=== TEST 9: query the view list
--- request
GET /=/view
--- response
[]



=== TEST 10: Add another rule
--- request
POST /=/role/Reader/~/~?_user=$TestAccount.Admin&_password=$TestPass&_use_cookie=1
{"url":"/=/model/Foo","prohibiting":true}
--- response_like
{"success":1,"rows_affected":1,"last_row":"/=/role/Reader/id/\d+"}



=== TEST 11: Check the rule list
--- request
GET /=/role/Reader/~/~
--- response_like
[
    {"url":"/=/~","prohibiting":false,"method":"GET","id":"\d+"},
    {"url":"/=/~/~","prohibiting":false,"method":"GET","id":"\d+"},
    {"url":"/=/~/~/~","prohibiting":false,"method":"GET","id":"\d+"},
    {"url":"/=/~/~/~/~","prohibiting":false,"method":"GET","id":"\d+"},
    {"url":"/=/action/RunView/~/~","prohibiting":false,"method":"GET","id":"\d+"},
    {"url":"/=/model/Foo","prohibiting":true,"method":"GET","id":"\d+"}
]



=== TEST 12: query the model list
--- request
GET /=/model?_user=$TestAccount.Reader&_password=hello1234&_use_cookie=1
--- response
[]



=== TEST 13: query the model Foo
--- request
GET /=/model/Foo
--- response
{"error":"Permission denied for the \"Reader\" role.","success":0}



=== TEST 14: query the view list
--- request
GET /=/view
--- response
[]



=== TEST 15: remove all the roles
--- request
DELETE /=/role?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 16: Create the Reader role again
--- request
POST /=/role/Reader
{"description":"reader only role",
"login":"password",
"password": "hello1234" }
--- response
{"success":1}



=== TEST 17: Use a password to sign in as Public
--- request
GET /=/role/Reader?_user=$TestAccount.Public&_password=blah
--- response
{"success":0,"error":"Password for $TestAccount.Public is incorrect."}



=== TEST 18: logout
--- request
GET /=/logout
--- response
{"success":1}

