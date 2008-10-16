# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Get the version info
--- request
GET /=/version
--- response_like
^"\d+\.\d+\.\d+"$



=== TEST 2: Get the version info
--- request
GET /=/version/more
--- response_like
^"OpenResty \d+\.\d+\.\d+ \(revision (?:Unknown|\d+)\) with the (?:\w+) (?:\([-\w]+\) )?backend\.\\nCopyright \(c\) 2007-2008 by Yahoo! China EEEE Works, Alibaba Inc\.\\n"$



=== TEST 3: Another way
--- request
GET /=/
--- response_like
^"\d+\.\d+\.\d+"$



=== TEST 4: Another way using YAML with _callback
--- request
GET /=/version.yml?_callback=foo
--- response_like
^foo\("--- \d+\.\d+\.\d+"\);$



=== TEST 5: Another way using YAML with _var
--- request
GET /=/version.yml?_var=foo
--- response_like
^foo="--- \d+\.\d+\.\d+";$

