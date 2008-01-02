# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

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



=== TEST 4: Check the data in GB2312
--- charset: GB2312
--- request
GET /=/model/Foo?charset=GB2312
--- response
{
  "columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"嘿嘿","type":"text"}
  ],
  "name":"Foo",
  "description":"你好么？"
}



=== TEST 5: Check the data in utf8
--- charset: utf8
--- request
GET /=/model/Foo?charset=utf8
--- response
{"columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"嘿嘿","type":"text"}
    ],
    "name":"Foo","description":"你好么？"}



=== TEST 6: Check the data in big5
--- charset: big5
--- request
GET /=/model/Foo?charset=big5
--- response
{"columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"嘿嘿","type":"text"}
    ],
    "name":"Foo","description":"你好么？"}



=== TEST 7: Check the data in latin1
--- charset: latin-1
--- request
GET /=/model/Foo/bar?charset=latin-1
--- response
{"name":"bar","default":null,"label":"??","type":"text"}



=== TEST 8: Insert records in Big5
--- charset: Big5
--- request
POST /=/model/Foo/~/~?charset=Big5
{ "bar": "廣告服務" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/1"}



=== TEST 9: Check the record
--- request
GET /=/model/Foo/~/~
--- response
[{"bar":"廣告服務","id":"1"}]



=== TEST 10: Check the record (in YAML)
--- request
GET /=/model/Foo/~/~.yml
--- format: YAML
--- response
--- 
- 
  bar: 廣告服務
  id: 1



=== TEST 11: Insert records in Big5
--- charset: Big5
--- request
GET /=/model/Foo/~/~?charset=Big5
--- response
[{"bar":"廣告服務","id":"1"}]

