# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: login (w/o password)
--- request
GET /=/captcha/id
--- response
""

