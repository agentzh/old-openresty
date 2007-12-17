use t::OpenAPI;

=pod

XXX TODO:
* Add tests for model list and column list.

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Clear the environment
--- request
DELETE /=/model
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



=== TEST 4: count = 0
--- request
GET /=/model/Foo/~/~?count=0
--- response
[]



=== TEST 5: count > total record num
--- request
GET /=/model/Foo/~/~?count=100
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



=== TEST 6: count = total record num
--- request
GET /=/model/Foo/~/~?count=7
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



=== TEST 7: count = total record num - 1
--- request
GET /=/model/Foo/~/~?count=6
--- response
[
    {"name":"Marry","id":"1","age":"21"},
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"},
    {"name":"Larry","id":"6","age":"59"}
]



=== TEST 8: count = 1
--- request
GET /=/model/Foo/~/~?count=1
--- response
[
    {"name":"Marry","id":"1","age":"21"}
]



=== TEST 9: count for normal select
--- request
GET /=/model/Foo/name/Bob?count=2
--- response
[
    {"name":"Bob","id":"2","age":"32"},
    {"name":"Bob","id":"3","age":"15"}
]



=== TEST 10: count for normal select (1)
--- request
GET /=/model/Foo/name/Bob?count=1
--- response
[
    {"name":"Bob","id":"2","age":"32"}
]



=== TEST 11: count and offset
--- request
GET /=/model/Foo/~/~?count=3&offset=2
--- response
[
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"}
]



=== TEST 12: limit and offset
--- request
GET /=/model/Foo/~/~?limit=3&offset=2
--- response
[
    {"name":"Bob","id":"3","age":"15"},
    {"name":"Henry","id":"4","age":"19"},
    {"name":"Henry","id":"5","age":"23"}
]



=== TEST 13: negative count
--- request
GET /=/model/Foo/name/Bob?count=-2
--- response
{"success":0,"error":"Invalid value for the \"count\" param: -2"}



=== TEST 14: empty count value
--- request
GET /=/model/Foo/name/Bob?count=
--- response
[]



=== TEST 15: weird value
--- request
GET /=/model/Foo/name/Bob?count=blah
--- response
{"success":0,"error":"Invalid value for the \"count\" param: blah"}

