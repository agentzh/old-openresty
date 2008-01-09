# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Get the version info
--- request
GET /=/version
--- response_like
^"OpenAPI \d+\.\d+\.\d+ \(revision \d+\)\\nCopyright \(c\) 2007-2008 Yahoo! China EEEE\\n"$

