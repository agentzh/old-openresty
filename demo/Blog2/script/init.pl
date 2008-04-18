#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';
use utf8;
use JSON::XS;
use YAML 'Dump';
use WWW::OpenResty::Simple;
use Date::Manip;
use Getopt::Std;

#$JSON::Syck::ImplicitUnicode = 1;
#$YAML::Syck::ImplicitUnicode = 1;

my %opts;
getopts('u:s:p:h', \%opts);
if ($opts{h}) {
    die "Usage: $0 -u <user> -p <password> -s <openresty_server> [big|small] [<json_file>]\n";
}
my $user = $opts{u} or
    die "No OpenResty account name specified via option -u\n";
my $password = $opts{p} or
    die "No OpenResty account's Admin password specified via option -p\n";
my $server = $opts{s} || 'http://resty.eeeeworks.org';

my $resty = WWW::OpenResty::Simple->new( { server => $server } );
$resty->login($user, $password);
$resty->delete("/=/role/Public/~/~");
$resty->delete("/=/role");
$resty->delete("/=/view");

if ($resty->has_model('Post')) {
    $resty->delete('/=/model/Post');
}

    $resty->post(
        '/=/model/Post',
        {
            description => "Blog post",
            columns => [
                { name => 'title', label => 'Post title' },
                { name => 'content', label => 'Post content' },
                { name => 'author', label => 'Post author' },
                { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Post creation time' },
                { name => 'comments', label => 'Number of comments', type => "integer", default => 0 },
            ],
        }
    );

if ($resty->has_model('Comment')) {
    $resty->delete('/=/model/Comment');
}

    $resty->post(
        '/=/model/Comment',
        {
            description => "Blog comment",
            columns => [
                { name => 'sender', label => 'Comment sender' },
                { name => 'email', label => 'Sender email address' },
                { name => 'url', label => 'Sender homepage URL' },
                { name => 'body', label => 'Comment body' },
                { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Comment creation time' },
                { name => 'post', label => 'target post', type => 'integer' },
            ],
        }
    );

print Dump($resty->get('/=/model')), "\n";
#print Dump($resty->get('/=/model/Post')), "\n";
#print Dump($resty->get('/=/model/Comment')), "\n";
$resty->post(
    '/=/view/PostsByMonth',
    {
        definition => <<'_EOC_',
            select id, title, date_part('day', created) as day
            from Post
            where date_part('year', created) = $year and
                date_part('month', created) = $month
            order by created asc
_EOC_
    }
);

$resty->post(
    '/=/view/RecentComments',
    {
        definition => <<'_EOC_',
            select Comment.id as id, post, sender, title
            from Post, Comment
            where post = Post.id
            order by Comment.id desc
            offset $offset | 0
            limit $limit | 10
_EOC_
    }
);

$resty->post(
    '/=/view/RecentPosts',
    {
        definition => <<'_EOC_',
            select id, title
            from Post
            order by id desc
            offset $offset | 0
            limit $limit | 10
_EOC_
    }
);

$resty->post(
    '/=/view/PrevNextPost',
    {
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
    }
);

$resty->post(
    '/=/view/RowCount',
    {
        definition => <<'_EOC_',
            select count(*)
            from $model
_EOC_
    }
);

$resty->post(
    '/=/view/PostCountByMonths',
    {
        definition => <<'_EOC_',
    select to_char(created, 'YYYY-MM-01') :: date as year_month,
        sum(1) as count
    from Post
    group by year_month
    order by year_month desc
    offset $offset | 0
    limit $limit | 12
_EOC_
    }
);

$resty->post(
    '/=/view/FullPostsByMonth',
    {
        definition => <<'_EOC_',
    select *
    from Post
    where date_part('year', created) = $year and
        date_part('month', created) = $month
    order by id desc
    limit $count | 40
_EOC_
    }
);

$resty->post(
    '/=/view/PrevNextArchive',
    {
        definition => <<'_EOC_',
    (select 'next' as id, date_part('month', created) as month,
        date_part('year', created) as year
     from Post
     where created > $now and (date_part('month', created) <> $month)
     order by created asc
     limit 1
    ) union
    (select 'prev' as id, date_part('month', created) as month,
        date_part('year', created) as year
     from Post
     where created < $now and (date_part('month', created) <> $month)
     order by created desc
     limit 1)
_EOC_
    }
);

$resty->post(
    '/=/role/Public/~/~',
    [
        { method => "GET", url => '/=/model/Post/~/~' },
        { method => "GET", url => '/=/model/Comment/~/~' },

        { method => "GET", url => '/=/view/RecentComments/~/~' },
        { method => "GET", url => '/=/view/RecentPosts/~/~' },
        { method => "GET", url => '/=/view/PrevNextPost/~/~' },
        { method => "GET", url => '/=/view/PostsByMonth/~/~' },
        { method => "GET", url => '/=/view/RowCount/~/~' },
        { method => "GET", url => '/=/view/PostCountByMonths/~/~' },
        { method => "GET", url => '/=/view/FullPostsByMonth/~/~' },
        { method => "GET", url => '/=/view/PrevNextArchive/~/~' },

        { method => "POST", url => '/=/model/Comment/~/~' },
        { method => "PUT", url => '/=/model/Post/id/~' },
    ]
);

$resty->post(
    '/=/role/Poster',
    { description => "Role for comment posters", login => 'captcha' }
);

