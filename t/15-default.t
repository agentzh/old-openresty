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



=== TEST 2: default in create model
--- request
POST /=/model/Foo
{
  "description":"Foo",
  "columns": [
    {"name":"title", "type":"text", "label": "title", "default":"'No title'"},
    {"name":"content", "type":"text", "label": "content", "default":"'No content'" }
  ]
}
--- response
{"success":1}



=== TEST 3: Check the model def
--- request
GET /=/model/Foo
--- response
{"columns":[{"label":"ID","name":"id","type":"serial"},{"default":"'No title'::text","label":"title","name":"title","not_null":false,"type":"text","unique":false},{"default":"'No content'::text","label":"content","name":"content","not_null":false,"type":"text","unique":false}],"description":"Foo","name":"Foo"}



=== TEST 4: Insert a row (wrong way)
--- request
POST /=/model/Foo/~/~
{}
--- response
{"success":0,"error":"No column specified in row 1."}



=== TEST 5: Insert a row
--- request
POST /=/model/Foo/~/~
{ "title": "Howdy!" }
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
{ "name": "created", "label": "创建日期", "type": "timestamp", "default": ["now()"] }
--- response
{"success":0,"error":"Bad value for \"default\": String expected."}



=== TEST 8: Add a column with default now()
--- request
POST /=/model/Foo/~
{ "name": "created", "label": "创建日期", "type": "timestamp", "default": "now()" }
--- response
{"success":1,"src":"/=/model/Foo/created"}



=== TEST 9: Check the column
--- request
GET /=/model/Foo/created
--- response
{"name":"created","default":"now()","label":"创建日期","type":"timestamp without time zone","unique":false,"not_null":false}



=== TEST 10: Check the column list
--- request
GET /=/model/Foo/~
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":"'No title'::text","label":"title","type":"text","unique":false,"not_null":false},
    {"name":"content","default":"'No content'::text","label":"content","type":"text","unique":false,"not_null":false},
    {"name":"created","default":"now()","label":"创建日期","type":"timestamp without time zone","unique":false,"not_null":false}]



=== TEST 11: Insert a row w/o setting "created"
--- request
POST /=/model/Foo/~/~
{ "title": "Hi!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/2"}



=== TEST 12: Check the newly added row
--- request
GET /=/model/Foo/id/2
--- response_like
\[\{"content":"No content","created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","id":"2","title":"Hi!"\}\]



=== TEST 13: Insert another row
--- request
POST /=/model/Foo/~/~
{ "title": "Bah!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/3"}



=== TEST 14: Check the newly added row
--- request
GET /=/model/Foo/id/3
--- response_like
\[\{"content":"No content","created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","id":"3","title":"Bah!"\}\]



=== TEST 15: change the default value of the "content" column
--- request
PUT /=/model/Foo/content
{ "default": "'hi'" }
--- response
{"success":1}



=== TEST 16: Insert another row
--- request
POST /=/model/Foo/~/~
{ "title": "Cat!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/4"}



=== TEST 17: Check the newly added row
--- request
GET /=/model/Foo/id/4
--- response_like
\[\{"content":"hi","created":"20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+","id":"4","title":"Cat!"\}\]



=== TEST 18: change the default value of the "content" column to now()
--- request
PUT /=/model/Foo/content
{"default": "now()"}
--- response
{"success":1}



=== TEST 19: Insert another row
--- request
POST /=/model/Foo/~/~
{ "title": "Dog!" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/5"}



=== TEST 20: Check the newly added row
--- request
GET /=/model/Foo/id/5
--- response_like
\[\{"content":".*?[-+]\d{2}","created":"(20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+)","id":"5","title":"Dog!"\}\]



=== TEST 21: model with default now()
--- request
POST /=/model/~
{ "name":"Howdy", "description":"Howdy",
  "columns":[
    {"name":"title","type":"text","label":"title"},
    {"name":"updated","type":"text","label":"updated","default":"now() at time zone 'UTC'"}
  ] }
--- response
{"success":1}



=== TEST 22: Check the columns
--- request
GET /=/model/Howdy/~
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","default":null,"label":"title","type":"text","unique":false,"not_null":false},
    {"name":"updated","default":"timezone('UTC'::text, now())","label":"updated","type":"text","unique":false,"not_null":false}
]



=== TEST 23: Insert another row
--- request
POST /=/model/Howdy/~/~
{ "title": "Hey" }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Howdy/id/1"}



=== TEST 24: Check the newly added row
--- request
GET /=/model/Howdy/id/1
--- response_like
\[\{"id":"1","title":"Hey","updated":"(20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+)"\}\]



=== TEST 25: Create a new column with timestamp
--- request
POST /=/model/Howdy/colA
{ "label": "colA", "type":  "timestamp" }
--- response
{"success":1,"src":"/=/model/Howdy/colA"}



=== TEST 26: Create a new column with timestamp(0)
--- request
POST /=/model/Howdy/colB
{ "label": "colB", "type":  "timestamp(0)" }
--- response
{"success":1,"src":"/=/model/Howdy/colB"}



=== TEST 27: extra space in type
--- request
POST /=/model/Howdy/colC
{ "label": "colC", "type":  "  timestamp  (  0  )  " }
--- response
{"success":1,"src":"/=/model/Howdy/colC"}



=== TEST 28: invalid stuff
--- request
POST /=/model/Howdy/colD
{ "label": "colD", "type":  "  timestamp  (  'a'  )  " }
--- response
{"success":0,"error":"Bad column type:   timestamp  (  'a'  )  "}



=== TEST 29: with timezone (Bad)
--- request
POST /=/model/Howdy/colE
{ "label": "colE", "type":  "  timestamp  (  0  )  with  timezone " }
--- response
{"success":0,"error":"Bad column type:   timestamp  (  0  )  with  timezone "}



=== TEST 30: with time zone (Good)
--- request
POST /=/model/Howdy/colE
{ "label": "colE", "type":  " timestamp ( 0 )  with  time  zone " }
--- response
{"success":1,"src":"/=/model/Howdy/colE"}



=== TEST 31: with time zone but w/o precision
--- request
POST /=/model/Howdy/colF
{ "label": "colF", "type":  " timestamp with  time  zone " }
--- response
{"success":1,"src":"/=/model/Howdy/colF"}



=== TEST 32: with time zone but w/o precision (for time)
--- request
POST /=/model/Howdy/colG
{ "label": "colG", "type":  " time (0) with  time  zone " }
--- response
{"success":1,"src":"/=/model/Howdy/colG"}



=== TEST 33: Add a column with default 0
--- request
POST /=/model/Foo/~
{ "name": "num", "label": "num", "type": "integer", "default": "0" }
--- response
{"success":1,"src":"/=/model/Foo/num"}



=== TEST 34: Add a column with default ""
--- request
POST /=/model/Foo/~
{ "name": "empty", "label": "num", "type": "text", "default": "''" }
--- response
{"success":1,"src":"/=/model/Foo/empty"}



=== TEST 35: Insert a line
--- request
POST /=/model/Foo/~/~
{"num":3,"created":"2008-05-06 14:36:27","content":"blah"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/6"}



=== TEST 36: check the new row
--- request
GET /=/model/Foo/id/6
--- response
[{"content":"blah","created":"2008-05-06 14:36:27","empty":"","id":"6","num":"3","title":"No title"}]



=== TEST 37: set an empty default value
--- request
PUT /=/model/Foo/content
{"default":null}
--- response
{"success":1}



=== TEST 38: Insert a line
--- request
POST /=/model/Foo/~/~
{"created":"2008-05-06 14:36:27"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Foo/id/7"}



=== TEST 39: check the new row
--- request
GET /=/model/Foo/id/7
--- response
[{"content":null,"created":"2008-05-06 14:36:27","empty":"","id":"7","num":"0","title":"No title"}]



=== TEST 40: logout
--- request
GET /=/logout
--- response
{"success":1}

