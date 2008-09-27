# vi:filetype=

my $ExePath;
BEGIN {
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found.\n";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable.\n";
        return;
    }
};
use t::OpenResty $skip ? (skip_all => $skip) : ();

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
{"success":1,"warning":"Builtin actions were skipped."}



=== TEST 3: Create a model
--- request
POST /=/model/Carrie.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "type":"text", "label": "标题" },
        { "name": "url", "type":"text", "label": "网址" },
        { "name": "num", "type": "integer", "label": "num" }
    ]
}
--- response
{"success":1}



=== TEST 4: insert a record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"hello carrie","url":"http://www.carriezh.cn/","num":"10"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/1"}



=== TEST 5: insert another record
--- request
POST /=/model/Carrie/~/~.js
{ "title":"second","url":"http://zhangxiaojue.cn","num":"1"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 6: create an action
--- request
POST /=/action/Query
{"definition":
"select * from Carrie where title = 'hello carrie' and num=10; select * from Carrie where title = 'hello carrie' and num=10;"}
--- response
{"success":1}



=== TEST 7: Invoke the action
--- request
GET /=/action/Query/~/~
--- response
[
    [{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}],
    [{"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"}]
]



=== TEST 8: Update the def to introduce vars
--- request
PUT /=/action/Query
{
    "parameters":[{"name":"num","type":"literal"}],
    "definition": "select title from Carrie where num = $num; select url from Carrie where num = $num"}
--- response
{"error":"Unrecognized key in hash: parameters","success":0}



=== TEST 9: Add a parameter
--- request
POST /=/action/Query/~
{"name":"num","type":"literal"}
--- response
{"src":"/=/model/Query/num","success":1}



=== TEST 10: Update the definition
--- request
PUT /=/action/Query
{ "definition": "select title from Carrie where num = $num; select url from Carrie where num = $num"}
--- response
{"success":1}



=== TEST 11: Invoke the action
--- request
GET /=/action/Query/num/10
--- response
[
    [{"title":"hello carrie"}],
    [{"url":"http://www.carriezh.cn/"}]
]



=== TEST 12: Invoke the action
--- request
GET /=/action/Query/num/1
--- response
[
    [{"title":"second"}],
    [{"url":"http://zhangxiaojue.cn"}]
]



=== TEST 13: Reference nonexistent models
--- request
PUT /=/action/Query
{ "definition":
"select * from BlahBlah limit 1 offset 1"}
--- response
{"success":0,"error":"Model \"BlahBlah\" not found."}



=== TEST 14: Try to reference meta models
--- request
PUT /=/action/Query
{ "definition":
"select * from _models limit 1 offset 1"}
--- response
{"error":"\"action\" (line 1, column 15):\nunexpected \"_\"\nexpecting space or model","success":0}



=== TEST 15: Invalid method
--- request
PUT /=/action/RunAction/~/~
{"definition":""}
--- response
{"success":0,"error":"HTTP PUT method not supported for action exec."}



=== TEST 16: Empty restyscript string
--- request
PUT /=/action/RunAction
{"definition":""}
--- response
{"error":"Restyscript source must be an non-empty literal string: \"\"","success":0}
--- SKIP



=== TEST 17: GET rows
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"10","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"1","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 18: Add a new parameter
--- request
POST /=/action/Query/~
{"name":"num","type":"literal","default":"5"}
--- response
{"success":0,"error":"Unrecognized key in hash: default"}



=== TEST 19: Add a default value
--- request
PUT /=/action/Query/num
{"default_value":"5"}
--- response
{"success":1}



=== TEST 20: Update some rows
--- request
PUT /=/action/Query
{
  "definition":
    "update Carrie set num=$num where num=10 or num=1"
}
--- response
{"success":1}



=== TEST 21: Invoke the new Query action
--- request
GET /=/action/Query/~/~
--- response
[{"success":1,"rows_affected":2}]



=== TEST 22: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"5","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"5","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 23: run the action again
--- request
GET /=/action/Query/~/~
--- response
[{"success":1,"rows_affected":0}]



=== TEST 24: run the action again (with argument)
--- request
GET /=/action/Query/num/7
--- response
[{"success":1,"rows_affected":0}]



=== TEST 25: Add a parameter
--- request
POST /=/action/Query/~
{"name":"col","type":"symbol"}
--- response
{"success":1,"src":"/=/model/Query/col"}



=== TEST 26: Do two updates
--- request
PUT /=/action/Query
{"definition":
    "update Carrie set $col=7 where id=1; update Carrie set $col=8 where id=2"}
--- response
{"success":1}



=== TEST 27: Run the action w/o arguments
--- request
GET /=/action/Query/~/~
--- response
{"success":0,"error":"Arguments required: col"}



=== TEST 28: Run the action with arguments
--- request
POST /=/action/Query/~/~
{"col":"_access"}
--- response
{"success":0,"error":"Bad value for parameter \"col\"."}



=== TEST 29: Run the action with arguments
--- request
POST /=/action/Query/~/~
{"col":"num"}
--- response
[{"success":1,"rows_affected":1},{"success":1,"rows_affected":1}]



=== TEST 30: Run the action with invalid arguments
--- request
POST /=/action/Query/~/~
{"col":"@#@@$^^#@"}
--- response
{"success":0,"error":"Bad value for parameter \"col\"."}



=== TEST 31: Run the action in the right way
--- request
POST /=/action/Query/~/~
{"col":"num"}
--- response
[{"rows_affected":1,"success":1},{"rows_affected":1,"success":1}]



=== TEST 32: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[
    {"num":"7","url":"http://www.carriezh.cn/","title":"hello carrie","id":"1"},
    {"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}
]



=== TEST 33: remove parameters
--- request
DELETE /=/action/Query/~
--- response
{"success":0,"error":"Failed to remove parameter \"col\": it's used in the definition."}



=== TEST 34: remove parameters
--- request
PUT /=/action/Query
{"definition":"select 0"}
--- response
{"success":1}



=== TEST 35: remove parameters
--- request
DELETE /=/action/Query/~
--- response
{"success":1}



=== TEST 36: check the action
--- request
GET /=/action/Query/~
--- response
[]



=== TEST 37: Add a new parameter
--- request
POST /=/action/Query/dir
{"type":"keyword"}
--- response
{"success":1,"src":"/=/model/Query/dir"}



=== TEST 38: order by a var
--- request
PUT /=/action/Query
{"definition":
"select id from Carrie order by id $dir"}
--- response
{"success":1}



=== TEST 39: invoke it with dir = asc
--- request
GET /=/action/Query/dir/asc
--- response
[[
    {"id":"1"},
    {"id":"2"}
]]



=== TEST 40: invoke it with dir = desc
--- request
GET /=/action/Query/dir/desc
--- response
[[
    {"id":"2"},
    {"id":"1"}
]]



=== TEST 41: invoke with invalid dir
--- request
GET /=/action/Query/dir/blah'
--- response
{"error":"Invalid valud for parameter \"dir\".","success":0}



=== TEST 42: Add a new parameter
--- request
POST /=/action/Query/num
{"type":"literal"}
--- response
{"success":1,"src":"/=/model/Query/num"}



=== TEST 43: Delete rows
--- request
PUT /=/action/Query
{"definition":"delete from Carrie\n where num = $num;;"
}
--- response
{"success":1}



=== TEST 44: Invoke the action
--- request
GET /=/action/Query/num/7
--- response
[{"success":1,"rows_affected":1}]



=== TEST 45: check rows again
--- request
GET /=/model/Carrie/~/~
--- response
[{"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]



=== TEST 46: Add a new parameter Yahoo
--- request
POST /=/action/Query/~
{"name":"Yahoo","type":"literal"}
--- response
{"success":1,"src":"/=/model/Query/Yahoo"}



=== TEST 47: Add a new parameter Yahoo (twice)
--- request
POST /=/action/Query/~
{"name":"Yahoo","type":"literal"}
--- response
{"error":"Parameter \"Yahoo\" already exists in action \"Query\".","success":0}



=== TEST 48: Add a new parameter Google
--- request
POST /=/action/Query/~
{"name":"Google","type":"literal"}
--- response
{"success":1,"src":"/=/model/Query/Google"}



=== TEST 49: Insert some more data via actions
--- request
PUT /=/action/Query
{"definition":
"POST '/=/model/Carrie' || '/~/~' [{num: 5, url: 'yahoo.cn', title: $Yahoo}, {'num': 6, url: 'google' || '.com', \"title\": $Google}]"
}
--- response
{"success":1}



=== TEST 50: Invoke it
--- request
GET /=/action/Query/Yahoo/Yahoo?Google=Google
--- response
[{"success":1,"rows_affected":2,"last_row":"/=/model/Carrie/id/4"}]



=== TEST 51: Add a new parameter col
--- request
POST /=/action/Query/~
{"name":"col","type":"symbol"}
--- response
{"success":1,"src":"/=/model/Query/col"}



=== TEST 52: three GET in an action
--- request
PUT /=/action/Query
{"definition":
"GET '/=/model/Carrie' || '/' || $col || '/4'; GET '/=/model/Carrie/' || $col || '/3';\n GET '/=/model/Carrie/' || $col || '/2';"
}
--- response
{"success":1}



=== TEST 53: Invoke it
--- request
GET /=/action/Query/col/id
--- response
[
    [{"num":"6","url":"google.com","title":"Google","id":"4"}],
    [{"num":"5","url":"yahoo.cn","title":"Yahoo","id":"3"}],
    [{"num":"8","url":"http://zhangxiaojue.cn","title":"second","id":"2"}]
]



=== TEST 54: three GET in an action (with exceptions)
--- request
PUT /=/action/Query
{"definition":
"GET '/=/model/Carrie' || '/id/4'; GET '/=/blah/blah'; GET '/=/model';"
}
--- response
{"success":1}



=== TEST 55: Invoke it
--- request
GET /=/action/Query/~/~
--- response
[
    [{"id":"4","num":"6","title":"Google","url":"google.com"}],
    {"error":"Handler for the \"blah\" category not found.","success":0},
    [{"description":"我的书签","name":"Carrie","src":"/=/model/Carrie"}]
]



=== TEST 56: Invoke it using yaml
--- request
GET /=/action/Query/~/~.yml
--- format: YAML
--- response
---
-
  -
    id: 4
    num: 6
    title: Google
    url: google.com
-
  error: Handler for the "blah" category not found.
  success: 0
-
  -
    description: "\xE6\x88\x91\xE7\x9A\x84\xE4\xB9\xA6\xE7\xAD\xBE"
    name: Carrie
    src: /=/model/Carrie



=== TEST 57: Add a new parameter model
--- request
POST /=/action/Query/~
{"name":"model","type":"symbol"}
--- response
{"success":1,"src":"/=/model/Query/model"}



=== TEST 58: delete mixed in 2 GET
--- request
PUT /=/action/Query
{"definition":
"DELETE '/=/model/'||$model|| '/id/4';\n GET ('/=/model/'||$model||'/~/~') ; delete from Carrie where id = 3\n ;GET '/=/' || ('model/' || $model ||'/~/~')"
}
--- response
{"success":1}



=== TEST 59: Invoke it
--- request
GET /=/action/Query/model/Carrie
--- response
[
    {"rows_affected":1,"success":1},
    [
        {"id":"2","num":"8","title":"second","url":"http://zhangxiaojue.cn"},
        {"id":"3","num":"5","title":"Yahoo","url":"yahoo.cn"}
    ],
    {"rows_affected":1,"success":1},
    [{"id":"2","num":"8","title":"second","url":"http://zhangxiaojue.cn"}]
]



=== TEST 60: access another account
--- request
POST /=/action/Query2
{"definition":
"DELETE '/=/model?_user=' || $user || '&_password=' || $pass;\nPOST '/=/model/Another' {\"description\":\"a model in another account\"};\n GET '/=/model';\n GET '/=/model?_user=$TestAccount2&_password=$TestPass2'",
"parameters":[
    {"name":"user","type":"literal"},
    {"name":"pass","type":"literal"}
]}
--- response
{"success":1}



=== TEST 61: Invoke it
--- request
POST /=/action/Query2/user/$TestAccount2
{"pass":"$TestPass2"}
--- response
[
    {"success":1},
    {"success":1,"warning":"No 'columns' specified for model \"Another\"."},
    [
      {"description":"我的书签","name":"Carrie","src":"/=/model/Carrie"},
      {"description":"a model in another account","name":"Another","src":"/=/model/Another"}
    ],
    []
]



=== TEST 62: check Test account 2:
--- request
GET /=/model?_user=$TestAccount2&_password=$TestPass2
--- response
[]



=== TEST 63: recheck Test account 1:
--- request
GET /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
[
    {"src":"/=/model/Carrie","name":"Carrie","description":"我的书签"},
    {"src":"/=/model/Another","name":"Another","description":"a model in another account"}
]



=== TEST 64: NewComment
--- request
POST /=/action/NewComment
{
    "description":"New comment",
    "parameters":[
        { "name": "sender", "type": "literal" },
        { "name": "email", "type": "literal" },
        { "name": "url", "type": "literal" },
        { "name": "body", "type": "literal" },
        { "name": "post_id", "type": "literal" }
    ],
    "definition":"POST '/=/model/Comment/~/~' { sender: $sender, email: $email, url: $url, body: $body, post: $post_id }; update Carrie set num = num + 1 where id = $post_id;"
}
--- response
{"success":1}



=== TEST 65: logout
--- request
GET /=/logout
--- response
{"success":1}

