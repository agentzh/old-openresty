# vi:filetype=

my $ExePath;
BEGIN {
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found.\n";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable.\n";
        return;
    }
};
use t::OpenResty $skip ? (skip_all => $skip) : ();

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing actions
--- request
DELETE /=/action?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1,"warning":"Builtin actions were skipped."}



=== TEST 2: Create an action with builtin vars
--- request
POST /=/action/Foo
{ "description": "test builtin vars",
  "definition": "select $_ACCOUNT as account, $_ROLE as role;" }
--- response
{"success":1}



=== TEST 3: Invoke the action with explicit variable binding
--- request
GET /=/action/Foo/_ACCOUNT/32?_ROLE=56
--- response
[[{"account":"tester","role":"Admin"}]]



=== TEST 4: Invoke the action w/o binding
--- request
GET /=/action/Foo/~/~
--- response
[[{"account":"tester","role":"Admin"}]]



=== TEST 5: Create an action with non-recognized builtin vars
--- request
POST /=/action/Bar
{ "description": "test builtin vars",
  "definition": "select $_blah as account, $_foo as role;" }
--- response
{"success":0,"error":"Unknown built-in parameter: _blah"}

