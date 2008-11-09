# vi:filetype=

use t::OpenResty;

plan tests => 3*blocks();
#plan tests => 3 * blocks();

run_tests;

my $Test = Test::Builder->new;
if (grep {!$_} $Test->summary) { # any failure
    $Test->BAIL_OUT('failing very basic tests, ensure your db is configured according to OpenResty::Spec::Install');
}


__DATA__

=== TEST 1: Login with password but w/o cookie
--- request
GET /=/login/$TestAccount.Admin/$TestPass
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$
