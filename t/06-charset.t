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



=== TEST 3: Create a model in GBK
--- charset: GBK
--- request
POST /=/model/Foo?charset=GBK
{ description: "你好么？", columns: [{name:"bar",label:"嘿嘿"}] }
--- response
{"success":1}



=== TEST 4: Check the data
--- charset: GB2312
--- request
GET /=/model/Foo?charset=GB2312
--- response
{"columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","label":"嘿嘿","type":"text"}
    ],
    "name":"Foo","description":"你好么？"}

