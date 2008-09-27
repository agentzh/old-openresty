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



=== TEST 2: Delete existing actions
--- request
DELETE /=/action
--- response
{"success":1,"warning":"Builtin actions are skipped."}



=== TEST 3: Check the action list
only builtin actions supported
--- request
GET /=/action
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"}
]



=== TEST 4: Check the action list
only builtin actions supported
--- request
GET /=/action/~
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"}
]



=== TEST 5: Another way to remove actions
--- request
DELETE /=/action/~
--- response
{"success":1,"warning":"Builtin actions are skipped."}



=== TEST 6: Create an action referencing non-existent models
--- request
POST /=/action/Action
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Model \"A\" not found."}



=== TEST 7: Create model A
--- request
POST /=/model/A
{ "description": "A",
  "columns": [{ "name": "title", "label": "title", "type": "text" }]
  }
--- response
{"success":1}



=== TEST 8: Create an action referencing non-existent model B
--- request
POST /=/action/Action
{ "definition": "select * from A, B where A.id = B.a order by A.title",
    "description":"My first action"}
--- response
{"success":0,"error":"Model \"B\" not found."}



=== TEST 9: Create model B
--- request
POST /=/model/B
{ "description": "B",
  "columns": [
    {"name":"body","label":"body","type":"text"},
    {"name":"a","type":"integer","label":"a"}
  ]
}
--- response
{"success":1}



=== TEST 10: Create the action when the models are ready
--- request
POST /=/action/Action
{ "definition": "select * from A, B where A.id = B.a order by A.title",
    "description":"My first action"}
--- response
{"success":1}



=== TEST 11: Try to create it twice
--- request
POST /=/action/Action
{ "definition": "select * from A, B where A.id = B.a order by A.title" }
--- response
{"success":0,"error":"Action \"Action\" already exists."}



=== TEST 12: Check the action list
--- request
GET /=/action
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"},
    {"src":"/=/action/Action","name":"Action","description":"My first action"}
]



=== TEST 13: Check the Action action
--- request
GET /=/action/Action
--- response
{
    "name":"Action",
    "description":"My first action",
    "parameters":[],
    "definition":"select * from A, B where A.id = B.a order by A.title"
}



=== TEST 14: Invoke the Action action
--- request
GET /=/action/Action/~/~
--- response
[[]]



=== TEST 15: Check a non-existent action
--- request
GET /=/action/Dummy
--- response
{"success":0,"error":"Action \"Dummy\" not found."}



=== TEST 16: Invoke the action
--- request
GET /=/action/Dummy/~/~
--- response
{"success":0,"error":"Action \"Dummy\" not found."}



=== TEST 17: Invoke the Action action
--- request
GET /=/action/Action/~/~
--- response
[[]]



=== TEST 18: Insert some data into model A
--- request
POST /=/model/A/~/~
[
  {"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},
  {"title":"Sina"},{"title":"Sohu"} ]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/A/id/5"}



=== TEST 19: Invoke the Action action
--- request
GET /=/action/Action/~/~
--- response
[[]]



=== TEST 20: Insert some data into model B
--- request
POST /=/model/B/~/~
[{"body":"baidu.com","a":3},{"body":"google.com","a":2},
 {"body":"sohu.com","a":5},{"body":"163.com","a":6},
 {"body":"yahoo.cn","a":1}]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/B/id/5"}



=== TEST 21: Invoke the action again
--- request
GET /=/action/Action/~/~
--- response
[[
{"body":"baidu.com","a":"3","title":"Baidu","id":"1"},
{"body":"google.com","a":"2","title":"Google","id":"2"},
{"body":"sohu.com","a":"5","title":"Sohu","id":"3"},
{"body":"yahoo.cn","a":"1","title":"Yahoo","id":"5"}
]]



=== TEST 22: Insert another record to model A
--- request
POST /=/model/A/~/~
{"title":"163"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/A/id/6"}



=== TEST 23: recheck the action
--- request
GET /=/action/Action/~/~
--- response
[[
{"body":"163.com","a":"6","title":"163","id":"4"},
{"body":"baidu.com","a":"3","title":"Baidu","id":"1"},
{"body":"google.com","a":"2","title":"Google","id":"2"},
{"body":"sohu.com","a":"5","title":"Sohu","id":"3"},
{"body":"yahoo.cn","a":"1","title":"Yahoo","id":"5"}
]]



=== TEST 24: Create a second action (without params)
--- request
POST /=/action/~
{
    "name":"Action2",
    "definition":"select title from A order by $col"}
--- response
{"success":0,"error":"Parameter \"col\" used in the action definition is not defined in the \"parameters\" list."}



=== TEST 25: Create a second action (with invalid params)
--- request
POST /=/action/~
{
    "name":"Action2",
    "parameters":32,
    "definition":"select title from A order by $col"}
--- response
{"success":0,"error":"Invalid \"parameters\" list: 32"}



=== TEST 26: Create a second action (with invalid params)
--- request
POST /=/action/~
{
    "name":"Action2",
    "parameters":[
        {"name":"col"}
    ],
    "definition":"select title from A order by $col"}
--- response
{"success":0,"error":"Missing \"type\" for parameter \"col\"."}



=== TEST 27: Create a second action (with invalid params)
--- request
POST /=/action/~
{
    "name":"Action2",
    "parameters":[
        {"name":"col", "type":[32]}
    ],
    "definition":"select title from A order by $col"}
--- response
{"success":0,"error":"Invalid \"type\" for parameter \"col\": [32]"}



=== TEST 28: Create a second action (with invalid params)
# XXX Test for invalid type for "order by $col $dir"
--- request
POST /=/action/~
{
    "name":"Action2",
    "parameters":[
        {"name":"col", "type":"literal"}
    ],
    "definition":"select title from A order by $col"}
--- response
{"success":0,"error":"Invalid \"type\" for parameter \"col\". (It's used as a symbol in the action definition.)"}



=== TEST 29: Create a second action (with invalid params)
--- request
POST /=/action/~
{
    "name":"Action2",
    "parameters":[
        {"name":"col", "type":"keyword"}
    ],
    "definition":"select title from A order by $col"}
--- response
{"success":0,"error":"Invalid \"type\" for parameter \"col\". (It's used as a symbol in the action definition.)"}



=== TEST 30: Create a second action (with good params)
--- request
POST /=/action/~
{
    "name":"Action2",
    "parameters":[
        {"name":"col", "type":"symbol"}
    ],
    "definition":"select title from A order by $col"}
--- response
{"success":1}



=== TEST 31: Check the action
--- request
GET /=/action/Action2
--- response
{
    "name":"Action2",
    "description":null,
    "parameters":[{"name":"col","type":"symbol","label":null,"default":null}],
    "definition":"select title from A order by $col"
}



=== TEST 32: Check the action list
--- request
GET /=/action
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"},
    {"src":"/=/action/Action","name":"Action","description":"My first action"},
    {"src":"/=/action/Action2","name":"Action2","description":null}
]



=== TEST 33: Invoke Action2
--- request
GET /=/action/Action2/~/~?col=title
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 34: another way to feed the param
--- request
GET /=/action/Action2/col/title
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 35: yet another way to feed the param
--- request
POST /=/action/Action2/~/~
{"col":"title"}
--- response
[[
    {"title":"163"},
    {"title":"Baidu"},
    {"title":"Google"},
    {"title":"Sina"},
    {"title":"Sohu"},
    {"title":"Yahoo"}
]]



=== TEST 36: Change the param value
--- request
GET /=/action/Action2/col/id
--- response
[[
    {"title":"Yahoo"},
    {"title":"Google"},
    {"title":"Baidu"},
    {"title":"Sina"},
    {"title":"Sohu"},
    {"title":"163"}
]]
--- LAST



=== TEST 37: Rename Action2 to TitleOnly
--- request
PUT /=/action/Action2
{"name":"TitleOnly"}
--- response
{"success":1}



=== TEST 38: Rename Action2 again (this should fail)
--- request
PUT /=/action/Action2
{"name":"TitleOnly"}
--- response
{"success":0,"error":"Action \"Action2\" not found."}



=== TEST 39: Check the action list
--- request
GET /=/action/~
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"},
    {"name":"Action","description":null,"src":"/=/action/Action"},
    {"name":"TitleOnly","description":null,"src":"/=/action/TitleOnly"}
]



=== TEST 40: Check the TitleOnly action
--- request
GET /=/action/TitleOnly
--- response
{
    "name":"TitleOnly",
    "parameters":[
        {"name":"col","type":"symbol","default":null}
    ],
    "description":null,
    "definition":"select title from A order by $col"
}



=== TEST 41: Invoke TitleOnly w/o params
--- request
GET /=/action/TitleOnly/~/~
--- response
{"success":0,"error":"Arguments required: col"}



=== TEST 42: Invoke TitleOnly with a param
--- request
GET /=/action/TitleOnly/col/title
--- response
[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]



=== TEST 43: Change the body of TitleOnly without adding new params
--- request
PUT /=/action/TitleOnly
{ "definition":"select $select_col from A order by $order_by" }
--- response
{"success":0,"error":"Parameter \"select_col\" used in the action definition is not defined in \"parameters\"."}



=== TEST 44: Adding a new parameter
--- request
POST /=/action/TitleOnly/~
{ "name":"select_col" }
--- response
{"success":0,"error":"No \"type\" specified for parameter \"select_col\"."}



=== TEST 45: Adding a new parameter
--- request
POST /=/action/TitleOnly/~
{ "type":"symbol" }
--- response
{"success":0,"error":"No \"name\" specified for the new parameter."}



=== TEST 46: Adding a new parameter
--- request
POST /=/action/TitleOnly/~
1234
--- response
{"success":0,"error":"Invalid parameter specification: 1234"}



=== TEST 47: Adding a new parameter
--- request
POST /=/action/TitleOnly/~
["hello"]
--- response
{"success":0,"error":"Invalid parameter specification: [\"hello\"]"}



=== TEST 48: Adding a new parameter
--- request
POST /=/action/TitleOnly/select_col
{"type":"keyword"}
--- response
{"success":1}



=== TEST 49: Change the body of TitleOnly without using the param the right way
--- request
PUT /=/action/TitleOnly
{ "definition":"select $select_col as foo from A" }
--- response
{"success":0,"error":"Parameter \"select_col\" is not used as a \"keyword\" in the action definition."}



=== TEST 50: Update the type of the select_col param
--- request
PUT /=/action/TitleOnly/select_col
{"type":"literal"}



=== TEST 51: Try to change the def of the action again
--- request
PUT /=/action/TitleOnly
{"definition": "select $select_col as foo from A" }
--- response
{"success":1}



=== TEST 52: Invoke the new version of the action
--- request
GET /=/action/TitleOnly/~/~?select_col=123
--- response
[[
    {"foo":"123"},
    {"foo":"123"},
    {"foo":"123"},
    {"foo":"123"},
    {"foo":"123"},
    {"foo":"123"}
]]



=== TEST 53: check the params list
--- request
GET /=/action/TitleOnly/~
--- response
[
    {"name":"col","type":"symbol","default":null},
    {"name":"select_col","type":"literal","default":null}
]



=== TEST 54: Remove the old "col" param
--- request
DELETE /=/action/TitleOnly/col
--- response
{"sucess":1}



=== TEST 55: Try to remove a referenced param
--- request
DELETE /=/action/TitleOnly/select_col
--- response
{"success":0,"error":"Parameter \"select_col\" is referenced in the action definition."}



=== TEST 56: Check the param list again
--- request
GET /=/action/TitleOnly/~
--- response
[
    {"name":"select_col","type":"literal","default":null}
]



=== TEST 57: view the single param
--- request
GET /=/action/TitleOnly/select_col
--- response
{"name":"select_col","type":"literal","default":null}



=== TEST 58: update the action def again
--- request
PUT /=/action/TitleOnly
{"definition":"select $select_col from A order by $order_by"}
--- response
{"success":0,"error":"Parameter \"order_by\" used in the action definition is not defined in \"parameters\"."}



=== TEST 59: Add a new param
--- request
POST /=/action/TitleOnly/~
{"name":"order_by","type":"symbol"}
-- response
{"success":1}



=== TEST 60: update the action def again
--- request
PUT /=/action/TitleOnly
{"definition":"select $select_col from A order by $order_by"}
--- response
{"success":1}



=== TEST 61: Check the TitleOnly action again
--- request
GET /=/action/TitleOnly
--- response
{
    "name":"TitleOnly",
    "parameters":[
        {"name":"select_col","type":"literal","default":null},
        {"name":"order_by","type":"symbol","default":null}
    ],
    "description":null,
    "definition":"select $select_col from A order by $col"
}



=== TEST 62: Update the type of select_col to keyword
--- request
PUT /=/action/TitleOnly/select_col
{"type":"keyword"}
--- response
{"success":0,"error":"Parameter \"select_col\" is not used as a \"keyword\" in the action definition."}



=== TEST 63: Update the type of select_col to symbol
--- request
PUT /=/action/TitleOnly/select_col
{"type":"symbol"}
--- response
{"success":1}



=== TEST 64: Check the column select_col
--- request
GET /=/action/TitleOnly/select_col
--- response
{"name":"select_col","type":"symbol"}



=== TEST 65: Invoke the new TitleOnly action (1st way)
--- request
GET /=/action/TitleOnly/select_col/id?order_by=id
--- response
[[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]]



=== TEST 66: Invoke the new TitleOnly action (1st way)
--- request
GET /=/action/TitleOnly/select_col/title?order_by=title
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 67: Invoke the new TitleOnly action (2rd way)
--- request
GET /=/action/TitleOnly/select_col/id?order_by=id
--- response
[[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]]



=== TEST 68: Invoke the new TitleOnly action (3rd way)
--- request
GET /=/action/TitleOnly/select_col/title?order_by=title
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 69: Invoke the new TitleOnly action (4th way)
--- request
GET /=/action/TitleOnly/~/~?select_col=id&order_by=id
--- response
[[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]]



=== TEST 70: Invoke the new TitleOnly action (5th way)
--- request
GET /=/action/TitleOnly/~/~?select_col=title&order_by=title
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 71: Invoke the new TitleOnly action (6th way)
--- request
POST /=/action/TitleOnly/~/~
{"select_col": "title", "order_by": "title" }
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 72: Invoke the new TitleOnly action (missing one param)
--- request
GET /=/action/TitleOnly/~/~?select_col=title
--- response
{"success":0,"error":"Arguments required: order_by"}



=== TEST 73: Invoke the new TitleOnly action (missing the other param)
--- request
GET /=/action/TitleOnly/order_by/id
--- response
{"success":0,"error":"Arguments required: select_col"}



=== TEST 74: Invoke the new TitleOnly action (missing both params)
--- request
GET /=/action/TitleOnly/~/~
--- response
{"success":0,"error":"Arguments required: select_col order_by"}



=== TEST 75: Invoke the new TitleOnly action (a wrong param given)
--- request
GET /=/action/TitleOnly/blah/dummy
--- response
{"success":0,"error":"Arguments required: select_col order_by"}



=== TEST 76: Delete the Action action
--- request
DELETE /=/action/Action
--- response
{"success":1}



=== TEST 77: Recheck the Action action
--- request
GET /=/action/Action
--- response
{"success":0,"error":"Action \"Action\" not found."}



=== TEST 78: Recheck the action list
--- request
GET /=/action
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"},
    {"src":"/=/action/TitleOnly","name":"TitleOnly","description":null}
]



=== TEST 79: Add a new action with default values
--- request
POST /=/action/Foo
{
    "parameters": [
        {"name":"col", "type":"symbol", "default":"id"},
        {"name":"by", "type":"symbol", "default":"title"}
    ],
    "definition":"select $col from A order by $by"}
--- response
{"success":1}



=== TEST 80: Check the Foo action
--- request
GET /=/action/Foo
--- response
{
    "name":"Foo",
    "description":null,
    "parameters":[
        {"name":"col","default":"id","type":"symbol"},
        {"name":"by","type":"symbol","default":"title"}
    ],
    "definition":"select $col from A order by $by"
}



=== TEST 81: Invoke Foo w/o params
--- request
GET /=/action/Foo/~/~
--- response
[[{"id":"6"},{"id":"3"},{"id":"2"},{"id":"4"},{"id":"5"},{"id":"1"}]]



=== TEST 82: Invoke Foo with 1 param set
--- request
GET /=/action/Foo/by/id
--- response
[[{"id":"1"},{"id":"2"},{"id":"3"},{"id":"4"},{"id":"5"},{"id":"6"}]]



=== TEST 83: Invoke Foo with the other one param set
--- request
GET /=/action/Foo/col/title
--- response
[[{"title":"163"},{"title":"Baidu"},{"title":"Google"},{"title":"Sina"},{"title":"Sohu"},{"title":"Yahoo"}]]



=== TEST 84: Invoke Foo with both params set
--- request
GET /=/action/Foo/col/title?by=id
--- response
[[{"title":"Yahoo"},{"title":"Google"},{"title":"Baidu"},{"title":"Sina"},{"title":"Sohu"},{"title":"163"}]]



=== TEST 85: Bad action name
--- request
GET /=/action/!@
--- response
{"success":0,"error":"Bad action name: !@"}



=== TEST 86: Get the action list
--- request
GET /=/action
--- response
[
    {"name":"RunView","description":"View interpreter","src":"/=/action/RunView"},
    {"name":"RunAction","description":"Action interpreter","src":"/=/action/RunAction"},
    {"src":"/=/action/TitleOnly","name":"TitleOnly","description":null},
    {"src":"/=/action/Foo","name":"Foo","description":null}
]



=== TEST 87: Change the action name and definition simultaneously
--- request
PUT /=/action/Foo
{ "name": "Bah", "definition": "select * from A" }
--- response
{"success":1}



=== TEST 88: Check the old action
--- request
GET /=/action/Foo
--- response
{"success":0,"error":"Action \"Foo\" not found."}



=== TEST 89: Check the new action
--- request
GET /=/action/Bah
--- response
{
    "name":"Bah",
    "description":null,
    "parameters":[],
    "definition":"select * from A"
}



=== TEST 90: Set the description (the wrong way, typo)
--- request
PUT /=/action/Bah
{ "descripition": "Blah blah blah..." }
--- response
{"success":0,"error":"Unknown keys in POST data: descripition"}



=== TEST 91: Set the description
--- request
PUT /=/action/Bah
{ "description": "Blah blah blah..." }
--- response
{"success":1}



=== TEST 92: Check the desc
--- request
GET /=/action/Bah
--- response
{
    "name":"Bah",
    "description":"Blah blah blah...",
    "parameters":[],
    "definition":"select * from A"
}



=== TEST 93: give wrong POST data
--- request
POST /=/action/Foo
[1,2,3]
--- response
{"success":0,"error":"The action schema must be a HASH."}



=== TEST 94: Bad hash
--- request
POST /=/action/Foo
{"cat":3}
--- response
{"success":0,"error":"No \"definition\" specified."}



=== TEST 95: Re-add action Foo (Bad minisql)
--- request
POST /=/action/Foo
{"description":"Test vars for vals","name":"Foo",
    "definition":""}
--- response
{"success":0,"error":"Bad definition: \"\""}



=== TEST 96: Re-add action Foo (Bad minisql)
--- request
POST /=/action/Foo
{"description":"Test vars for vals","name":"Foo",
    "definition":"update _action set "}
--- response
{"success":0,"error":"\"action\" (line 1, column 8):\nunexpected \"_\"\nexpecting space or model"}



=== TEST 97: Re-add action Foo (Bad default value for param)
--- request
POST /=/action/Foo
{"description":"Test vars for vals","name":"Foo",
    "parameters":[
        {"name":"model", "type":"symbol", "default":"'A'"},
        {"name":"col", "type":"symbol", "default":"id"},
        {"name":"val","type":"literal"}
    ],
    "definition":"select * from $model  where $col > $val"}
--- response
{"success":0,"error":"Bad default value for parameter \"model\": "'A'"}



=== TEST 98: Re-add action Foo (Bad default value for param)
--- request
POST /=/action/Foo
{"description":"Test vars for vals","name":"Foo",
    "parameters":[
        {"name":"model", "type":"symbol", "default":[3]},
        {"name":"col", "type":"symbol", "default":"id"},
        {"name":"val","type":"literal"}
    ],
    "definition":"select * from $model  where $col > $val"}
--- response
{"success":0,"error":"Bad default value for parameter \"model\": [3]}



=== TEST 99: Re-add action Foo
--- request
POST /=/action/Foo
{"description":"Test vars for vals","name":"Foo",
    "parameters":[
        {"name":"model", "type":"symbol", "default":"A"},
        {"name":"col", "type":"symbol", "default":"id"},
        {"name":"val","type":"literal"}
    ],
    "definition":"select * from $model  where $col > $val"}
--- response
{"success":1}



=== TEST 100: Invoke the action (required vars missing)
--- request
GET /=/action/Foo/~/~
--- response
{"success":0,"error":"Arguments required: val"}



=== TEST 101: Invoke the action
--- request
GET /=/action/Foo/val/2
--- response
[[
    {"title":"Baidu","id":"3"},
    {"title":"Sina","id":"4"},
    {"title":"Sohu","id":"5"},
    {"title":"163","id":"6"}
]]



=== TEST 102: Escaped char
--- request
GET /=/action/Foo/val/林\?col=title
--- response
[[]]



=== TEST 103: Invoke the action (bad fixed var name)
--- request
GET /=/action/Foo/!@/2
--- response
{"success":0,"error":"Bad parameter name: \"!@\""}



=== TEST 104: Invoke the action (another way)
--- request
GET /=/action/Foo/~/~?val=2
--- response
[[
    {"title":"Baidu","id":"3"},
    {"title":"Sina","id":"4"},
    {"title":"Sohu","id":"5"},
    {"title":"163","id":"6"}
]]



=== TEST 105: Invoke the action (bad free var name)
--- request
GET /=/action/Foo/~/~?!@=2
--- response
{"success":0,"error":"Arguments required: val"}



=== TEST 106: Invoke the action (bad symbol)
--- request
GET /=/action/Foo/~/~?val=2&col=id"
--- response
{"success":0,"error":"Bad symbol for parameter \"col\": id\""}



=== TEST 107: Invoke the action (overriding vars)
--- request
GET /=/action/Foo/~/~?val=2&col=id
--- response
[[
    {"title":"Baidu","id":"3"},
    {"title":"Sina","id":"4"},
    {"title":"Sohu","id":"5"},
    {"title":"163","id":"6"}
]]



=== TEST 108: Create a model with cidr type
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



=== TEST 109: Insert lines to cidr table
--- request
POST /=/model/T/~/~
[
    {"cidr":"202.165.100.143"}
]
--- response
{"last_row":"/=/model/T/id/1","rows_affected":1,"success":1}



=== TEST 110: create a action with operator >>=
--- request
POST /=/action/TC
{ "definition": "select count(*) from T where cidr >>= '202.165.100.143'" }
--- response
{"success":1}



=== TEST 111: Invoke the T action
--- request
GET /=/action/TC/~/~
--- response
[[{"cidr":"202.165.100.143"}]]



=== TEST 112: bug
--- request
POST /=/action/RowCount
{ "parameters":[
    {"name":"model","type":"blah"}
   ],
   "definition": "select count(*) from $model" }
--- response
{"success":0,"error":"Bad type for parameter: \"blah\"}



=== TEST 113: bug
--- request
POST /=/action/RowCount
{ "parameters":[
    {"name":"model","type":"literal"}
   ],
   "definition": "select count(*) from $model" }
--- response
{"success":0,"error":"Invalid \"type\" for parameter \"model\". (It's used as a symbol in the action definition.)"}



=== TEST 114: bug
--- request
POST /=/action/RowCount
{ "parameters":[
    {"name":"model","type":"literal"}
   ],
   "definition": "select count(*) from $model" }
--- response
{"success":1}



=== TEST 115: view the TitleOnly action
--- request
GET /=/action/TitleOnly
--- response
{"name":"TitleOnly","parameters":[
        {"name":"select_col","type":"symbol","default":null},
        {"name":"order_by","type":"symbol","default":null}
    ],"description":null,"definition":"select $select_col from A order by $order_by"}



=== TEST 116: change the action def
--- request
PUT /=/action/TitleOnly
{ "definition": "select 32" }
--- response
{"success":1}



=== TEST 117: get the action def again:
--- request
GET /=/action/TitleOnly
--- response
{"name":"TitleOnly","description":null,"parameters":[],"definition":"select 32"}



=== TEST 118: change the action def (syntax error)
--- request
PUT /=/action/TitleOnly
{ "definition": "abc 32" }
--- response
{"error":"\"action\" (line 1, column 1):\nunexpected \"a\"\nexpecting white space or action statement","success":0}



=== TEST 119: logout
--- request
GET /=/logout
--- response
{"success":1}

