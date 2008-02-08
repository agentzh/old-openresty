#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';
use Time::HiRes 'sleep';
use utf8;
use JSON::Syck;
use YAML 'Dump';
use lib '/home/agentz/hack/openapi/trunk/lib';
use WWW::OpenAPI::Simple;

my $cmd = shift || 'small';
if ($cmd ne 'small' and $cmd ne 'big') {
    die "Unknown command: $cmd\n";
}

my $openapi = WWW::OpenAPI::Simple->new( { server => 'http://localhost' } );
$openapi->login('agentzh', 4423037);
$openapi->delete("/=/model");
$openapi->delete("/=/role/Public/~/~");
$openapi->delete("/=/view");

$openapi->post({
    description => "Blog post",
    columns => [
        { name => 'title', label => 'Post title' },
        { name => 'content', label => 'Post content' },
        { name => 'author', label => 'Post author' },
        { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Post creation time' },
        { name => 'comments', label => 'Number of comments', default => 0 },
    ],
}, '/=/model/Post');

$openapi->post({
    description => "Blog comment",
    columns => [
        { name => 'sender', label => 'Comment sender' },
        { name => 'email', label => 'Sender email address' },
        { name => 'url', label => 'Sender homepage URL' },
        { name => 'body', label => 'Comment body' },
        { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Comment creation time' },
        { name => 'post', label => 'target post' },
    ],
}, '/=/model/Comment');

print Dump($openapi->get('/=/model')), "\n";
#print Dump($openapi->get('/=/model/Post')), "\n";
#print Dump($openapi->get('/=/model/Comment')), "\n";
$openapi->post({
    definition => <<'_EOC_',
        select id, title, date_part('day', created) as day
        from Post
        where date_part('year', created) = $year and
              date_part('month', created) = $month
        order by created asc
_EOC_
}, '/=/view/PostsByMonth');

$openapi->post({
    definition => <<'_EOC_',
        select Comment.id as id, post, sender, title
        from Post, Comment
        where post = Post.id
        order by Comment.id desc
        offset $offset | 0
        limit $limit | 10
_EOC_
}, '/=/view/RecentComments');

$openapi->post({
    definition => <<'_EOC_',
        select id, title
        from Post
        order by id desc
        offset $offset | 0
        limit $limit | 10
_EOC_
}, '/=/view/RecentPosts');

$openapi->post({
    definition => <<'_EOC_',
        (select id, title
        from Post
        where id < $current
        order by id desc
        limit 1)
      union
        (select id, title
        from Post
        where id > $current
        order by id asc
        limit 1)
_EOC_
}, '/=/view/PrevNextPost');

$openapi->post({
    definition => <<'_EOC_',
        select count(*)
        from $model
_EOC_
}, '/=/view/RowCount');

$openapi->post([
    { method => "GET", url => '/=/model/Post/~/~' },
    { method => "GET", url => '/=/model/Comment/~/~' },

    { method => "GET", url => '/=/view/RecentComments/~/~' },
    { method => "GET", url => '/=/view/RecentPosts/~/~' },
    { method => "GET", url => '/=/view/PrevNextPost/~/~' },
    { method => "GET", url => '/=/view/PostsByMonth/~/~' },
    { method => "GET", url => '/=/view/RowCount/~/~' },

    { method => "POST", url => '/=/model/Comment/~/~' },
    { method => "PUT", url => '/=/model/Post/id/~' },
], '/=/role/Public/~/~');

################################################

if ($cmd eq 'small') {
    my ($title, $created, $buffer);
    while (<DATA>) {
        if (!$title) {
            next if /^\s*$/;
            $title = $_;
            chop $title;
        } elsif (!$created) {
            next if /^\s*$/;
            $created = $_;
            chop $created;
        } elsif (m{^////////+$}) {
            warn $title, "\n";
            $openapi->post({
                author => '章亦春',
                title => $title,
                content => $buffer,
                $created eq 'undef' ? () : (created => $created),
            }, '/=/model/Post/~/~');
            undef $title;
            undef $buffer;
            undef $created;
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

    #print Dump($openapi->get('/=/model/Post/~/~')), "\n";

    for my $i (1..5) {
        warn "Comment $i\n";
        $openapi->post([
            { sender => 'bot', body => qq{This is a comment <b>\t<a href="">&nbsp;</a>\t</b>$i\n} x 20, post => 2 },
        ], '/=/model/Comment/~/~');
        #sleep(0.8);
    }

    $openapi->post([
        { sender => 'laser', body => 'super cool!', url => 'www.pgsqldb.org', post => 4 },
        { sender => 'ting', body => '呵呵。。。', url => 'http://agentzh.org', post => 4 },
        { sender => 'clover', body => "yay!\nso great!", post => 3 },
    ], '/=/model/Comment/~/~');

    $openapi->put({ comments => 2 }, '/=/model/Post/id/4');
    $openapi->put({ comments => 1 }, '/=/model/Post/id/3');
    $openapi->put({ comments => 5 }, '/=/model/Post/id/2');
} else {
    my $infile = 'agentzh-live.json';
    open my $in, $infile or die "Can't open $infile for reading: $!\n";
    my $json = do { local $/; <$in> };
    my $data = JSON::Syck::Load($json);
    for my $entry (@$data) {
        my $title = $entry->{title};
        my $body = $entry->{body};
        my $date = $entry->{date};
        warn $title, "\n";
        $openapi->post({
            author => '章亦春',
            title => $title,
            content => $body,
            $date eq 'undef' ? () : (created => $date),
        }, '/=/model/Post/~/~');
    }
}

__DATA__

SearchAll 0.3.2 发布！
2007-08-09 13:05
经过 Yahoo! China EEEE hacking 小组近一个月的努力， <a href="http://searchall.agentzh.cn/">SearchAll</a>  0.3.2 版终于发布到了  <a href="http://addons.mozilla.org/">AMO 官方网站</a> ： </p><p><a href="https://addons.mozilla.org/zh-TW/firefox/addon/5712">
https://addons.mozilla.org/zh-TW/firefox/addon/5712</a> </p><p>如果您已经安装了 SearchAll 的话，您的 Firefox 在启动时会自动检查更新，并按用户选择进行升级。 </p><p>和上一个 AMO 公开发布版本 0.1.8 相比，SearchAll 积累了许多重大改进。其中的亮点包括： </p><ul><li> <p>增加了对结果页中的链接进行本地测试的功能。SearchAll 现在会自动在``规格化视图''中用可爱的小图标标记出坏链，好链，和慢链。由于使用 Ajax HEAD 请求，所以测试的速度很快。我们 team 的 
<a href="http://blog.jianingy.com/">杨家宁</a> 当初做 <a href="http://www.yisou.com/">"易搜"</a> 的时候就想到实现这样的本地链接测试的功能，但受到 AJAX 跨域请求的限制而未能实现。谢谢杨家宁提的这个 feature! </p></li><li> <p>增加了 <a href="http://agentzh.org/misc/rightclick.swf">

"划搜"功能</a> 。用户可以在任意的网页中选定文本，然后右击，在弹出的快捷菜单中点击"我搜去"（或者SearchAll)，进行搜索。感谢李晓栓的提议！ </p></li><li> <p>增
加了对简体中文(zh-CN)，繁体中文(zh-TW), 法语(fr)，和西班牙语(es-ES) 的国际化支持。如果用户使用的是简体中文版的
Firefox，那么她看到的 SearchAll 界面也将是简体中文版的。其他语言支持依此类推 :) 感谢西班牙的 Gregorio
Villarrubia 的西班牙文翻译。对于非中文用户而言，第一次使用 SearchAll 时默认的三家搜索引擎是 <a href="http://search.yahoo.com/">yahoo.com</a> ,  <a href="http://www.google.com/en">google.com</a> , 和  <a href="http://www.ask.com/">ask.com</a> . 中文用户默认的原三家网站保持不变。
 </p></li><li> <p>为大部分默认列表中的搜索引擎实现了  <a href="http://developer.mozilla.org/en/docs/Creating_OpenSearch_plugins_for_Firefox">OpenSearch 快捷方式</a> ，从而使第一次查询以及切换搜索引擎时的用时减少了至少 50%. 感谢服务于  <a href="http://www.ironport.com/">IronPort 公司

 </a> 的  <a href="http://wanghui.org/">cnhackTNT</a>  的提议！ </p></li><li> <p>修复了多处内存泄漏问题。使用 SearchAll 的时候，Firefox 不会再占用越来越多的内存。界面响应也更迅速。感谢 Mozilla 官方网站的编辑  <a href="http://wiki.mozilla.org/User:Archaeopteryx">Archaeopteryx</a>
   的报告。 </p></li><li> <p>SearchAll 工具条上的搜索框现在支持快捷菜单方式下的"复制"，"剪切"，和"粘贴"操作。感谢尚尔迪的报告和修复。 </p></li><li> <p>添加了下列新的默认搜索引擎： </p><ul><li> <p><a href="http://www.a9.com/">http://www.a9.com</a> </p></li><li> <p><a href="http://www.answers.com/">

   http://www.answers.com</a> </p></li><li> <p><a href="http://search.ebay.com/">http://search.ebay.com</a> </p></li><li> <p><a href="http://www.flickr.com/">http://www.flickr.com</a> </p></li><li> <p><a href="http://www.youtube.com/">
   http://www.youtube.com</a> </p></li></ul> </li></ul> <p>我们仍然在考虑如何在 SearchAll 中展现 Omni Search 的问题。既要保持 SearchAll 在结果展示上的公平公正性，又要表现 Omni Search 丰富的内容，并不是一件容易的事情 ;) 欢迎大家多提宝贵建议 :) </p><p>我最近在看有关  <a href="http://en.wikipedia.org/wiki/Adobe_Flex">

   Adobe Flex</a>  方面的文档，一个基于 Flash 的 SearchAll 似乎更酷一些，因为它将能运行在 IE 和 Opera 这样的浏览器中，而不仅仅是 Firefox. 当然这仅仅是一个很模糊的想法，不知是否可行。有兴趣的朋友可以与我们联系 ;) </p><p>SearchAll 是一个基于 MIT 协议的开源项目。源码仓库位于台湾的  <a href="http://rt.openfoundry.org/">OpenFoundry 服务器
   </a> 上：<a href="http://svn.openfoundry.org/searchall/trunk/">http://svn.openfoundry.org/searchall/trunk/</a>. 如果您乐意参与到项目开发中来，请立即与我们联系；我们很乐意像 Pugs 团队那样递送 Subversion 提交权限。 </p><p>感谢所有一直以来关注和使用 SearchAll 的朋友们；我们一如既往地欢迎各种新功能提议，bug 报告，和评论。
    </p><p>谢谢！ </p><p>章亦春 (agentzh) </p><p>附：根据陈敬亮的报告，来自  <a href="http://www.foxplus.org/">Foxplus</a>  的  <a href="https://addons.mozilla.org/en-US/firefox/addon/5362">Alexa Sparky 扩展</a> 会严重影响 SearchAll tab 的切换速度，因此对于安装了该版本的 Alexa Sparky 扩展的用户，请在使用 SearchAll 的时候暂时禁用 Alexa Sparky.

////////////////////////////

写了一篇东西到"雅虎搜索日志"
2006-12-31 12:27
写了一篇东西到我们 Yahoo 自己的"雅虎搜索日志"网站上：<br><br>&nbsp;&nbsp;&nbsp;&nbsp; <a href="http://ysearchblog.cn/2007/11/searchall.html">http://ysearchblog.cn/2007/11/searchall.html</a><br><br>感谢咱们 content team 的何远银同学提供的初稿。毕竟发起一些东西不是我的长项，而大刀阔斧地修改现成的东西却是，呵呵。
<br><br>另外还必须特别感谢一下我的编辑石杏岚小姐不厌其烦地反复修改这篇东西。在修改过 N 处之后，她终于说自己快崩溃了，呵呵。<br><br>这里顺便 spam 一下，SearchAll 的下一个版本将提供一个全新的视图，Mapping View：<br><br>&nbsp;&nbsp; <a href="http://agentzh.org/misc/mapview.png">http://agentzh.org/misc/mapview.png</a><br><br>欢迎大家试用 Subversion 里的版本：<br><br>&nbsp;&nbsp;&nbsp; <a href="http://svn.openfoundry.org/searchall/trunk/searchall.xpi">
http://svn.openfoundry.org/searchall/trunk/searchall.xpi</a><br><br>Enjoy!<br><br>-agentzh


/////////////////////////////

Yahoo! 4e team 贺岁语录
2008-02-09 02:05
"妈呀，又是测试啊？" -- leiyh<br><br>"话说……你加的功能 work 了！" -- carrie<br><br>"这事咋办呢？让我想想。。。" -- ting<br><br>"每日常坐电脑前，每逢春秋必感冒。锻炼永远计划中，感冒一直在行动。" -- jianingy<br><br>"谁说我不乖的？我很乖的。" -- ywayne
<br><br>"咦？是 exe 的。。。我来 hack 一下。。。" -- shangerdi<br><br>"哈哈！央视8套真好看,讲苍蝇飞行的原理 :D" -- laser<br><br>"锅得刚说了，铛铛铛，铛儿嘀儿嘀个儿铛！" -- arthas<br><br>"yay! it works! :D" -- agentzh<br><br>"春儿太猛了！整天写一坨一坨的没用的东西……" -- luoyi

////////////////////////////

作秀中...
2008-02-01 02:05
最近又写了一篇东西到"<a href="http://ysearchblog.cn/">雅虎搜索日志</a>"，题为"从SearchAll看搜索引擎DNA":<br><br>&nbsp;&nbsp;&nbsp; <a href="http://ysearchblog.cn/2008/01/searchalldna.html">http://ysearchblog.cn/2008/01/searchalldna.html</a><br><br>感谢杏岚的编辑工作 :)<br>
<br>我的下一篇东西可能题为"装在口袋里的网站"；我一直打算介绍一下我们的基于 OpenAPI 的纯客户端应用的开发技术。<br><br>我们的 M，yuting++，已经怪我"染上了作秀不良风气"了，哈哈。我看来是很难改正了，呵呵。tingting 一定要原谅我哦 ;)<br><br>-agentzh

/////////////////////////////

三叶草
undef
昨天在校园里漫步的时候，偶然间发现路旁的绿地上竟满是我最爱的三叶草。圆圆的叶子是那么娇嫩，那么雅致。我仿佛能觉出一缕淡淡的幽香……

////////////////////////////

怎样生活
undef
每天都在奔跑————不好，这不是我想要的生活。<br><br>每天都在学习————不好，这也不是我想要的生活。<br><br>每天都在工作————不好，这还不是我想要的生活。<br><br>我自己究竟想要什么样的生活呢？我不知道。<br><br>嗯，或许是那种比较清闲的生活。繁忙让我厌烦，压力让我不悦。<br><br>让别人拉着我向前奔跑？天哪，那有什么趣味？<br><br>让自己逼着我向前奔跑？嗨，奔跑又是为了什么？<br><br>按照“习俗”追求的许多东西，想来根本没有意义。归根究底，仍是放牛娃的逻辑：<br>学习，成功，娶妻，生子，学习，成功，娶妻，生子……<br><br>无聊之极。<br><br>极少去思考自己的思考。平日里所谓的思考，想来更多的是一种习惯，一种迷惑。<br><br>恶念在心中生起来却浑然不知，甚至乐此不彼。可悲，可叹，可恶！<br><br>终日只知愤世嫉俗，殊不知最俗最坏的竟是自己。<br><br>妍媸自彼，与我何干！<br><br>其实只愿在大部分的时间里，能够真真正正地静下心来，读懂我的灵魂，读懂我的心……<br><br>这个世界是虚幻的，我的心也是虚幻的。无奈。


