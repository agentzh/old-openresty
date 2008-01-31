#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
use YAML 'Dump';
use lib '/home/agentz/hack/openapi/trunk/lib';
use WWW::OpenAPI::Simple;

my $openapi = WWW::OpenAPI::Simple->new( { server => 'http://localhost' } );
$openapi->login('agentzh', 4423037);
$openapi->delete("/=/model");

$openapi->post({
    description => "Blog post",
    columns => [
        { name => 'title', label => 'Post title' },
        { name => 'content', label => 'Post content' },
        { name => 'author', label => 'Post author' },
        { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Post creation time' },
    ],
}, '/=/model/Post');

$openapi->post({
    description => "Blog comment",
    columns => [
        { name => 'sender', label => 'Comment sender' },
        { name => 'email', label => 'Sender email address' },
        { name => 'body', label => 'Comment body' },
        { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Comment creation time' },

    ],
}, '/=/model/Comment');

print Dump($openapi->get('/=/model')), "\n";
#print Dump($openapi->get('/=/model/Post')), "\n";
#print Dump($openapi->get('/=/model/Comment')), "\n";

my ($title, $buffer);
while (<DATA>) {
    if ($_ and !$title) {
        $title = $_;
    } elsif (m{^////////+$}) {
        $openapi->post({
            author => '章亦春',
            title => $title,
            content => $buffer,
        }, '/=/model/Post/~/~');
        undef $title;
        undef $buffer;
    } else {
        $buffer .= $_;
    }
}
if ($title && $buffer) {
    $openapi->post({
        author => '章亦春',
        title => $title,
        content => $buffer,
    }, '/=/model/Post/~/~');
}

print Dump($openapi->get('/=/model/Post/~/~')), "\n";

__DATA__

写了一篇东西到"雅虎搜索日志"
写了一篇东西到我们 Yahoo 自己的"雅虎搜索日志"网站上：<br><br>&nbsp;&nbsp;&nbsp;&nbsp; <a href="http://ysearchblog.cn/2007/11/searchall.html">http://ysearchblog.cn/2007/11/searchall.html</a><br><br>感谢咱们 content team 的何远银同学提供的初稿。毕竟发起一些东西不是我的长项，而大刀阔斧地修改现成的东西却是，呵呵。
<br><br>另外还必须特别感谢一下我的编辑石杏岚小姐不厌其烦地反复修改这篇东西。在修改过 N 处之后，她终于说自己快崩溃了，呵呵。<br><br>这里顺便 spam 一下，SearchAll 的下一个版本将提供一个全新的视图，Mapping View：<br><br>&nbsp;&nbsp; <a href="http://agentzh.org/misc/mapview.png">http://agentzh.org/misc/mapview.png</a><br><br>欢迎大家试用 Subversion 里的版本：<br><br>&nbsp;&nbsp;&nbsp; <a href="http://svn.openfoundry.org/searchall/trunk/searchall.xpi">
http://svn.openfoundry.org/searchall/trunk/searchall.xpi</a><br><br>Enjoy!<br><br>-agentzh


/////////////////////////////

Yahoo! 4e team 贺岁语录
"妈呀，又是测试啊？" -- leiyh<br><br>"话说……你加的功能 work 了！" -- carrie<br><br>"这事咋办呢？让我想想。。。" -- ting<br><br>"每日常坐电脑前，每逢春秋必感冒。锻炼永远计划中，感冒一直在行动。" -- jianingy<br><br>"谁说我不乖的？我很乖的。" -- ywayne
<br><br>"咦？是 exe 的。。。我来 hack 一下。。。" -- shangerdi<br><br>"哈哈！央视8套真好看,讲苍蝇飞行的原理 :D" -- laser<br><br>"锅得刚说了，铛铛铛，铛儿嘀儿嘀个儿铛！" -- arthas<br><br>"yay! it works! :D" -- agentzh<br><br>"春儿太猛了！整天写一坨一坨的没用的东西……" -- luoyi

////////////////////////////

作秀中...
最近又写了一篇东西到"<a href="http://ysearchblog.cn/">雅虎搜索日志</a>"，题为"从SearchAll看搜索引擎DNA":<br><br>&nbsp;&nbsp;&nbsp; <a href="http://ysearchblog.cn/2008/01/searchalldna.html">http://ysearchblog.cn/2008/01/searchalldna.html</a><br><br>感谢杏岚的编辑工作 :)<br>
<br>我的下一篇东西可能题为"装在口袋里的网站"；我一直打算介绍一下我们的基于 OpenAPI 的纯客户端应用的开发技术。<br><br>我们的 M，yuting++，已经怪我"染上了作秀不良风气"了，哈哈。我看来是很难改正了，呵呵。tingting 一定要原谅我哦 ;)<br><br>-agentzh


