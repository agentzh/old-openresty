# vi:filetype=

use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?user=$TestAccount&password=$TestPass&use_cookie=1
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
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":0,"error":"No 'description' specified for model \"Bookmark\"."}



=== TEST 4: Create a model without column_label
--- request
POST /=/model/Bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url" }
    ]
}
--- response
{"success":0,"error":"No 'label' specified for column \"url\" in model \"Bookmark\"."}



=== TEST 5: Create a model with illegal name, test 1st
--- request
POST /=/model/1_Bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"1_Bookmark\""}



=== TEST 6: Create a model with illegal name, test 2nd
--- request
POST /=/model/_Bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"_Bookmark\""}



=== TEST 7: Create a model with illegal name, test 3rd
--- request
POST /=/model/Bookmark.chen.js
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"Bookmark.chen\""}



=== TEST 8: Create a model with illegal name, test 4th
--- request
POST /=/model/Bookmark-chen.js
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":0,"error":"Bad model name: \"Bookmark-chen\""}



=== TEST 9: Create a model with name described in Manual
--- request
POST /=/model/Bookmark
{
    description: "我的书签",
    columns: [
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
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
    description: "我的书签",
    columns: [
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
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
    description: "我的书签",
    columns: [
        { name: "_id", type: "serial", label: "ID" }
    ]
}
--- response
{"success":0,"error":"Bad column name: _id"}



=== TEST 14: Create a model with illegal column name
--- request
POST /=/model/Bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id.chen", type: "serial", label: "ID" }
    ]
}
--- response
{"success":0,"error":"Bad column name: id.chen"}



=== TEST 15: Create a model with illegal column name
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "1_id", type: "serial", label: "ID" }
    ]
}
--- response
{"success":0,"error":"Bad column name: 1_id"}



=== TEST 16: Create a model with illegal column name
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id-chen", type: "serial", label: "ID" }
    ]
}
--- response
{"success":0,"error":"Bad column name: id-chen"}



=== TEST 17: Create a model with column name starting with upper case
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "ID", type: "serial", label: "ID" }
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
    description: "我的书签",
    columns: { name: "id_chen", type: "serial", label: "ID" }
}
--- response
{"success":1}
 



=== TEST 20: Delete newly created model
--- request
DELETE /=/model/Bookmark.js
--- response
{"success":1}

