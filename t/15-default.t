# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=peee&password=4423037
--- response
{"success":1}



=== TEST 2: default in create model
--- request
POST /=/model/Foo
{
  description:"Foo",
  columns: [
    {name:"title", label: "title", default:"No title"},
    {name:"content", label: "content", default:"No content" }
  ]
}
--- response
{"success":1}



=== TEST 3: Check the model def
--- request
GET /=/model/Foo
--- response
{
  "columns":
    [
      {"name":"id","label":"ID","type":"serial"},
      {"name":"title","default":"'No title'","label":"title","type":"text"},
      {"name":"content","default":"'No content'","label":"content","type":"text"}
    ],
    "name":"Foo",
    "description":"Foo"
}



=== TEST 4: Insert a row (wrong way)
--- request
POST /=/model/Foo/~/~
{}
--- response
{"success":0,"error":"No column specified in row 1."}



=== TEST 5: Insert a row
--- request
POST /=/model/Foo/~/~
{ title: "Howdy!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/1"}



=== TEST 6: Check that it has the default value
--- request
GET /=/model/Foo/id/1
--- response
[{"content":"No content","title":"Howdy!","id":"1"}]



=== TEST 7: Add a column with default now()
--- request
POST /=/model/Foo/~
{ name: "created", label: "创建日期", type: "timestamp", default: ["now()"] }
--- response
{"success":1,"src":"/=/model/Foo/created"}



=== TEST 8: Check the column
--- request
GET /=/model/Foo/created
--- response
{"name":"created","default":"now()","label":"创建日期","type":"timestamp"}



=== TEST 9: Check the column list
--- request
GET /=/model/Foo/~
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":"'No title'","label":"title","type":"text"},
    {"name":"content","default":"'No content'","label":"content","type":"text"},
    {"name":"created","default":"now()","label":"创建日期","type":"timestamp"}]



=== TEST 10: Insert a row w/o setting "created"
--- request
POST /=/model/Foo/~/~
{ title: "Hi!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/2"}



=== TEST 11: Check the newly added row
--- request
GET /=/model/Foo/id/2
--- response_like
\[\{"created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","content":"No content","title":"Hi!","id":"2"\}\]



=== TEST 12: Insert another row
--- request
POST /=/model/Foo/~/~
{ title: "Bah!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/3"}



=== TEST 13: Check the newly added row
--- request
GET /=/model/Foo/id/3
--- response_like
\[\{"created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","content":"No content","title":"Bah!","id":"3"\}\]



=== TEST 14: change the default value of the "content" column
--- request
PUT /=/model/Foo/content
{ default: "hi" }
--- response
{"success":1}



=== TEST 15: Insert another row
--- request
POST /=/model/Foo/~/~
{ title: "Cat!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/4"}



=== TEST 16: Check the newly added row
--- request
GET /=/model/Foo/id/4
--- response_like
\[\{"created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","content":"hi","title":"Cat!","id":"4"\}\]



=== TEST 17: change the default value of the "content" column to now()
--- request
PUT /=/model/Foo/content
{ default: [" now ( ) "] }
--- response
{"success":1}



=== TEST 18: Insert another row
--- request
POST /=/model/Foo/~/~
{ title: "Dog!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/5"}



=== TEST 19: Check the newly added row
--- request
GET /=/model/Foo/id/5
--- response_like
\[\{"created":"(20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+)","content":"\1[-+]\d{2}","title":"Dog!","id":"5"\}\]



=== TEST 20: model with default now()
--- request
POST /=/model/~
{ name:"Howdy", description:"Howdy",
  columns:[
    {name:"title",label:"title"},
    {name:"updated",label:"updated",default:["now()"]}
  ] }
--- response
{"success":1}



=== TEST 21: Check the columns
--- request
GET /=/model/Howdy/~
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":null,"label":"title","type":"text"},
    {"name":"updated","default":"now()","label":"updated","type":"text"}
]



=== TEST 22: Insert another row
--- request
POST /=/model/Howdy/~/~
{ title: "Hey" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Howdy/id/1"}



=== TEST 23: Check the newly added row
--- request
GET /=/model/Howdy/id/1
--- response_like
\[\{"updated":"(20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+[-+]\d{2})","title":"Hey","id":"1"\}\]



=== TEST 24: Create a new column with timestamp
--- request
POST /=/model/Howdy/colA
{ label: "colA", type:  "timestamp" }
--- response
{"success":1,"src":"/=/model/Howdy/colA"}



=== TEST 25: Create a new column with timestamp(0)
--- request
POST /=/model/Howdy/colB
{ label: "colB", type:  "timestamp(0)" }
--- response
{"success":1,"src":"/=/model/Howdy/colB"}



=== TEST 26: extra space in type
--- request
POST /=/model/Howdy/colC
{ label: "colC", type:  "  timestamp  (  0  )  " }
--- response
{"success":1,"src":"/=/model/Howdy/colC"}



=== TEST 27: invalid stuff
--- request
POST /=/model/Howdy/colD
{ label: "colD", type:  "  timestamp  (  'a'  )  " }
--- response
{"success":0,"error":"Bad column type:   timestamp  (  'a'  )  "}



=== TEST 28: with timezone (Bad)
--- request
POST /=/model/Howdy/colE
{ label: "colE", type:  "  timestamp  (  0  )  with  timezone " }
--- response
{"success":0,"error":"Bad column type:   timestamp  (  0  )  with  timezone "}



=== TEST 29: with time zone (Good)
--- request
POST /=/model/Howdy/colE
{ label: "colE", type:  " timestamp ( 0 )  with  time  zone " }
--- response
{"success":1,"src":"/=/model/Howdy/colE"}



=== TEST 30: with time zone but w/o precision
--- request
POST /=/model/Howdy/colF
{ label: "colF", type:  " timestamp with  time  zone " }
--- response
{"success":1,"src":"/=/model/Howdy/colF"}



=== TEST 31: with time zone but w/o precision (for time)
--- request
POST /=/model/Howdy/colG
{ label: "colG", type:  " time (0) with  time  zone " }
--- response
{"success":1,"src":"/=/model/Howdy/colG"}



=== TEST 32: Add a column with default 0
--- request
POST /=/model/Foo/~
{ name: "num", label: "num", type: "integer", default: "0" }
--- response
{"success":1,"src":"/=/model/Foo/num"}

