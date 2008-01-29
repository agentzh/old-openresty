# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: UTF-8
--- charset: UTF-8
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
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



=== TEST 12: Create a model in UTF-8
--- charset: UTF-8
--- request
POST /=/model/Utf8?charset=guessing
{ description: "文字编码测试utf8", columns: [{name:"bar",label:"我们的open api"}] }
--- response
{"success":1}



=== TEST 13: Check the data in UTF-8
--- charset: UTF-8
--- request
GET /=/model/Utf8?charset=UTF-8
--- response
{
  "columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"我们的open api","type":"text"}
  ],
  "name":"Utf8",
  "description":"文字编码测试utf8"
}



=== TEST 14: Create a model in GBK
--- charset: GBK
--- request
POST /=/model/Gbk?charset=guessing
{ description: "文字编码测试GBK 张皛珏 万珣新", columns: [{name:"bar",label:"我们的open api"}] }
--- response
{"success":1}



=== TEST 15: Check the data in UTF-8
--- charset: UTF-8
--- request
GET /=/model/Gbk?charset=UTF-8
--- response
{
  "columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"我们的open api","type":"text"}
  ],
  "name":"Gbk",
  "description":"文字编码测试GBK 张皛珏 万珣新"
}



=== TEST 16: Create a model in GB2312
--- charset: GB2312
--- request
POST /=/model/Gb2312?charset=guessing
{ description: "文字编码测试GB2312", columns: [{name:"bar",label:"我们的open api"}] }
--- response
{"success":1}



=== TEST 17: Check the data in UTF-8
--- charset: UTF-8
--- request
GET /=/model/Gb2312?charset=UTF-8
--- response
{
  "columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"我们的open api","type":"text"}
  ],
  "name":"Gb2312",
  "description":"文字编码测试GB2312"
}



=== TEST 18: Create a model in big5
--- charset: Big5
--- request
POST /=/model/Big5?charset=guessing
{ description: "文字編碼測試big5", columns: [{name:"bar",label:"我們的open api"}] }
--- response
{"success":1}



=== TEST 19: Check the data in UTF-8
--- charset: UTF-8
--- request
GET /=/model/Big5?charset=UTF-8
--- response
{
  "columns":[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"bar","default":null,"label":"我們的open api","type":"text"}
  ],
  "name":"Big5",
  "description":"文字編碼測試big5"
}

