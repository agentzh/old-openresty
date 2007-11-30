use t::OpenAPI;

plan tests => 2 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 3: Create a model
--- request
POST /=/model.js
{
    name: 'Bookmark',
    description: '我的书签',
    columns: [
        { name: 'id', type: 'serial', label: 'ID' },
        { name: 'title', label: '标题' },
        { name: 'url', label: '网址' }
    ]
}
--- response
{"success":1}



=== TEST 4: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Bookmark","name":"Bookmark","description":"我的书签"}]



=== TEST 5: check the column
--- request
GET /=/model/Bookmark.js
--- response
[
    {"name":"id","label":"ID","type":"serial"},
    {"name":"title","label":"标题","type":"text"},
    {"name":"url","label":"网址","type":"text"}
]



=== TEST 6: access inexistent models
--- request
GET /=/model/Foo.js
--- response
{"success":0,"error":"Model \"Foo\" not found."}



=== TEST 7: insert a single record
--- request
POST /=/model/Bookmark.js
{ title: 'Yahoo Search', url: 'http://www.yahoo.cn' }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/1"}



=== TEST 8: insert another record
--- request
POST /=/model/Bookmark.js
{ title: 'Yahoo Search', url: 'http://www.yahoo.cn' }
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Bookmark/id/2"}


