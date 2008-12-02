# vi:filetype=

use t::OpenResty;

=pod

This test file test a bug such as  DELETE /=/model/xxx/xxx?op=contains

TODO
* many...

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login
--- request
GET /=/login/taobao_vip.Admin/$TestPass?_use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"taobao_vip","role":"Admin"}$



