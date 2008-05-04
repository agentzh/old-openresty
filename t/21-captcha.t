# vi:filetype=
use t::OpenResty 'no_plan';

run_tests;

__DATA__

=== TEST 1: Get the captcha ID
--- request
GET /=/captcha/id
--- response_like
^"([0-9a-zA-Z._-]+)"$



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



=== TEST 5: get the captcha ID (en)
--- request
GET /=/captcha/id?lang=en
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 6: get the captcha image using the ID (en)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg
--- response_like
.



=== TEST 7: get the captcha ID (En)
--- request
GET /=/captcha/id?lang=En
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 8: get the captcha image using the ID (En)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg
--- response_like
.



=== TEST 9: get the captcha ID (cn)
--- request
GET /=/captcha/id?lang=cn
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 10: get the captcha image using the ID (cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg
--- response_like
.
--- use_ttf: 1



=== TEST 11: get the captcha ID (Cn)
--- request
GET /=/captcha/id?lang=Cn
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 12: get the captcha image using the ID (Cn)
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture.jpeg
--- response_like
.
--- use_ttf: 1



=== TEST 13: get the captcha ID (fr)
--- request
GET /=/captcha/id?lang=fr
--- response
{"success":0,"error":"Unsupported lang (only cn and en allowed): fr"}



=== TEST 14: Login via captcha (invalid format, id only)
--- request
GET /=/model?user=$TestAccount.Admin&captcha=$SavedCapture
--- response_like
{"success":0,"error":"Bad captcha parameter: [0-9a-zA-Z._-]+"}



=== TEST 15: Login via captcha (invalid format, id only)
--- request
GET /=/model?user=$TestAccount.Admin&captcha=$SavedCapture:abc
--- response_like
{"success":0,"error":"Cannot login as $TestAccount.Admin via captchas."}



=== TEST 16: Login as Admin
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 17: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 18: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 19: Create an account with 'captcha' login method
--- request
POST /=/role/Poster
{ "description":"Poster", "login":"captcha" }
--- response
{"success":1}



=== TEST 20: Add permission to GET model list
--- request
POST /=/role/Poster/~/~
{"url":"/=/model"}
--- response_like
^{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"}$



=== TEST 21: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 22: Login via captcha (wrong solution)
--- sleep_before: 1
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:abc
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}



=== TEST 23: Login via captcha (wrong captcha ID format)
--- request
GET /=/model?user=$TestAccount.Poster&captcha=aa$SavedCapture:abc
--- response
{"success":0,"error":"Captcha ID format is incorrect."}



=== TEST 24: get the captcha image using the ID (invalid format)
--- request
GET /=/captcha/id/aa$SavedCapture
--- response_like
^{"success":0,"error":"Invalid captcha ID: [0-9a-zA-Z._-]+"}$



=== TEST 25: get the captcha image using the ID (already expired)
--- sleep_before: 4
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
^{"success":0,"error":"Captcha ID has expired: [0-9a-zA-Z._-]+"}$



=== TEST 26: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 27: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 28: Use captcha to login
--- sleep_before: 1
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworld
--- response
[]



=== TEST 29: Use captcha to login (use previous succeeded one again)
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworld
--- response
{"success":0,"error":"The captcha has been used."}



=== TEST 30: Get captcha image (use expired succeeded one again)
--- sleep_before: 3
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
{"success":0,"error":"Captcha ID has expired: [0-9a-zA-Z._-]+"}



=== TEST 31: Use captcha to login (use expired succeeded one again)
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworld
--- response
{"success":0,"error":"Captcha ID has expired."}



=== TEST 32: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 33: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture?lang=en
--- response_like
.



=== TEST 34: Use captcha to login (wrong password)
--- sleep_before: 1
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:helloworldd
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}



=== TEST 35: Get a new captcha ID
--- request
GET /=/captcha/id?lang=cn
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 36: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.
--- use_ttf: 1



=== TEST 37: Use captcha to login
--- sleep_before: 1
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:你好，世界！
--- response
[]
--- use_ttf: 1



=== TEST 38: Get a new captcha ID
--- request
GET /=/captcha/id?lang=en
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 39: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 40: Use captcha to login (wrong solution)
buggy in PgMocked...
--- sleep_before: 1
--- request
GET /=/model?user=$TestAccount.Poster&captcha=$SavedCapture:你好，世界啊！
--- response
{"success":0,"error":"Solution to the captcha is incorrect."}
--- use_ttf: 1


