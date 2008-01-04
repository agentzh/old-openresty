# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Get the captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 2: get the captcha image using the ID
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.{100}



=== TEST 3: get the captcha image using the ID (stripping .gif)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.gif
--- response_like
.{100}



=== TEST 4: get the captcha image using the ID (stripping .jpeg)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg
--- response_like
.{100}



=== TEST 5: get the captcha image using the ID (cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=cn
--- response_like
.{100}



=== TEST 6: get the captcha image using the ID (Cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=Cn
--- response_like
.{100}



=== TEST 7: get the captcha image using the ID (en)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=en
--- response_like
.{100}



=== TEST 8: get the captcha image using the ID (fr)
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=fr
--- response
{"success":0,"error":"Unsupported lang (only cn and en allowed): fr"}



=== TEST 9: Login via captcha (invalid format, id only)
--- request
GET /=/model?user=peee.Admin&captcha=$SavedCapture
--- response_like
{"success":0,"error":"Bad captcha parameter: \w+(?:-\w+)+"}



=== TEST 10: Login via captcha (invalid format, id only)
--- request
GET /=/model?user=peee.Admin&captcha=$SavedCapture:abc
--- response_like
{"success":0,"error":"Cannot login as peee.Admin via captchas."}



=== TEST 11: Login as Admin
--- request
GET /=/login/peee.Admin/4423037
--- response
{"success":1,"account":"peee","role":"Admin"}



=== TEST 12: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 13: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 14: Create an account with 'captcha' login method
--- request
POST /=/role/Poster
{ description:"Poster", login:"captcha" }
--- response
{"success":1}



=== TEST 15: Add permission to GET model list
--- request
POST /=/role/Poster/~/~
{url:"/=/model"}
--- response_like
^{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"}$



=== TEST 16: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 17: Login via captcha (not get the image yet)
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:abc
--- response
{"success":0,"error":"Captcha image never used."}



=== TEST 18: Login via captcha (the second time)
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:abc
--- response
{"success":0,"error":"Capture ID is bad or expired."}



=== TEST 19: get the captcha image using the ID (already expired)
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
^{"success":0,"error":"Invalid captcha ID: \w+(?:-\w+)+"}$



=== TEST 20: get the captcha image using the ID (already expired)
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
^{"success":0,"error":"Invalid captcha ID: \w+(?:-\w+)+"}$



=== TEST 21: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 22: Get a new one again
--- request
GET /=/model
--- response
[]



=== TEST 23: Use the old to try login
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:efg
--- response
{"success":0,"error":"Captcha image never used."}



=== TEST 24: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 25: Get a new captcha ID for a second time
--- request
GET /=/captcha/id
--- response_like
^"(?:\w+(?:-\w+){3,})"$



=== TEST 26: Use the old ID to try login
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:efg
--- response
{"success":0,"error":"Capture ID is bad or expired."}

