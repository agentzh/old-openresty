use strict;
use warnings;

use Test::More 'no_plan';
#use Test::LongString;
use OpenResty::FeedWriter::RSS;

my $rss = OpenResty::FeedWriter::RSS->new(
    {
        title => '<h1>你好么?</h1>',
        link => 'http://blog.agentzh.org/',
        description => 'agentzh\'s madhouse',
        language => 'en-us',
        copyright => 'Copyright by Agent Zhang',
        pubDate => 'Sat, 15 Nov 2003 0:00:01 GMT',
        lastBuildDate => 'Mon, 25 Jan 2004 0:00:01 GMT',
    }
);
ok $rss, 'obj ok';
isa_ok $rss, 'OpenResty::FeedWriter::RSS';

eval { $rss->as_xml };
ok $@, 'eval failed as expected';
like $@, qr/No entries found/, 'error as expected';

$rss = OpenResty::FeedWriter::RSS->new(
    {
        title => '<h1>你好么?</h1>',
        link => 'http://blog.agentzh.org/',
        description => 'agentzh\'s madhouse',
        language => 'en-us',
        copyright => 'Copyright by Agent Zhang',
        pubDate => 'Sat, 15 Nov 2003 0:00:01 GMT',
        lastBuildDate => 'Mon, 25 Jan 2004 0:00:01 GMT',
    }
);

$rss->add_entry(
    {
        title => 'Hello, world',
        author => 'agentzh',
        comments => 'http://blog.agentzh.org/#post-3:comments',
        description => 'Blah blah blah...',
        pubDate => '2007-03-04 5:34',
        category => 'IT',
        link => 'http://blog.agentzh.org/#post-3',
    }
);

$rss->add_entry(
    { title => '<h1>我来了！</h1>', link => 'http://foo.com',
      description => 'howdy!' }
);

is $rss->as_xml, <<'_EOC_';
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
  <title>&lt;h1&gt;你好么?&lt;/h1&gt;</title>
  <link>http://blog.agentzh.org/</link>
  <description>agentzh's madhouse</description>
  <language>en-us</language>
  <copyright>Copyright by Agent Zhang</copyright>
  <pubDate>Sat, 15 Nov 2003 0:00:01 GMT</pubDate>
  <lastBuildDate>Mon, 25 Jan 2004 0:00:01 GMT</lastBuildDate>
  <item>
    <title>Hello, world</title>
    <link>http://blog.agentzh.org/#post-3</link>
    <description>Blah blah blah...</description>
    <author>agentzh</author>
    <comments>http://blog.agentzh.org/#post-3:comments</comments>
    <pubDate>2007-03-04 5:34</pubDate>
    <category>IT</category>
  </item>
  <item>
    <title>&lt;h1&gt;我来了！&lt;/h1&gt;</title>
    <link>http://foo.com</link>
    <description>howdy!</description>
  </item>
  </channel>
</rss>
_EOC_

