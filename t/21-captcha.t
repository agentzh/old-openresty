# vi:filetype=

use t::OpenResty 'no_plan';

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



=== TEST 5: get the captcha image using the ID (en)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=en
--- response_like
.



=== TEST 6: get the captcha image using the ID (En)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=En
--- response_like
.



=== TEST 7: get the captcha image using the ID (cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=cn
--- response_like
.
--- use_ttf: 1



=== TEST 8: get the captcha image using the ID (Cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=Cn
--- response_like
.
--- use_ttf: 1



=== TEST 9: get the captcha image using the ID (en)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=en
--- response_like
.



=== TEST 10: get the captcha image using the ID (fr)
--- request
GET /=/captcha/id/$SavedCapture.jpeg?lang=fr
--- response
{"success":0,"error":"Unsupported lang (only cn and en allowed): fr"}



=== TEST 11: Login via captcha (invalid format, id only)
--- request
GET /=/model?user=$TestAccount.Admin&captcha=$SavedCapture
--- response_like
{"success":0,"error":"Bad captcha parameter: \w+(?:-\w+)+"}



=== TEST 12: Login via captcha (invalid format, id only)
--- request
GET /=/model?user=$TestAccount.Admin&captcha=$SavedCapture:abc
--- response_like
{"success":0,"error":"Cannot login as $TestAccount.Admin via captchas."}



=== TEST 13: Login as Admin
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 14: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 15: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 16: Create an account with 'captcha' login method
--- request
POST /=/role/Poster
{ description:"Poster", login:"captcha" }
--- response
{"success":1}



=== TEST 17: Add permission to GET model list
--- request
POST /=/role/Poster/~/~
{url:"/=/model"}
--- response_like
^{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"}$



=== TEST 18: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 19: Login via captcha (not get the image yet)
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:abc
--- response
{"success":0,"error":"Captcha image never used."}



=== TEST 20: Login via captcha (the second time)
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:abc
--- response
{"success":0,"error":"Capture ID is bad or expired."}



=== TEST 21: get the captcha image using the ID (already expired)
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
^{"success":0,"error":"Invalid captcha ID: \w+(?:-\w+)+"}$



=== TEST 22: get the captcha image using the ID (already expired)
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
^{"success":0,"error":"Invalid captcha ID: \w+(?:-\w+)+"}$



=== TEST 23: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 24: Get a new one again
--- request
GET /=/model
--- response
[]



=== TEST 25: Use the old to try login
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:efg
--- response
{"success":0,"error":"Captcha image never used."}



=== TEST 26: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 27: Get a new captcha ID for a second time
--- request
GET /=/captcha/id
--- response_like
^"(?:\w+(?:-\w+){3,})"$



=== TEST 28: Use the old ID to try login
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:efg
--- response
{"error":"Captcha image never used.","success":0}



=== TEST 29: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 30: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 31: Get a new captcha ID
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 32: Use captcha to login
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworld
--- response
[]



=== TEST 33: Use captcha to login
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworld
--- response
{"success":0,"error":"Capture ID is bad or expired."}



=== TEST 34: Get a new captcha ID
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
{"success":0,"error":"Invalid captcha ID: \w+(?:-\w+)+"}



=== TEST 35: Use captcha to login
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworld
--- response
{"success":0,"error":"Capture ID is bad or expired."}



=== TEST 36: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 37: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=en
--- response_like
.



=== TEST 38: Use captcha to login (wrong password)
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworldd
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}



=== TEST 39: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 40: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=cn
--- response_like
.
--- use_ttf: 1



=== TEST 41: Use captcha to login
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:你好，世界！
--- response
[]
--- use_ttf: 1



=== TEST 42: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"(\w+(?:-\w+){3,})"$



=== TEST 43: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=en
--- response_like
.



=== TEST 44: Use captcha to login (wrong solution)
buggy in PgMocked...
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:你好，世界啊！
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}
--- use_ttf: 1


