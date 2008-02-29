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
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Foo
{
    description:"foo",
    columns:
        [ {name:"name", label:"姓名"},
          {name:"age", label: "年龄", type:"integer"}
        ]
}
--- response
{"success":1}



=== TEST 3: Insert some data
--- request
POST /=/model/Foo/~/~
[
  { name:"Marry", age:21 },
  { name:"Bob", age:32 },
  { name:"Bob", age: 15 },
  { name:"Henry", age: 19 },
  { name:"Henry", age: 23 },
  { name:"Larry", age: 59 },
  { name:"Audrey", age: 17 }
]
--- response
{"success":1,"rows_affected":7,"last_row":"/=/model/Foo/id/7"}



=== TEST 4: offset = 0
--- request
GET /=/model/Foo/~/~?offset=0
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



=== TEST 5: offset = 1
--- request
GET /=/model/Foo/~/~?offset=1
--- response
[
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"},
    {"name":"Larry","id":"6","age":"59"},
    {"name":"Audrey","id":"7","age":"17"}
]



=== TEST 6: offset = count - 1
--- request
GET /=/model/Foo/~/~?offset=6
--- response
[
    {"name":"Audrey","id":"7","age":"17"}
]



=== TEST 7: offset = count
--- request
GET /=/model/Foo/~/~?offset=7
--- response
[]



=== TEST 8: offset > count
--- request
GET /=/model/Foo/~/~?offset=8
--- response
[]



=== TEST 9: offset = 0 for normal select
--- request
GET /=/model/Foo/name/Bob?offset=0
--- response
[
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"}
]



=== TEST 10: offset = count - 1 for normal select
--- request
GET /=/model/Foo/name/Bob?offset=1
--- response
[
    {"name":"Bob","id":"3","age":"15"}
]



=== TEST 11: offset = count for normal select
--- request
GET /=/model/Foo/name/Bob?offset=2
--- response
[]



=== TEST 12: negative offset
--- request
GET /=/model/Foo/name/Bob?offset=-2
--- response
{"success":0,"error":"Invalid value for the \"offset\" param: -2"}



=== TEST 13: empty offset value
--- request
GET /=/model/Foo/name/Bob?offset=
--- response
[{"name":"Bob","id":"2","age":"32"},{"name":"Bob","id":"3","age":"15"}]



=== TEST 14: weird value
--- request
GET /=/model/Foo/name/Bob?offset=blah
--- response
{"success":0,"error":"Invalid value for the \"offset\" param: blah"}

