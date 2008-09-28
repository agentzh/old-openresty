# vi:filetype=

use strict;
use warnings;

#use OpenResty;
#use OpenResty::Config;
my $ExePath;
my $skip;
use t::OpenResty;
BEGIN {
    OpenResty::Config->init;
    my $allowed = $OpenResty::AllowForwarding{$t::OpenResty::user};
    if (!$allowed) {
        $skip = "$t::OpenResty::user not allowed for open HTTP forwarding";
    }
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable";
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



=== TEST 2: Relay a cross-site request
--- request
POST /=/action/Test
{ "definition": "GET 'http://api.openresty.org/=/version'" }
--- response
{"success":1}



=== TEST 3: Invoke it
--- request
GET /=/action/Test/~/~
--- response
["0.5.0"]

