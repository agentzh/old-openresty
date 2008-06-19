# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks() - 3;

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
    {"title":"Hello, world","author":"agentzh","content":"<h1>This is my first program ;)</h1>","comments":5, "created_on":"2008-03-12 15:20:00+08"},
    {"title":"I'm going home","author":"carrie","content":"<h1>At last, I'm home again! Yay!</h1>","comments":5,"created_on":"2008-02-29 20:03:00+08"},
    {"title":"我来了呀！","author":"章亦春","content":"<h1>呵呵，我<B>回来</B>了！</h1>我很开心哦，呵呵！","comments":5,"created_on":"2008-01-30 15:59:00+08"}
]
--- response
{"last_row":"/=/model/Post/id/3","rows_affected":3,"success":1}



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
  "definition": "select author, title, 'http://blog.agentzh.org/#post-' || id as link, content, created_on as published, 'http://blog.agentzh.org/#post-' || id || ':comments' as comments from Post order by created_on desc limit $count | 20"
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
    "title": "Human & Machine - Blog posts",
    "view": "PostFeed",
    "logo": "http://localhost/Blog/out/me.jpg"
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
    "title": "Human & Machine - Blog posts",
    "view": "PostFeed"
}
--- response
{"error":"Feed \"Post\" already exists.","success":0}



=== TEST 14: Get the feed list
--- request
GET /=/feed
--- response
[{"src":"/=/feed/Post","name":"Post","description":"Feed for blog posts"}]



=== TEST 15: Get the "Post" feed
--- request
GET /=/feed/Post
--- response
{
    "name": "Post",
    "description": "Feed for blog posts",
    "author": "agentzh",
    "link": "http://blog.agentzh.org",
    "copyright": "Copyright 2008 by Agent Zhang",
    "language": "en",
    "title": "Human & Machine - Blog posts",
    "view": "PostFeed"
}



=== TEST 16: Obtain the feed content (XML)
--- request
GET /=/feed/Post/~/~
--- res_type: application/rss+xml; charset=utf-8
--- format: feed
--- response
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
  <title>Human &amp; Machine - Blog posts</title>
  <link>http://blog.agentzh.org</link>
  <language>en</language>
  <copyright>Copyright 2008 by Agent Zhang</copyright>
  <generator>OpenResty RSS Feed Writer</generator>
  <pubDate>XXX</pubDate>
  <lastBuildDate>XXX</lastBuildDate>
  <image>
    <url>http://localhost/Blog/out/me.jpg</url>
    <link>http://blog.agentzh.org</link>
    <title>Human &amp; Machine - Blog posts</title>
  </image>
  <item>
    <title>Hello, world</title>
    <link>http://blog.agentzh.org/#post-1</link>
    <description>&lt;h1&gt;This is my first program ;)&lt;/h1&gt;</description>
    <author>agentzh</author>
    <comments>http://blog.agentzh.org/#post-1:comments</comments>
    <pubDate>2008-03-12T15:20:00Z</pubDate>
    <guid isPermaLink="true">http://blog.agentzh.org/#post-1</guid>
  </item>
  <item>
    <title>I'm going home</title>
    <link>http://blog.agentzh.org/#post-2</link>
    <description>&lt;h1&gt;At last, I'm home again! Yay!&lt;/h1&gt;</description>
    <author>carrie</author>
    <comments>http://blog.agentzh.org/#post-2:comments</comments>
    <pubDate>2008-02-29T20:03:00Z</pubDate>
    <guid isPermaLink="true">http://blog.agentzh.org/#post-2</guid>
  </item>
  <item>
    <title>我来了呀！</title>
    <link>http://blog.agentzh.org/#post-3</link>
    <description>&lt;h1&gt;呵呵，我&lt;B&gt;回来&lt;/B&gt;了！&lt;/h1&gt;我很开心哦，呵呵！</description>
    <author>章亦春</author>
    <comments>http://blog.agentzh.org/#post-3:comments</comments>
    <pubDate>2008-01-30T15:59:00Z</pubDate>
    <guid isPermaLink="true">http://blog.agentzh.org/#post-3</guid>
  </item>
  </channel>
</rss>



=== TEST 17: Obtain the feed content using param (XML)
--- request
GET /=/feed/Post/count/1
--- res_type: application/rss+xml; charset=utf-8
--- format: feed
--- response
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
  <title>Human &amp; Machine - Blog posts</title>
  <link>http://blog.agentzh.org</link>
  <language>en</language>
  <copyright>Copyright 2008 by Agent Zhang</copyright>
  <generator>OpenResty RSS Feed Writer</generator>
  <pubDate>XXX</pubDate>
  <lastBuildDate>XXX</lastBuildDate>
  <image>
    <url>http://localhost/Blog/out/me.jpg</url>
    <link>http://blog.agentzh.org</link>
    <title>Human &amp; Machine - Blog posts</title>
  </image>
  <item>
    <title>Hello, world</title>
    <link>http://blog.agentzh.org/#post-1</link>
    <description>&lt;h1&gt;This is my first program ;)&lt;/h1&gt;</description>
    <author>agentzh</author>
    <comments>http://blog.agentzh.org/#post-1:comments</comments>
    <pubDate>2008-03-12T15:20:00Z</pubDate>
    <guid isPermaLink="true">http://blog.agentzh.org/#post-1</guid>
  </item>
  </channel>
</rss>



=== TEST 18: security hole suggested by laser++
--- debug: 1
--- request
GET /=/feed/Post/count/*
--- response
{"success":0,"error":"invalid input syntax for integer: \"*\""}



=== TEST 19: security hole suggested by laser++
--- debug: 0
--- request
GET /=/feed/Post/count/*
--- response
{"success":0,"error":"Operation failed."}



=== TEST 20: another security hole suggested by laser++
--- request
GET /=/feed/Post/count/-1
--- response
{"success":0,"error":"No entries found"}



=== TEST 21: Create another feed
--- request
POST /=/feed/Comment
{
    "description": "Feed for blog comments",
    "link": "http://blog.agentzh.org",
    "copyright": "Copyright by the individual commment senders",
    "language": "en",
    "title": "Human & Machine - Blog comments",
    "view": "PostFeed"
}
--- response
{"success":1}



=== TEST 22: Get the feed list again
--- request
GET /=/feed
--- response
[
    {"src":"/=/feed/Post","name":"Post","description":"Feed for blog posts"},
    {"src":"/=/feed/Comment","name":"Comment","description":"Feed for blog comments"}
]



=== TEST 23: Delete feed Comment
--- request
DELETE /=/feed/Comment
--- response
{"success":1}



=== TEST 24: Get the feed list again
--- request
GET /=/feed
--- response
[
    {"src":"/=/feed/Post","name":"Post","description":"Feed for blog posts"}
]



=== TEST 25: Delete feed Comment again
--- request
DELETE /=/feed/Comment
--- response
{"error":"Feed \"Comment\" not found.","success":0}

