# vi:filetype=

BEGIN {
    use OpenResty::Config;
    OpenResty::Config->init;
    if ($OpenResty::Config{'test_suite.use_http'}) {
        $skip = "Config option test_suite.use_http is set to true, cannot mock cgi's ip address.\n";
        return;
    }
};

use t::OpenResty $skip ? (skip_all => $skip) : ();

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: login
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Admin","session":"[-\w]+","success":1}$



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
    {"description":"Administrator","name":"Admin","src":"/=/role/Admin"},
    {"description":"Anonymous","name":"Public","src":"/=/role/Public"}
]



=== TEST 7: Clear out Public's rules
--- request
DELETE /=/role/Public/~/~
--- response
{"success":1}



=== TEST 8: Get Public's rules
--- request
GET /=/role/Public/~/~
--- response
[]



=== TEST 9: Add a new rule to Public
--- request
POST /=/role/Public/~/~
{"method":"GET","url":"/=/model","applied_to": "192.168.100.0/24"}
--- response_like
"success":1



=== TEST 10: Get the access rules
--- request
GET /=/role/Public/~/~
--- response_like
\[
    {"applied_to":"192\.168\.100\.0/24","id":"\d+","method":"GET","prohibiting":false,"url":"/=/model"}
\]



=== TEST 11: Create model A
--- request
POST /=/model/~
{"columns":[{"name":"title","type":"text", "label":"name"}],"description":"A","name":"A"}
--- response
{"success":1}



=== TEST 12: Create model B
--- request
POST /=/model/B
{"description":"B","columns":[
    {"label":"title","type":"text", "name":"title"},
    {"label":"body","type":"text", "name":"body"}
 ]
}
--- response
{"success":1}



=== TEST 13: Switch to the Public role
--- request
GET /=/login/$TestAccount.Public?_use_cookie=1
--- response_like
^{"account":"$TestAccount","role":"Public","session":"[-\w]+","success":1}$



=== TEST 14: Get model list
--- client_ip
127.0.0.1
--- request
GET /=/model
--- response
[
    {"description":"A","name":"A","src":"/=/model/A"},
    {"description":"B","name":"B","src":"/=/model/B"}
]



=== TEST 15: Get model list
--- client_ip
192.168.100.1
--- request
GET /=/model
--- response
[
    {"description":"A","name":"A","src":"/=/model/A"},
    {"description":"B","name":"B","src":"/=/model/B"}
]



=== TEST 16: Get model list
--- client_ip
192.168.100.100
--- request
GET /=/model
--- response
[
    {"description":"A","name":"A","src":"/=/model/A"},
    {"description":"B","name":"B","src":"/=/model/B"}
]



=== TEST 17: Get model list
--- client_ip
192.168.200.100
--- request
GET /=/model
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 18: Delete the models
--- client_ip
192.168.100.2
--- request
DELETE /=/model
--- response
{"error":"Permission denied for the \"Public\" role.","success":0}



=== TEST 19: logout
--- request
GET /=/logout
--- response
{"success":1}

