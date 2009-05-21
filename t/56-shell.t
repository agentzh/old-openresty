# vi:filetype=

use t::OpenResty ($ENV{USER} && $ENV{USER} ne 'agentz') ? (skip_all => $skip) : ();

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: prog list
list all executables in PATH
--- request
GET /=/shell
--- response_like
^\[.*?awk.*?diff.*?grep.*?ls.*?mkdir.*?mv.*?\]$



=== TEST 2: prog path inspecting (where is diff?)
--- request
GET /=/shell/diff
--- response
"/usr/bin/diff"



=== TEST 3: prog path inspecting (where is ls?)
--- request
GET /=/shell/ls
--- response
"/bin/ls"



=== TEST 4: prog run (ls -l)
--- request
GET /=/shell/ls/~/~?l=""
--- response_like
^"total \d+



=== TEST 5: params take arguments
--- request
GET /=/shell/perl/e/print("hello,world")
--- response
"hello,world"

