# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Login
--- request
GET /=/login/$TestAccount.Admin/$TestPass?use_cookie=1
--- response_like
^{"success":1,"session":"[-\w]+","account":"$TestAccount","role":"Admin"}$



=== TEST 2: Delete existing models
--- request
DELETE /=/model
--- response
{"success":1}


=== TEST 4: Create a model with various types
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


=== TEST 5: insert a line
--- request
POST /=/model/NetAddr/~/~
{ "cidr":"192.168.100.128", "macaddr":"08-00-2b-01-02-03", "inet":"192.168.100.128/25" }
--- response
{"last_row":"/=/model/NetAddr/id/1","rows_affected":1,"success":1}


=== TEST 6: Check the row that was just inserted
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

