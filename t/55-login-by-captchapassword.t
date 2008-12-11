# vi:filetype=

use OpenResty::Config;
#use t::OpenResty 'no_plan';
my $reason;
BEGIN {
    OpenResty::Config->init;
    if ($OpenResty::Config{'backend.type'} eq 'PgMocked' ||
        $OpenResty::Config{'backend.recording'}) {
        $reason = 'Skipped in PgMocked or recording mode.';
    }
}
use t::OpenResty $reason ? (skip_all => $reason) : ('no_plan');
if ($reason) { return; }

run_tests;

__DATA__

=== TEST 1: Login as Admin
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 2: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 3: Delete existing roles
--- request
DELETE /=/role
--- response
{"success":1,"warning":"Predefined roles skipped."}



=== TEST 4: Create an account with 'captcha+password' login method
--- request
POST /=/role/Poster
{ "description":"Poster", "login":"captcha+password" }
--- response
{"error":"No password given when 'login' is 'captcha+password'.","success":0}



=== TEST 5: Create an account with 'captcha+password' login method
--- request
POST /=/role/Poster
{ "description":"Poster", "login":"captcha+password", "password": "abcdef" }
--- response
{"success":1}



=== TEST 6: Add permission to GET model list
--- request
POST /=/role/Poster/~/~
{"url":"/=/model"}
--- response_like
^{"success":1,"rows_affected":1,"last_row":"/=/role/Poster/id/\d+"}$



=== TEST 7: Get a new captcha ID
--- request
GET /=/captcha/id
--- response_like
^"([0-9a-zA-Z._-]+)"$



=== TEST 8: Get the image
--- res_type: image/png
--- request
GET /=/captcha/id/$SavedCapture
--- response_like
.



=== TEST 9: Use captcha but no pasword to login
--- sleep_before: 1
--- request
GET /=/model?_user=$TestAccount.Poster&_captcha=$SavedCapture:helloworld
--- response
{"error":"Cannot login as $TestAccount.Poster via captchas.","success":0}


=== TEST 10: Use captcha and pasword to login
--- sleep_before: 1
--- request
GET /=/model?_user=$TestAccount.Poster&_captcha=$SavedCapture:helloworld&_password=abcdef
--- response
[]



=== TEST 11: logout
--- request
GET /=/logout
--- response
{"success":1}

