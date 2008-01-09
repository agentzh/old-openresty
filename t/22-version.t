# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Get the version info
--- request
GET /=/version
--- response
"OpenAPI 1.0.0\nCopyright (c) 2007-2008 Yahoo! China EEEE\n"

