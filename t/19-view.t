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
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"A\" not found."}



=== TEST 7: Create model A
--- request
POST /=/model/A
{ "description": "A",
  "columns": { "name": "title", "type":"text", "label": "title" }
  }
--- response
{"success":1}



=== TEST 8: Create a view referencing non-existent model B
--- request
POST /=/view/View
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"B\" not found."}



=== TEST 9: Create model B
--- request
POST /=/model/B
{ "description": "B",
  "columns": [
    {"name":"body","type":"text", "label":"body"},
    {"name":"a","type":"integer","label":"a"}
  ]
}
--- response
{"success":1}



=== TEST 10: Create the view when the models are ready
--- request
POST /=/view/View
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":1}



=== TEST 11: Try to create it twice
--- request
POST /=/view/View
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"View \"View\" already exists."}



=== TEST 12: Check the view list
--- request
GET /=/view
--- response
[
    {
      "src":"/=/view/View",
      "name":"View",
      "description":null
    }
]



=== TEST 13: Check the View view
--- request
GET /=/view/View
--- response
{
    "name":"View",
    "description":null,
    "definition":"select * from A, B where A.id = B.a order by A.title"
}



=== TEST 14: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 15: Check a non-existent model
--- request
GET /=/view/Dummy
--- response
{"success":0,"error":"View \"Dummy\" not found."}



=== TEST 16: Invoke the view
--- request
GET /=/view/Dummy/~/~
--- response
{"success":0,"error":"View \"Dummy\" not found."}



=== TEST 17: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 18: Insert some data into model A
--- request
POST /=/model/A/~/~
[
  {"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},
  {"title":"Sina"},{"title":"Sohu"} ]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/A/id/5"}



=== TEST 19: Invoke the View view
--- request
GET /=/view/View/~/~
--- response
[]



=== TEST 20: Insert some data into model B
--- request
POST /=/model/B/~/~
[{"body":"baidu.com","a":3},{"body":"google.com","a":2},
 {"body":"sohu.com","a":5},{"body":"163.com","a":6},
 {"body":"yahoo.cn","a":1}]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/B/id/5"}



=== TEST 21: Invoke the view again
--- request
GET /=/view/View/~/~
--- response
[
{"body":"baidu.com","a":"3","title":"Baidu","id":"1"},
{"body":"google.com","a":"2","title":"Google","id":"2"},
{"body":"sohu.com","a":"5","title":"Sohu","id":"3"},
{"body":"yahoo.cn","a":"1","title":"Yahoo","id":"5"}
]



=== TEST 22: Insert another record to model A
--- request
POST /=/model/A/~/~
{"title":"163"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/A/id/6"}



=== TEST 23: recheck the view
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



=== TEST 24: Create a second view
--- request
POST /=/view/~
{"name":"View2","definition":"select title from A as blah order by $col"}
--- response
{"success":1}



=== TEST 25: Check the view
--- request
GET /=/view/View2
--- response
{"name":"View2","description":null,"definition":"select title from A as blah order by $col"}



=== TEST 26: Check the view list
--- request
GET /=/view
--- response
[
    {"src":"/=/view/View",
     "name":"View",
     "description":null
    },
    {"src":"/=/view/View2",
     "name":"View2",
     "description":null
     }
]



=== TEST 27: Invoke View2
--- request
GET /=/view/View2/~/~?col=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 28: another way to feed the param
--- request
GET /=/view/View2/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 29: Change the param value
--- request
GET /=/view/View2/col/id
--- response
[{"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},{"title":"Sina"},{"title":"Sohu"},{"title":"163"}]



=== TEST 30: Rename View2 to TitleOnly
--- request
PUT /=/view/View2
{"name":"TitleOnly"}
--- response
{"success":1}



=== TEST 31: Rename View2 again (this should fail)
--- request
PUT /=/view/View2
{"name":"TitleOnly"}
--- response
{"success":0,"error":"View \"View2\" not found."}



=== TEST 32: Check the view list
--- request
GET /=/view/~
--- response
[
    {"name":"View","description":null},
    {"name":"TitleOnly","description":null}
]



=== TEST 33: Check the TitleOnly view
--- request
GET /=/view/TitleOnly
--- response
{"name":"TitleOnly","description":null,"definition":"select title from A as blah order by $col"}



=== TEST 34: Invoke TitleOnly w/o params
--- request
GET /=/view/TitleOnly/~/~
--- response
{"success":0,"error":"Parameters required: col"}



=== TEST 35: Invoke TitleOnly with a param
--- request
GET /=/view/TitleOnly/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 36: Change the body of TitleOnly
--- request
PUT /=/view/TitleOnly
{ "definition":"select $select_col from A order by $order_by" }
--- response
{"success":1}



=== TEST 37: Check the new TitleOnly view
--- request
GET /=/view/TitleOnly
--- response
{"name":"TitleOnly","description":null,"definition":"select $select_col from A order by $order_by"}



=== TEST 38: Invoke the new TitleOnly view (1st way)
--- request
GET /=/view/TitleOnly/select_col/id?order_by=id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 39: Invoke the new TitleOnly view (1st way)
--- request
GET /=/view/TitleOnly/select_col/title?order_by=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 40: Invoke the new TitleOnly view (2rd way)
--- request
GET /=/view/TitleOnly/select_col/id?order_by=id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 41: Invoke the new TitleOnly view (2rd way)
--- request
GET /=/view/TitleOnly/select_col/title?order_by=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 42: Invoke the new TitleOnly view (3rd way)
--- request
GET /=/view/TitleOnly/~/~?select_col=id&order_by=id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 43: Invoke the new TitleOnly view (3rd way)
--- request
GET /=/view/TitleOnly/~/~?select_col=title&order_by=title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 44: Invoke the new TitleOnly view (missing one param)
--- request
GET /=/view/TitleOnly/~/~?select_col=title
--- response
{"success":0,"error":"Parameters required: order_by"}



=== TEST 45: Invoke the new TitleOnly view (missing the other param)
--- request
GET /=/view/TitleOnly/order_by/id
--- response
{"success":0,"error":"Parameters required: select_col"}



=== TEST 46: Invoke the new TitleOnly view (missing both params)
--- request
GET /=/view/TitleOnly/~/~
--- response
{"success":0,"error":"Parameters required: select_col order_by"}



=== TEST 47: Invoke the new TitleOnly view (a wrong param given)
--- request
GET /=/view/TitleOnly/blah/dummy
--- response
{"success":0,"error":"Parameters required: select_col order_by"}



=== TEST 48: Delete the View view
--- request
DELETE /=/view/View
--- response
{"success":1}



=== TEST 49: Recheck the View view
--- request
GET /=/view/View
--- response
{"success":0,"error":"View \"View\" not found."}



=== TEST 50: Recheck the view list
--- request
GET /=/view
--- response
[
    {"src":"/=/view/TitleOnly","name":"TitleOnly","description":null}
]



=== TEST 51: Add a new view with default values
--- request
POST /=/view/Foo
{"definition":"select $col|id from A order by $by|title"}
--- response
{"success":1}



=== TEST 52: Check the Foo view
--- request
GET /=/view/Foo
--- response
{"name":"Foo","description":null,"definition":"select $col|id from A order by $by|title"}



=== TEST 53: Invoke Foo w/o params
--- request
GET /=/view/Foo/~/~
--- response
[{"id":"6"},{"id":"3"},{"id":"2"},{"id":"4"},{"id":"5"},{"id":"1"}]



=== TEST 54: Invoke Foo with 1 param set
--- request
GET /=/view/Foo/by/id
--- response
[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]



=== TEST 55: Invoke Foo with the other one param set
--- request
GET /=/view/Foo/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 56: Invoke Foo with both params set
--- request
GET /=/view/Foo/col/title?by=id
--- response
[{"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},{"title":"Sina"},{"title":"Sohu"},{"title":"163"}]



=== TEST 57: Bad view name
--- request
GET /=/view/!@
--- response
{"success":0,"error":"Bad view name: !@"}



=== TEST 58: Get the view list
--- request
GET /=/view
--- response
[
    {"src":"/=/view/TitleOnly","name":"TitleOnly","description":null},
    {"src":"/=/view/Foo","name":"Foo","description":null}
]



=== TEST 59: Change the view name and definition simultaneously
--- request
PUT /=/view/Foo
{ "name": "Bah", "definition": "select * from A" }
--- response
{"success":1}



=== TEST 60: Check the old view
--- request
GET /=/view/Foo
--- response
{"success":0,"error":"View \"Foo\" not found."}



=== TEST 61: Check the new view
--- request
GET /=/view/Bah
--- response
{
    "name":"Bah",
    "description":null,
    "definition":"select * from A"
}



=== TEST 62: Set the description (the wrong way, typo)
--- request
PUT /=/view/Bah
{ "descripition": "Blah blah blah..." }
--- response
{"success":0,"error":"Unknown keys in POST data: descripition"}



=== TEST 63: Set the description
--- request
PUT /=/view/Bah
{ "description": "Blah blah blah..." }
--- response
{"success":1}



=== TEST 64: Check the desc
--- request
GET /=/view/Bah
--- response
{
    "name":"Bah",
    "description":"Blah blah blah...",
    "definition":"select * from A"
}



=== TEST 65: give wrong POST data
--- request
POST /=/view/Foo
[1,2,3]
--- response
{"success":0,"error":"The view schema must be a HASH."}



=== TEST 66: Bad hash
--- request
POST /=/view/Foo
{"cat":3}
--- response
{"success":0,"error":"No 'definition' specified."}



=== TEST 67: Re-add view Foo (Bad minisql)
--- request
POST /=/view/Foo
{"description":"Test vars for vals","name":"Foo",
    "definition":""}
--- response
{"success":0,"error":"Bad definition: \"\""}



=== TEST 68: Re-add view Foo (Bad minisql)
--- request
POST /=/view/Foo
{"description":"Test vars for vals","name":"Foo",
    "definition":"update _view set "}
--- response
{"success":0,"error":"minisql: line 1: error: Unexpected input: \"update\" ('(' or select expected)."}



=== TEST 69: Re-add view Foo (Bad minisql)
--- request
POST /=/view/Foo
{"description":"Test vars for vals","name":"Foo",
    "definition":"select * from $model | 'A' where $col|id > $val"}
--- response
{"success":0,"error":"minisql: line 1: error: Unexpected input: \"'A'\" (IDENT expected)."}



=== TEST 70: Re-add view Foo
--- request
POST /=/view/Foo
{"description":"Test vars for vals","name":"Foo",
    "definition":"select * from $model | A where $col|id > $val"}
--- response
{"success":1}



=== TEST 71: Invoke the view (required vars missing)
--- request
GET /=/view/Foo/~/~
--- response
{"success":0,"error":"Parameters required: val"}



=== TEST 72: Invoke the view
--- request
GET /=/view/Foo/val/2
--- response
[
    {"title":"Baidu","id":"3"},
    {"title":"Sina","id":"4"},
    {"title":"Sohu","id":"5"},
    {"title":"163","id":"6"}
]



=== TEST 73: Escaped char
--- request
GET /=/view/Foo/val/林\?col=title
--- response
[]



=== TEST 74: Invoke the view (bad fixed var name)
--- request
GET /=/view/Foo/!@/2
--- response
{"success":0,"error":"Bad parameter name: \"!@\""}



=== TEST 75: Invoke the view (another way)
--- request
GET /=/view/Foo/~/~?val=2
--- response
[
    {"title":"Baidu","id":"3"},
    {"title":"Sina","id":"4"},
    {"title":"Sohu","id":"5"},
    {"title":"163","id":"6"}
]



=== TEST 76: Invoke the view (bad free var name)
--- request
GET /=/view/Foo/~/~?!@=2
--- response
{"success":0,"error":"Parameters required: val"}



=== TEST 77: Invoke the view (bad symbol)
--- request
GET /=/view/Foo/~/~?val=2&col=id"
--- response
{"success":0,"error":"minisql: Bad symbol: id\""}



=== TEST 78: Invoke the view (overriding vars)
--- request
GET /=/view/Foo/~/~?val=2&col=id
--- response
[
    {"title":"Baidu","id":"3"},
    {"title":"Sina","id":"4"},
    {"title":"Sohu","id":"5"},
    {"title":"163","id":"6"}
]



=== TEST 79: Create a model with cidr type
--- request
POST /=/model/T
{
    "description": "Type testing",
    "columns":[
        { "name": "cidr", "type": "cidr", "label": "cidr" }
    ]
}
--- response
{"success":1}



=== TEST 80: Insert lines to cidr table
--- request
POST /=/model/T/~/~
[
    {"cidr":"202.165.100.143"}
]
--- response
{"last_row":"/=/model/T/id/1","rows_affected":1,"success":1}



=== TEST 81: create a view with operator >>=
--- request
POST /=/view/TC
{ "definition": "select count(*) from T where cidr >>= '202.165.100.243'" }
--- response
{"success":1}



=== TEST 82: bug
--- request
POST /=/view/RowCount
{ "definition": "select count(*) from $model" }
--- response
{"success":1}



=== TEST 83: view the TitleOnly view
--- request
GET /=/view/TitleOnly
--- response
{"name":"TitleOnly","description":null,"definition":"select $select_col from A order by $order_by"}



=== TEST 84: change the view def
--- request
PUT /=/view/TitleOnly
{ "definition": "select 32" }
--- response
{"success":1}



=== TEST 85: get the view def again:
--- request
GET /=/view/TitleOnly
--- response
{"name":"TitleOnly","description":null,"definition":"select 32"}



=== TEST 86: change the view def (syntax error)
--- request
PUT /=/view/TitleOnly
{ "definition": "abc 32" }
--- response
{"error":"minisql: line 1: error: Unexpected input: \"abc\" ('(' or select expected).","success":0}


=== TEST 87: from proc() as q
--- request
PUT /=/view/TitleOnly
{ "definition": "select ts_rank(ts_vector(content), q)" }
--- response
{"success":1}



=== TEST 87: from proc() as q
--- request
PUT /=/view/TitleOnly
{ "definition": "select * from Post, to_tsquery('chinesecfg', $query) as q where 1=1 order by ts_rank(ts_vector(content), q)" }
--- response
{"success":1}
--- SKIP

=== TEST 88: don't recognize aliased proc as model
--- request
POST /=/view/TitleOnly2
{ "definition": "select * from (select * from Post) as a where a.title = 'a' " }
--- response
{"success":1}


=== TEST 90: logout
--- request
GET /=/logout
--- response
{"success":1}
