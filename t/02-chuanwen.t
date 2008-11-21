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



=== TEST 2: Delete non-existing models
--- request
DELETE /=/model/Blah.js
--- response
{"success":0,"error":"Model \"Blah\" not found."}



=== TEST 3: Create a model without desc
--- request
POST /=/model/Bookmark.js
{
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"error":"Value for \"description\" required.","success":0}



=== TEST 4: Create a model without column_label
--- request
POST /=/model/Bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "type":"text", "label": "标题" },
        { "name": "url", "type":"text" }
    ]
}
--- response
{"error":"Value for \"label\" for \"columns\" array element required.","success":0}



=== TEST 5: Create a model with illegal name, test 1st
--- request
POST /=/model/1_Bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"1_Bookmark\""}



=== TEST 6: Create a model with illegal name, test 2nd
--- request
POST /=/model/_Bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"_Bookmark\""}



=== TEST 7: Create a model with illegal name, test 3rd
--- request
POST /=/model/Bookmark.chen.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"Bookmark.chen\""}



=== TEST 8: Create a model with illegal name, test 4th
--- request
POST /=/model/Bookmark-chen.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id", "type": "serial", "label": "ID" },
        { "name": "title", "label": "标题" },
        { "name": "url", "label": "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"Bookmark-chen\""}



=== TEST 9: Create a model with name described in Manual
--- request
POST /=/model/Bookmark
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "type":"varchar  ( 20 )", "label": "标题" },
        { "name": "url", "label": "网址", "type":"text" }
    ]
}
--- response
{"success":1}



=== TEST 10: Delete newly created model
--- request
DELETE /=/model/Bookmark
--- response
{"success":1}



=== TEST 11: Create a model with name starting with lower case
--- request
POST /=/model/bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "type":"text", "label": "标题" },
        { "name": "url", "label": "网址", "type":"text" }
    ]
}
--- response
{"success":1}



=== TEST 12: Delete newly created model with different capital case
--- request
DELETE /=/model/bookmark
--- response
{"success":1}



=== TEST 13: Create a model with illegal column name
--- request
POST /=/model/Bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "_id", "type": "serial", "label": "ID" }
    ]
}
--- response
{"error":"Bad value for \"name\" for \"columns\" array element: Identifier expected.","success":0}



=== TEST 14: Create a model with illegal column name
--- request
POST /=/model/Bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id.chen", "type": "serial", "label": "ID" }
    ]
}
--- response
{"error":"Bad value for \"name\" for \"columns\" array element: Identifier expected.","success":0}



=== TEST 15: Create a model with illegal column name
--- request
POST /=/model/bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "1_id", "type": "serial", "label": "ID" }
    ]
}
--- response
{"error":"Bad value for \"name\" for \"columns\" array element: Identifier expected.","success":0}



=== TEST 16: Create a model with illegal column name
--- request
POST /=/model/bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "id-chen", "type": "serial", "label": "ID" }
    ]
}
--- response
{"error":"Bad value for \"name\" for \"columns\" array element: Identifier expected.","success":0}



=== TEST 17: Create a model with column name starting with upper case
--- request
POST /=/model/bookmark.js
{
    "description": "我的书签",
    "columns": [
        { "name": "ID", "type": "serial", "label": "ID" }
    ]
}
--- response
{"success":1,"warning":"Column \"id\" reserved. Ignored."}



=== TEST 18: Delete newly created model
--- request
DELETE /=/model/bookmark
--- response
{"success":1}



=== TEST 19: Create a model with such columns writing
--- request
POST /=/model/Bookmark.js
{
    "description": "我的书签",
    "columns": [{ "name": "id_chen", "type": "serial", "label": "ID"}]
}
--- response
{"success":1}



=== TEST 20: Delete newly created model
--- request
DELETE /=/model/Bookmark.js
--- response
{"success":1}



=== TEST 21: logout
--- request
GET /=/logout
--- response
{"success":1}

