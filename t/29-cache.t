# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: clean env via user A
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass
--- response
{"success":1}



=== TEST 2: clean env via user A
--- request
DELETE /=/view?_user=$TestAccount&_password=$TestPass
--- response_like
{"success":1}



=== TEST 3: clean env via user B
--- request
DELETE /=/model?_user=$TestAccount2&_password=$TestPass2
--- response
{"success":1}



=== TEST 4: clean env via user B
--- request
DELETE /=/view?_user=$TestAccount2&_password=$TestPass2
--- response
{"success":1}



=== TEST 5: Create a new model in A
--- request
POST /=/model/Foo?_user=$TestAccount&_password=$TestPass
{ "description": "Foo" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Foo\"."}



=== TEST 6: Get model Foo in A
--- request
GET /=/model/Foo?_user=$TestAccount&_password=$TestPass
--- response
{"columns":
    [
        {"label":"ID","name":"id","type":"serial"}
    ],
    "description":"Foo","name":"Foo"}



=== TEST 7: Create a new model in B
--- request
POST /=/model/Foo?_user=$TestAccount2&_password=$TestPass2
{ "description": "Foo" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Foo\"."}



=== TEST 8: Create a new view in A
--- request
POST /=/view/Foo?_user=$TestAccount&_password=$TestPass
{ "definition": "select 3" }
--- response
{"success":1}



=== TEST 9: Get the view in A
--- request
GET /=/view/Foo?_user=$TestAccount&_password=$TestPass
--- response
{"name":"Foo","description":null,"definition":"select 3"}



=== TEST 10: Create a new view in B
--- request
POST /=/view/Foo?_user=$TestAccount2&_password=$TestPass2
{ "definition": "select 3" }
--- response
{"success":1}



=== TEST 11: logout
--- request
GET /=/logout
--- response
{"success":1}

