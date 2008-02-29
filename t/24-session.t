# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login w/o cookie
--- request
GET /=/login/$TestAccount.Admin/$TestPass
--- response_like
^{"success":1,"session":"([-\w]+)","account":"$TestAccount","role":"Admin"}$



=== TEST 2: Delete existing models (w/o session)
--- request
DELETE /=/model.js
--- response
{"success":0,"error":"Login required."}



=== TEST 3: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":1}



=== TEST 4: Login w/o cookie(obvious)
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=0
--- response_like
^{"success":1,"session":"([-\w]+)","account":"$TestAccount","role":"Admin"}$



=== TEST 5: Delete existing models (w/o session)
--- request
DELETE /=/model.js
--- response
{"success":0,"error":"Login required."}



=== TEST 6: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":1}



=== TEST 7: Login with cookie
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
--- response_like
^{"success":1,"session":"([-\w]+)","account":"$TestAccount","role":"Admin"}$



=== TEST 8: Delete existing models (w/o session)
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 9: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":1}



=== TEST 10: Logout
--- request
GET /=/logout
--- response
{"success":1}



=== TEST 11: Delete existing models after logout(w/o session)
--- request
DELETE /=/model.js
--- response
{"success":0,"error":"Login required."}



=== TEST 12: Login with cookie
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
--- response_like
^{"success":1,"session":"([-\w]+)","account":"$TestAccount","role":"Admin"}$



=== TEST 13: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":1}



=== TEST 14: Logout
--- request
GET /=/logout
--- response
{"success":1}



=== TEST 15: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":0,"error":"Login required."}



=== TEST 16: Login w/o cookie(obvious)
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=0
--- response_like
^{"success":1,"session":"([-\w]+)","account":"$TestAccount","role":"Admin"}$



=== TEST 17: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":1}



=== TEST 18: Logout
--- request
GET /=/logout
--- response
{"success":1}



=== TEST 19: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":1}



=== TEST 20: Logout
--- request
GET /=/logout?session=$SavedCapture
--- response
{"success":1}



=== TEST 21: Delete existing models (session)
--- request
DELETE /=/model.js?session=$SavedCapture
--- response
{"success":0,"error":"Login required."}

