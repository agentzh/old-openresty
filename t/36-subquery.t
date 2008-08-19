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



=== TEST 3: Create a new model
--- request
POST /=/model/City
{"description":"City",
 "columns":[{"name":"name","label":"Name","type":"text"},
    {"name":"parent","label":"Parent","type":"integer","default":0}]
 }
--- response
{"success":1}



=== TEST 4: Insert some rows
--- request
POST /=/model/City/~/~
[
    {"name":"北京市"},
    {"name":"朝阳","parent":1},
    {"name":"宣武","parent":1}
]
--- response
{"last_row":"/=/model/City/id/3","rows_affected":3,"success":1}



=== TEST 5: Create a view
--- request
POST /=/view/Children
{"definition":"select * from City where parent in (select id from City where name like $city || '%') order by id"}
--- response
{"success":1}



=== TEST 6: Invoke the view
--- request
GET /=/view/Children/city/北京
--- response
[{"parent":"1","name":"朝阳","id":"2"},{"parent":"1","name":"宣武","id":"3"}]



=== TEST 7: Change the view def a bit using foo = (select ...)
--- request
PUT /=/view/Children
{"definition":"select name from City where parent = (select id from City where name like $city || '%') order by id"}
--- response
{"success":1}



=== TEST 8: Invoke the view
--- request
GET /=/view/Children/city/北京
--- response
[{"name":"朝阳"},{"name":"宣武"}]



=== TEST 9: Test from (select ...) as foo
--- request
PUT /=/view/Children
{"definition":"select blah.name from (select * from City where name like $city || '%' order by id) as blah"}
--- response
{"success":1}



=== TEST 10: Invoke the view
--- request
GET /=/view/Children/city/北京
--- response
[{"name":"北京市"}]



=== TEST 11: logout
--- request
GET /=/logout
--- response
{"success":1}

