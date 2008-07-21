# vi:filetype=

use t::OpenResty;

=pod

XXX TODO:
* Add tests for model list and column list.

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Clear the environment
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model (invalid JSON)
--- request
POST /=/model/Foo
{
    "description":"foo",
    columns:
        [ {"name":"name", "label":"姓名"},
          {"name":"age", "label": "年龄", "type":"integer"}
        ]
}
--- response_like
{"success":0,"error":"Syntax error found in the JSON input: '\\"' expected, at character offset



=== TEST 3: Create a model
--- request
POST /=/model/Foo
{
    "description":"foo",
    "columns":
        [ {"name":"name", "type":"text", "label":"姓名"},
          {"name":"age", "label": "年龄", "type":"integer"}
        ]
}
--- response
{"success":1}



=== TEST 4: Insert some data
--- request
POST /=/model/Foo/~/~
[
  { "name":"Marry", "age":21 },
  { "name":"Bob", "age":32 },
  { "name":"Bob", "age": 15 },
  { "name":"Henry", "age": 19 },
  { "name":"Henry", "age": 23 },
  { "name":"Larry", "age": 59 },
  { "name":"Audrey", "age": 17 }
]
--- response
{"success":1,"rows_affected":7,"last_row":"/=/model/Foo/id/7"}



=== TEST 5: _count = 0
--- request
GET /=/model/Foo/~/~?_count=0
--- response
[]



=== TEST 6: _count > total record num
--- request
GET /=/model/Foo/~/~?_count=100
--- response
[
    {"name":"Marry","id":"1","age":"21"},
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"},
    {"name":"Larry","id":"6","age":"59"},
    {"name":"Audrey","id":"7","age":"17"}
]



=== TEST 7: _count = total record num
--- request
GET /=/model/Foo/~/~?_count=7
--- response
[
    {"name":"Marry","id":"1","age":"21"},
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"},
    {"name":"Larry","id":"6","age":"59"},
    {"name":"Audrey","id":"7","age":"17"}
]



=== TEST 8: _count = total record num - 1
--- request
GET /=/model/Foo/~/~?_count=6
--- response
[
    {"name":"Marry","id":"1","age":"21"},
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"},
    {"name":"Larry","id":"6","age":"59"}
]



=== TEST 9: _count = 1
--- request
GET /=/model/Foo/~/~?_count=1
--- response
[
    {"name":"Marry","id":"1","age":"21"}
]



=== TEST 10: _count for normal select
--- request
GET /=/model/Foo/name/Bob?_count=2
--- response
[
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"}
]



=== TEST 11: _count for normal select (1)
--- request
GET /=/model/Foo/name/Bob?_count=1
--- response
[
    {"name":"Bob","id":"2","age":"32"}
]



=== TEST 12: _count and offset
--- request
GET /=/model/Foo/~/~?_count=3&_offset=2
--- response
[
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"}
]



=== TEST 13: _limit and offset
--- request
GET /=/model/Foo/~/~?_limit=3&_offset=2
--- response
[
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"}
]



=== TEST 14: negative _count
--- request
GET /=/model/Foo/name/Bob?_count=-2
--- response
{"success":0,"error":"Invalid value for the \"_count\" param: -2"}



=== TEST 15: empty _count value
--- request
GET /=/model/Foo/name/Bob?_count=
--- response
[]



=== TEST 16: weird value
--- request
GET /=/model/Foo/name/Bob?_count=blah
--- response
{"success":0,"error":"Invalid value for the \"_count\" param: blah"}



=== TEST 17: logout
--- request
GET /=/logout
--- response
{"success":1}

