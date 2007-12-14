use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: Delete non-existing models
--- request
GET /=/model.js
--- response
{"success":0}



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



=== TEST4: Create a model without column_label
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



=== TEST5: Create a model with illegal name
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


=== TEST5: Create a model with illegal name
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



=== TEST5: Create a model with illegal name
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



=== TEST5: Create a model with illegal name
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



=== TEST6: Create a model with name described in Manual
--- request
POST /=/model/Bookmark
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":1}



--- request
DELETE /=/model/Bookmark
--- response
{"success":1}



=== TEST7: Create a model with name starting with lower case
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id", type: "serial", label: "ID" },
        { name: "title", label: "标题" },
        { name: "url", label: "网址" }
    ]
}
--- response
{"success":1}



--- request
DELETE /=/model/bookmark
--- response
{"success":1}



=== TEST8: Create a model with illegal column name
--- request
POST /=/model/Bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "_id", type: "serial", label: "ID" },
    ]
}
--- response
{"success":0}



=== TEST8: Create a model with illegal column name
--- request
POST /=/model/Bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id.chen", type: "serial", label: "ID" },
    ]
}
--- response
{"success":0}



=== TEST8: Create a model with illegal column name
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "1_id", type: "serial", label: "ID" },
    ]
}
--- response
{"success":0}



=== TEST8: Create a model with illegal column name
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "id-chen", type: "serial", label: "ID" },
    ]
}
--- response
{"success":0}



=== TEST9: Create a model with column name starting with upper case
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: [
        { name: "ID", type: "serial", label: "ID" },
    ]
}
--- response
{"success":1,"warning":"Column \"id\" reserved. Ignored."}



--- request
DELETE /=/model/Bookmark
--- response
{"success":1}



=== TEST8: Create a model with such columns writing
--- request
POST /=/model/bookmark.js
{
    description: "我的书签",
    columns: { name: "id_chen", type: "serial", label: "ID" },
}
--- response
{"success":1}
 


--- request
DELETE /=/model/Bookmark
--- response
{"success":1}