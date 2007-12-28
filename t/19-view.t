# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}


=== TEST 2: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 3: Check the view list
--- request
GET /=/view
--- response
[]



=== TEST 4: Check the view list
--- request
GET /=/view/~
--- response
[]



=== TEST 5: Another way
--- request
DELETE /=/view/~
--- response
{"success":1}



=== TEST 6: Create a view referencing non-existent models
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"A\" not found."}



=== TEST 7: Create model A
--- request
POST /=/model/A
{ description: "A",
  columns: { name: "title", label: "title" }
  }
--- response
{"success":1}



=== TEST 8: Create a view referencing non-existent model B
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"B\" not found."}



=== TEST 9: Create model B
--- request
POST /=/model/B
{ description: "B",
  columns: [
    {name:"body",label:"body"},
    {name:"a",type:"integer",label:"a"}
  ]
}
--- response
{"success":1}



=== TEST 10: Create the view when the models are ready
--- request
POST /=/view/View
{ body: "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1}



=== TEST 11: Check the view list
--- request
GET /=/view
--- response
[
    {
      "src":"/=/view/View",
      "name":"View",
      "description":null,
      "definition":"select * from A, B where A.id = B.a order by A.title"
    }
]



=== TEST 12: Check the View view
--- request
GET /=/view/View
--- response
{
    "name":"View",
    "description":null,
    "definition":"select * from A, B where A.id = B.a order by A.title"
}



=== TEST 13: Check a non-existent model
--- request
GET /=/view/Dummy
--- response
{"success":0,"error":"View \"Dummy\" not found."}



=== TEST 14: Invoke the view
--- request
GET /=/view/Dummy/~/~
--- response
{"success":0,"error":"View \"Dummy\" not found."}



=== TEST 15: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 16: Insert some data into model A
--- request
POST /=/model/A/~/~
[
  {title:"Yahoo"},{title:"Google"},{title:"Baidu"},
  {title:"Sina"},{title:"Sohu"} ]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/A/id/5"}



=== TEST 17: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 18: Insert some data into model B
--- request
POST /=/model/B/~/~
[{body:"baidu.com",a:3},{body:"google.com",a:2},
 {body:"sohu.com",a:5},{body:"163.com",a:6},
 {body:"yahoo.cn",a:1}]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/B/id/5"}



=== TEST 19: Invoke the view again
--- request
GET /=/view/View/~/~
--- response
[
{"body":"baidu.com","a":"3","title":"Baidu","id":"1"},
{"body":"google.com","a":"2","title":"Google","id":"2"},
{"body":"sohu.com","a":"5","title":"Sohu","id":"3"},
{"body":"yahoo.cn","a":"1","title":"Yahoo","id":"5"}
]



=== TEST 20: Insert another record to model A
--- request
POST /=/model/A/~/~
{title:"163"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/A/id/6"}



=== TEST 21: recheck the view
--- request
GET /=/view/View/~/~
--- response
[
{"body":"163.com","a":"6","title":"163","id":"4"},
{"body":"baidu.com","a":"3","title":"Baidu","id":"1"},
{"body":"google.com","a":"2","title":"Google","id":"2"},
{"body":"sohu.com","a":"5","title":"Sohu","id":"3"},
{"body":"yahoo.cn","a":"1","title":"Yahoo","id":"5"}
]



=== TEST 22: Create a second view
--- request
POST /=/view/~
{name:"View2",body:"select title from A order by $col"}
--- response
{"success":1}



=== TEST 23: Check the view
--- request
GET /=/view/View2
--- response
{"name":"View2","description":null,"definition":"select title from A order by $col"}



=== TEST 24: Check the view list
--- request
GET /=/view
--- response
[
{"src":"/=/view/View",
 "name":"View",
 "description":null,
 "definition":"select * from A, B where A.id = B.a order by A.title"
},
{"src":"/=/view/View2",
"name":"View2",
"description":null,
"definition":"select title from A order by $col"
}
]



=== TEST 25: Invoke View2
--- request
GET /=/view/View2/~/~?col=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 26: another way to feed the param
--- request
GET /=/view/View2/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 27: Change the param value
--- request
GET /=/view/View2/col/id
--- response
[{"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},{"title":"Sina"},{"title":"Sohu"},{"title":"163"}]



=== TEST 28: Rename View2 to TitleOnly
--- request
PUT /=/view/View2
{name:"TitleOnly"}
--- response
{"success":1,"rows_affected":1}


=== TEST 29: Rename View2 again (this should fail)
--- request
PUT /=/view/View2
{name:"TitleOnly"}
--- response
{"success":0,"error":"View \"View2\" not found."}



=== TEST 30: Check the view list
--- request
GET /=/view/~
--- response
[
{"name":"View","description":null,"definition":"select * from A, B where A.id = B.a order by A.title"},
{"name":"TitleOnly","description":null,"definition":"select title from A order by $col"}
]



=== TEST 31: Check the TitleOnly view
--- request
GET /=/view/TitleOnly
--- response
{"name":"TitleOnly","description":null,"definition":"select title from A order by $col"}



=== TEST 32: Invoke TitleOnly w/o params
--- request
GET /=/view/TitleOnly/~/~
--- response
{"success":0,"error":"Parameter(s) required: col "}



=== TEST 33: Invoke TitleOnly with a param
--- request
GET /=/view/TitleOnly/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 34: Change the body of TitleOnly
--- request
PUT /=/view/TitleOnly
{ definition:"select $select_col from A order by $order_by" }
--- response
{"success":1,"rows_affected":1}



=== TEST 35: Check the new TitleOnly view
--- request
GET /=/view/TitleOnly
--- response
{"name":"TitleOnly","description":null,"definition":"select $select_col from A order by $order_by"}



=== TEST 36: Invoke the new TitleOnly view (1st way)
--- request
GET /=/view/TitleOnly/select_col/id?order_by=id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 37: Invoke the new TitleOnly view (1st way)
--- request
GET /=/view/TitleOnly/select_col/title?order_by=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 38: Invoke the new TitleOnly view (2rd way)
--- request
GET /=/view/TitleOnly/select_col/id?order_by=id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 39: Invoke the new TitleOnly view (2rd way)
--- request
GET /=/view/TitleOnly/select_col/title?order_by=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 40: Invoke the new TitleOnly view (3rd way)
--- request
GET /=/view/TitleOnly/~/~?select_col=id&order_by=id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 41: Invoke the new TitleOnly view (3rd way)
--- request
GET /=/view/TitleOnly/~/~?select_col=title&order_by=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 42: Invoke the new TitleOnly view (missing one param)
--- request
GET /=/view/TitleOnly/~/~?select_col=title
--- response
{"success":0,"error":"Parameter(s) required: order_by "}



=== TEST 43: Invoke the new TitleOnly view (missing the other param)
--- request
GET /=/view/TitleOnly/order_by/id
--- response
{"success":0,"error":"Parameter(s) required: select_col "}



=== TEST 44: Invoke the new TitleOnly view (missing both params)
--- request
GET /=/view/TitleOnly/~/~
--- response
{"success":0,"error":"Parameter(s) required: select_col order_by "}



=== TEST 45: Invoke the new TitleOnly view (a wrong param given)
--- request
GET /=/view/TitleOnly/blah/dummy
--- response
{"success":0,"error":"Parameter(s) required: select_col order_by "}



=== TEST 46: Delete the View view
--- request
DELETE /=/view/View
--- response
{"success":1}



=== TEST 47: Recheck the View view
--- request
GET /=/view/View
--- response
{"success":0,"error":"View \"View\" not found."}



=== TEST 48: Recheck the view list
--- request
GET /=/view
--- response
[{"src":"/=/view/TitleOnly","name":"TitleOnly","description":null,"definition":"select $select_col from A order by $order_by"}]



=== TEST 49: Add a new view with default values
--- request
POST /=/view/Foo
{"body":"select $col|id from A order by $by|title"}
--- response
{"success":1}



=== TEST 50: Check the Foo view
--- request
GET /=/view/Foo
--- response
{"name":"Foo","description":null,"definition":"select $col|id from A order by $by|title"}



=== TEST 51: Invoke Foo w/o params
--- request
GET /=/view/Foo/~/~
--- response
[{"id":"6"},{"id":"3"},{"id":"2"},{"id":"4"},{"id":"5"},{"id":"1"}]



=== TEST 52: Invoke Foo with 1 param set
--- request
GET /=/view/Foo/by/id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]


=== TEST 53: Invoke Foo with the other one param set
--- request
GET /=/view/Foo/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 54: Invoke Foo with both params set
--- request
GET /=/view/Foo/col/title?by=id
--- response
[{"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},{"title":"Sina"},{"title":"Sohu"},{"title":"163"}]


