# vi:filetype=

use t::OpenResty;

=pod

This test file test a bug such as  DELETE /=/model/xxx/xxx?op=contains

TODO
* many...

=cut

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login
--- request
GET /=/login/$TestAccount.Admin/$TestPass?_use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 2: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}



=== TEST 3: Create a employee model
--- request
POST /=/model/Employee
{
    "description": "Employee",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "name",   "type":"text", "label": "名称" },
        { "name": "age",    "type":"smallint",  "label": "年龄" },
        { "name": "salary", "type":"smallint",  "label": "薪水" },
        { "name": "addr",   "type":"text", "label": "地址" }
    ]
}
--- response
{"success":1,"warning":"Column \"id\" reserved. Ignored."}



=== TEST 4: insert multiple records
--- request
POST /=/model/Employee/~/~
[
    { "name": "name1", "age": "20", "salary": "2500", "addr": "上海市南京路" },
    { "name": "name2", "age": "30", "salary": "2500", "addr": "上海市南京路" },
    { "name": "name3", "age": "40", "salary": "2500", "addr": "china.中国上海市南京路" },
    { "name": "name4", "age": "24", "salary": "1600", "addr": "南京路" },
    { "name": "name5", "age": "23", "salary": "1500", "addr": "南京路" }
]
--- response
{"success":1,"rows_affected":5,"last_row":"/=/model/Employee/id/5"}



=== TEST 5: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "1", "name": "name1", "age": "20", "salary": "2500", "addr": "上海市南京路" },
    {"id": "2", "name": "name2", "age": "30", "salary": "2500", "addr": "上海市南京路" },
    {"id": "3", "name": "name3", "age": "40", "salary": "2500", "addr": "china.中国上海市南京路" },
    {"id": "4", "name": "name4", "age": "24", "salary": "1600", "addr": "南京路" },
    {"id": "5", "name": "name5", "age": "23", "salary": "1500", "addr": "南京路" }
]



=== TEST 6: if salary less than or equal 1600 , then update the salary = 2000  
--- request
PUT /=/model/Employee/salary/1600?_op=le
{ "salary": "2000"}
--- response
{"success":1,"rows_affected":2}



=== TEST 7: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "1", "name": "name1", "age": "20", "salary": "2500", "addr": "上海市南京路" },
    {"id": "2", "name": "name2", "age": "30", "salary": "2500", "addr": "上海市南京路" },
    {"id": "3", "name": "name3", "age": "40", "salary": "2500", "addr": "china.中国上海市南京路" },
    {"id": "4", "name": "name4", "age": "24", "salary": "2000", "addr": "南京路" },
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" }
]



=== TEST 8: if addr contains 上海, then update the salary = 3000  
--- request
PUT /=/model/Employee/addr/上海?_op=contains
{ "salary": "3000"}
--- response
{"success":1,"rows_affected":3}



=== TEST 9: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "1",  "name": "name1", "age": "20", "salary": "3000", "addr": "上海市南京路" },
    {"id": "2",  "name": "name2", "age": "30", "salary": "3000", "addr": "上海市南京路" },
    {"id": "3",  "name": "name3", "age": "40", "salary": "3000", "addr": "china.中国上海市南京路" },
    {"id": "4",  "name": "name4", "age": "24", "salary": "2000", "addr": "南京路" },
    {"id": "5",  "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" }
]



=== TEST 10: if addr contains 上海, then delete the row  
--- request
DELETE /=/model/Employee/addr/上海?_op=contains
--- response
{"success":1,"rows_affected":3}



=== TEST 11: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "4",  "name": "name4", "age": "24", "salary": "2000", "addr": "南京路" },
    {"id": "5",  "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" }
]



=== TEST 12: if age less than 24, then delete the row  
--- request
DELETE /=/model/Employee/age/24?op_lt
--- response
{"success":1,"rows_affected":1}



=== TEST 13: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5",  "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" }
]



=== TEST 14: insert multiple records again
--- request
POST /=/model/Employee/~/~
[
    { "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    { "name": "china7", "age": "30", "salary": "4500", "addr": "上海市南京路" },
    { "name": "name8", "age": "40", "salary": "9900", "addr": "china.中国上海市南京路" },
    { "name": "name9", "age": "24", "salary": "500", "addr": "南京路" }
]
--- response
{"success":1,"rows_affected":4,"last_row":"/=/model/Employee/id/9"}



=== TEST 15: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" },
    {"id": "6", "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    {"id": "7", "name": "china7", "age": "30", "salary": "4500", "addr": "上海市南京路" },
    {"id": "8", "name": "name8", "age": "40", "salary": "9900", "addr": "china.中国上海市南京路" },
    {"id": "9", "name": "name9", "age": "24", "salary": "500", "addr": "南京路" }
]



=== TEST 16: get all rows that a column contain "china"
--- request
GET /=/model/Employee/~/china?_op=contains&_order_by=id
--- response
[
    {"id": "7", "name": "china7", "age": "30", "salary": "4500", "addr": "上海市南京路" },
    {"id": "8", "name": "name8", "age": "40", "salary": "9900", "addr": "china.中国上海市南京路" }
]



=== TEST 17: test get rows by op value "ge" 
--- request
GET /=/model/Employee/~/china?_op=ge
--- response
{"success":0, "error":"_op value not supported for values other than contains and eq."}



=== TEST 18: update rows that a col contain "china"
--- request
PUT /=/model/Employee/~/china?_op=contains
{"salary": "5000"}
--- response
{"success":1,"rows_affected":2}



=== TEST 19: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" },
    {"id": "6", "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    {"id": "7", "name": "china7", "age": "30", "salary": "5000", "addr": "上海市南京路" },
    {"id": "8", "name": "name8", "age": "40", "salary": "5000", "addr": "china.中国上海市南京路" },
    {"id": "9", "name": "name9", "age": "24", "salary": "500", "addr": "南京路" }
]



=== TEST 20: test update rows by op value le
--- request
PUT /=/model/Employee/~/china?_op=le
{"salary": "4000"}
--- response
{"success":0, "error":"_op value not supported for values other than contains and eq."}



=== TEST 21: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" },
    {"id": "6", "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    {"id": "7", "name": "china7", "age": "30", "salary": "5000", "addr": "上海市南京路" },
    {"id": "8", "name": "name8", "age": "40", "salary": "5000", "addr": "china.中国上海市南京路" },
    {"id": "9", "name": "name9", "age": "24", "salary": "500", "addr": "南京路" }
]



=== TEST 22: delete rows that a col contain "china"
--- request
DELETE /=/model/Employee/~/china?_op=contains
--- response
{"success":1,"rows_affected":2}



=== TEST 23: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" },
    {"id": "6", "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    {"id": "9", "name": "name9", "age": "24", "salary": "500", "addr": "南京路" }
]



=== TEST 24: delete rows by op value le
--- request
PUT /=/model/Employee/~/china?_op=ge
{"salary": "4000"}
--- response
{"success":0, "error":"_op value not supported for values other than contains and eq."}



=== TEST 25: get all rows that age contain "2"
--- request
GET /=/model/Employee/age/2?_op=contains&_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" },
    {"id": "6", "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    {"id": "9", "name": "name9", "age": "24", "salary": "500", "addr": "南京路" }
]



=== TEST 26: update rows that salary contain "2"
--- request
PUT /=/model/Employee/salary/500?_op=contains
{"addr": "上海市南京路"}
--- response
{"success": 1, "rows_affected": 2}



=== TEST 27: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" },
    {"id": "6", "name": "name6", "age": "20", "salary": "3500", "addr": "上海市南京路" },
    {"id": "9", "name": "name9", "age": "24", "salary": "500", "addr": "上海市南京路" }
]



=== TEST 28: delete rows that salary contain "2"
--- request
DELETE /=/model/Employee/salary/500?_op=contains
--- response
{"success": 1, "rows_affected": 2}



=== TEST 29: get all rows
--- request
GET /=/model/Employee/~/~?_order_by=id
--- response
[
    {"id": "5", "name": "name5", "age": "23", "salary": "2000", "addr": "南京路" }
]



=== TEST 30: logout
--- request
GET /=/logout
--- response
{"success":1}

