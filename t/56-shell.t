# vi:filetype=

use OpenResty::Config;
my $reason;
BEGIN {
    OpenResty::Config->init({root_path => '.'});
    if ($OpenResty::Config{'frontend.handlers'} !~ /\bShell\b/) {
        $reason = 'Shell handler not enabled in frontend.handlers';
    }
}
use t::OpenResty $reason ? (skip_all => $reason) : ();

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



=== TEST 4: how about an invalid prog name?
--- request
GET /=/shell/something_really_bad
--- response
{"success":0,"error":"Can't find program something_really_bad: "}



=== TEST 5: prog run (ls -l)
--- request
GET /=/shell/ls/~/~?l=""
--- response_like
^"total \d+



=== TEST 6: params take arguments
--- request
GET /=/shell/perl/e/print("hello,world")
--- response
"hello,world"



=== TEST 7: DELETE prog not allowed
--- request
DELETE /=/shell/perl
--- response
{"success":0,"error":"HTTP DELETE method not supported for prog."}



=== TEST 8: POST "stdin"
--- request
POST /=/shell/perl/~/~
"print 'hello, world!'"
--- response
"hello, world!"



=== TEST 9: POST "stdin" (bad post content)
--- request
POST /=/shell/perl/~/~
["print 'hello, world!'"]
--- response
{"success":0,"error":"POST data must be a plain string."}



=== TEST 10: test timeout
--- request
POST /=/shell/perl/~/~
"sleep 10"
--- response
{"success":0,"error":"IPC::Run: timeout on timer #7"}

