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



=== TEST 3: Delete existing views
--- request
DELETE /=/view
--- response
{"success":1}



=== TEST 4: Delete existing feeds
--- request
DELETE /=/feed
--- response
{"success":1}



=== TEST 5: Check the feed list
--- request
GET /=/feed
--- response
[]



=== TEST 6: Create a sample model
--- request
POST /=/model/Post
{
    "description": "Blog post",
    "columns": [
        {"name": "title", "label": "Title", "type": "text"},
        {"name": "author", "label": "Author", "type": "text"},
        {"name": "content", "label": "Content", "type": "text"},
        {"name": "created_on", "label": "Created on", "type": "timestamp (0) with time zone", "default": ["now()"]},
        {"name": "comments", "label": "Number of comments", "type":"integer", "default":0}
    ]
}
--- response
{"success":1}



=== TEST 7: Insert some records
--- request
POST /=/model/Post/~/~
[
    {"title":"Hello, world","author":"agentzh","content":"<h1>This is my first program ;)</h1>","comments":5},
    {"title":"I'm going home","author":"agentzh","content":"<h1>At last, I'm home again! Yay!</h1>","comments":5}
]
--- response
{"last_row":"/=/model/Post/id/2","rows_affected":2,"success":1}



=== TEST 8: Create a feed without "view"
--- request
POST /=/feed/Post
{
    "description": "View for post feeds",
    "author": "agentzh",
    "link": "http://blog.agentzh.org",
    "copyright": "Copyright 2008 by Agent Zhang",
    "language": "en",
    "title": "Human & Machine"
}
--- response
{"error":"No 'view' specified.","success":0}



=== TEST 9: Create a feed with an undefined view
--- request
POST /=/feed/Post
{
    "description": "View for post feeds",
    "author": "agentzh",
    "link": "http://blog.agentzh.org",
    "copyright": "Copyright 2008 by Agent Zhang",
    "language": "en",
    "title": "Human & Machine",
    "view": "Blah"
}
--- response
{"error":"View \"Blah\" not found.","success":0}



=== TEST 10: Create a view
--- request
POST /=/view/PostFeed
{
  "description": "View for post feeds",
  "definition": "select author, title, 'http://blog.agentzh.org/#post-' || id as link, content as summary, created_on as published from Post order by created_on desc limit 20"
}
--- response
{"success":1}



=== TEST 11: Create a feed without link
--- request
POST /=/feed/Post
{
    "description": "Feed for blog posts",
    "author": "agentzh",
    "copyright": "Copyright 2008 by Agent Zhang",
    "language": "en",
    "title": "Human & Machine",
    "view": "PostFeed"
}
--- response
{"error":"No 'link' specified.","success":0}



=== TEST 12: Create a feed successfully
--- request
POST /=/feed/Post
{
    "description": "Feed for blog posts",
    "author": "agentzh",
    "link": "http://blog.agentzh.org",
    "copyright": "Copyright 2008 by Agent Zhang",
    "language": "en",
    "title": "Human & Machine",
    "view": "PostFeed"
}
--- response
{"success":1}



=== TEST 13: Try to create a feed twice
--- request
POST /=/feed/Post
{
    "description": "Feed for blog posts",
    "author": "agentzh",
    "link": "http://blog.agentzh.org",
    "copyright": "Copyright 2008 by Agent Zhang",
    "language": "en",
    "title": "Human & Machine",
    "view": "PostFeed"
}
--- response
{"error":"Feed \"Post\" already exists.","success":0}



=== TEST 14: Get the feed list
--- request
GET /=/feed
--- response
[{"src":"/=/feed/Post","name":"Post","description":"Feed for blog posts"}]

