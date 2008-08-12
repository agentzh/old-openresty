# vi:filetype=

use t::OpenResty;

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



=== TEST 3: Create a model with various types
--- request
POST /=/model/NetAddr
{
    "description": "Type testing",
    "columns": [
        { "name": "cidr", "type": "cidr", "label": "cidr" },
        { "name": "macaddr", "type": "macaddr", "label": "macaddr" },
        { "name": "inet", "type": "inet", "label": "inet" }
    ]
}
--- response
{"success":1}



=== TEST 4: insert a line
--- request
POST /=/model/NetAddr/~/~
{ "cidr":"192.168.100.128", "macaddr":"08-00-2b-01-02-03", "inet":"192.168.100.128/25" }
--- response
{"last_row":"/=/model/NetAddr/id/1","rows_affected":1,"success":1}



=== TEST 5: Check the row that was just inserted
--- request
GET /=/model/NetAddr/id/1
--- response
[
    {
     "inet":"192.168.100.128/25",
     "macaddr":"08:00:2b:01:02:03",
     "id":"1",
     "cidr":"192.168.100.128/32"
    }
]



=== TEST 6: Add a column with type bigint
--- request
POST /=/model/NetAddr/bigint
{ "type": "bigint", "label": "Bigint" }
--- response
{"src":"/=/model/NetAddr/bigint","success":1}



=== TEST 7: Create a model with varchar types
--- request
POST /=/model/varcharTest
{
    "description": "Type testing",
    "columns": [
        { "name": "title", "type": "varchar(32)", "label": "Test for varchar type" }
    ]
}
--- response
{"success":1}



=== TEST 8: Create a model with tsquery types
XXX FIX ME
I have to skip this test since it cannot pass on Pg instances without
tsearch2 installed.
--- request
POST /=/model/tsqueryTest
{
    "description": "Type testing",
    "columns": [
        { "name": "title", "type": "tsquery", "label": "Test for tsquery type" }
    ]
}
--- response
{"success":1}
--- SKIP



=== TEST 9: Declare a char type
--- request
POST /=/model/Test
{
    "description":"test char(xxx)",
    "columns":[{"name":"foo","label":"Foo","type":"char(1)"}]
}
--- response
{"success":1}



=== TEST 10: logout
--- request
GET /=/logout
--- response
{"success":1}

