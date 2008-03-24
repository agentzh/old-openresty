# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Clear the environment
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Foo
{
    "description":"foo",
    "columns":
        [ {"name":"text", "label":"Text"} ]
}
--- response
{"success":1}



=== TEST 3: Post a sexist's content
--- request
POST /=/model/Foo/~/~
{ "text": "oh, what a fuck!" }
--- response
{"success":0,"error":"QP filter: Sexist not welcomed."}

