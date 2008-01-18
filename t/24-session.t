# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login w/o cookie
--- request
GET /=/login/peee.Admin/4423037
--- response_like
^{"success":1,"session":"([-\w]+)","account":"peee","role":"Admin"}$



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
GET /=/login/peee.Admin/4423037?use_cookie=0
--- response_like
^{"success":1,"session":"([-\w]+)","account":"peee","role":"Admin"}$



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



