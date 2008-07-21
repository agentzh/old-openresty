# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 3: Create a view
--- request
POST /=/view/Toy
{"definition":"select 12"}
--- response
{"success":1}



=== TEST 4: Create an identical view but with a different name
--- request
POST /=/view/Toy2
{"definition":"select 12"}
--- response
{"success":1}

