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
.



=== TEST 3: get the captcha image using the ID (stripping .gif)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.gif
--- response_like
.



=== TEST 4: get the captcha image using the ID (stripping .jpeg)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg
--- response_like
.



=== TEST 5: get the captcha image using the ID (cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=cn
--- response_like
.



=== TEST 6: get the captcha image using the ID (Cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=Cn
--- response_like
.



=== TEST 7: get the captcha image using the ID (en)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=en
--- response_like
.



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
GET /=/login/peee.Admin/4423037?use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"peee","role":"Admin"}$



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



=== TEST 27: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 28: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 29: Get a new captcha ID
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 30: Use captcha to login
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:helloworld
--- response
[]



=== TEST 31: Use captcha to login
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:helloworld
--- response
{"success":0,"error":"Capture ID is bad or expired."}



=== TEST 32: Get a new captcha ID
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
{"success":0,"error":"Invalid captcha ID: \w+(?:-\w+)+"}



=== TEST 33: Use captcha to login
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:helloworld
--- response
{"success":0,"error":"Capture ID is bad or expired."}



=== TEST 34: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 35: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=en
--- response_like
.



=== TEST 36: Use captcha to login (wrong password)
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:helloworldd
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}



=== TEST 37: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 38: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=cn
--- response_like
.



=== TEST 39: Use captcha to login
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:你好，世界！
--- response
[]



=== TEST 40: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 41: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=cn
--- response_like
.



=== TEST 42: Use captcha to login (wrong solution)
--- request
GET /=/model?user=peee.Poster&captcha=$SavedCapture:你好，世界啊！
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}

