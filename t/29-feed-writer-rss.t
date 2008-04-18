use strict;
use warnings;

use Test::More 'no_plan';
use Test::LongString;
use OpenResty::FeedWriter::RSS;

my $rss = OpenResty::FeedWriter::RSS->new(
    {
        title => '<h1>你好么?</h1>',
        link => 'http://blog.agentzh.org/',
        description => 'agentzh\'s madhouse',
        langauge => 'en-us',
        copyright => 'Copyright by Agent Zhang',
        pubDate => 'Sat, 15 Nov 2003 0:00:01 GMT',
        lastBuildDate => 'Mon, 25 Jan 2004 0:00:01 GMT',
    }
);
ok $rss, 'obj ok';
isa_ok $rss, 'OpenResty::FeedWriter::RSS';
is_string $rss->as_xml, <<'_EOC_';
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <title>&lt;h1&gt;你好么?&lt;/h1&gt;</title>
    <link>http://blog.agentzh.org/</link>
    <description>agentzh's madhouse</description>
    <copyright>Copyright by Agent Zhang</copyright>
    <pubDate>Sat, 15 Nov 2003 0:00:01 GMT</pubDate>
    <lastBuildDate>Mon, 25 Jan 2004 0:00:01 GMT</lastBuildDate>
  </channel>
</rss>
_EOC_

