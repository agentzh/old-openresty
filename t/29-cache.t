# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: clean env via user A
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass
--- response
{"success":1}



=== TEST 2: clean env via user A
--- request
DELETE /=/view?user=$TestAccount&password=$TestPass
--- response_like
{"success":1}



=== TEST 3: clean env via user B
--- request
DELETE /=/model?user=$TestAccount2&password=$TestPass2
--- response
{"success":1}



=== TEST 4: clean env via user B
--- request
DELETE /=/view?user=$TestAccount2&password=$TestPass2
--- response
{"success":1}



=== TEST 5: Create a new model in A
--- request
POST /=/model/Foo?user=$TestAccount&password=$TestPass
{ "description": "Foo" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Foo\"."}



=== TEST 6: Get model Foo in A
--- request
GET /=/model/Foo?user=$TestAccount&password=$TestPass
--- response
{"columns":
    [
        {"label":"ID","name":"id","type":"serial"}
    ],
    "description":"Foo","name":"Foo"}



=== TEST 7: Create a new model in B
--- request
POST /=/model/Foo?user=$TestAccount2&password=$TestPass2
{ "description": "Foo" }
--- response
{"success":1,"warning":"No 'columns' specified for model \"Foo\"."}



=== TEST 5: Create a new view in A
--- request
POST /=/view/Foo?user=$TestAccount&password=$TestPass
{ "definition": "select 3" }
--- response
{"success":1}


=== TEST 6: Get the view in A
--- request
GET /=/view/Foo?user=$TestAccount&password=$TestPass
--- response
{"name":"Foo","description":null,"definition":"select 3"}


=== TEST 7: Create a new view in B
--- request
POST /=/view/Foo?user=$TestAccount2&password=$TestPass2
{ "definition": "select 3" }
--- response
{"success":1}

