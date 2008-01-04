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
--- request
GET /=/captcha/id/$SavedCapture
--- response

