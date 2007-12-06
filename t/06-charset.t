use t::OpenAPI 'no_plan';

run_tests;

__DATA__

=== TEST 1: UTF-8
--- charset: UTF-8
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 2: GBK
--- charset: GBK
--- request
DELETE /=/model?charset=GBK
--- response
{"success":1}

