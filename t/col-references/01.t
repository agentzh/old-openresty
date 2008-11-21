# vi:filetype=

#创建1列，其References指向一个不存在的model

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: create a model
--- request
POST /=/model/testreferences
{"description": "test references path01","columns": [{ "name":"jx01","type":"text","label":"jx01","references":{"model": "referencesmodel"}}]}
--- response
{"success":0,"error":"model \"referencesmodel\" is not exists!"}