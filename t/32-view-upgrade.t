# vi:filetype=

#use Smart::Comments '###';

my $ExePath;
BEGIN {
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found.\n";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable.\n";
        return;
    }
};
use Test::Base $skip ? (skip_all => $skip) : ();

plan tests => 3 * blocks();

use OpenResty::RestyScript::ViewUpgrade;
use OpenResty::RestyScript;

run {
    my $block = shift;
    my $name = $block->name;
    my $upgrade = OpenResty::RestyScript::ViewUpgrade->new;
    my $old = $block->old;
    if (!$old) { die "No --- old specified.\n" }
    my $res = $upgrade->parse($old);
    ## $res
    is $res->{newdef}, $block->newdef, "$name - newdef ok";
    my $vars = $res->{vars};
    my $s = '';
    for my $var (@$vars) {
        $s .=  join(' ', @$var) . "\n";
    }
    is $s, $block->params, "$name - params okay";
    my $newview = OpenResty::RestyScript->new('view', $res->{newdef});
    my ($frags, $stats);
    eval {
        ($frags, $stats) = $newview->compile;
    };
    ### $frags
    if ($@) { warn $@ };
    ok($frags && $stats, "$name - Compiled OK");
};

__DATA__

=== TEST 1: hello world
--- old
select * from $foo where $bar | 3> $blah|'hi'
--- newdef
select *
from $foo
where $bar > $blah
--- params
$foo symbol
$bar literal 3
$blah literal hi



=== TEST 2: lhs?
--- old
select * from $foo where $bar> $blah
--- newdef
select *
from $foo
where $bar > $blah
--- params
$foo symbol
$bar symbol
$blah literal



==== TEST 3: FetchResults (carrie)
--- old
select * from yisou_comments_fetch_results($parentid,'',$orderby,$offset,$count,$child_offset,$child_count,$dsc)
--- newdef
select *
from yisou_comments_fetch_results ( $parentid , '' , $orderby , $offset , $count , $child_offset , $child_count , $dsc )
--- params
$parentid literal
$orderby literal
$offset literal
$count literal
$child_offset literal
$child_count literal
$dsc literal



=== TEST 3: UpdateScore (carrie)
--- old
select yisou_comments_update_score($method,$value,$id);
--- newdef
select yisou_comments_update_score ( $method , $value , $id )
--- params
$method literal
$value literal
$id literal



=== TEST 4: CountResults (carrie)
--- old
select count(*) from YisouComments where parentid=0
--- newdef
select count ( * )
from YisouComments
where parentid = 0
--- params



=== TEST 5:  bupt1214bbsFetchTitles
--- old
select * from bupt1214_tree_fetch_title($parentid,'tree',$orderby,$offset,$count,$child_offset,$child_count,$dsc)
--- newdef
select *
from bupt1214_tree_fetch_title ( $parentid , 'tree' , $orderby , $offset , $count , $child_offset , $child_count , $dsc )
--- params
$parentid literal
$orderby literal
$offset literal
$count literal
$child_offset literal
$child_count literal
$dsc literal



=== TEST 6: blog_recentPostTitle
--- old
select title from Post order by $id desc offset $offset limit $limit
--- newdef
select title
from Post
order by $id desc
offset $offset
limit $limit
--- params
$id symbol
$offset literal
$limit literal



=== TEST 7: FetchTitles (carrie)
--- old
select * from yisou_comments_fetch_title($parentid,'tree',$orderby,$offset,$count,$child_offset,$child_count,$dsc)
--- newdef
select *
from yisou_comments_fetch_title ( $parentid , 'tree' , $orderby , $offset , $count , $child_offset , $child_count , $dsc )
--- params
$parentid literal
$orderby literal
$offset literal
$count literal
$child_offset literal
$child_count literal
$dsc literal



=== TEST 8: fetchMsg (carrie)
--- old
select * from MessageBoard where id=$mid
--- newdef
select *
from MessageBoard
where id = $mid
--- params
$mid literal



=== TEST 9: blog_comments (carrie)
--- old
select * from Comments where postid=$postid and status=$cstatus
--- newdef
select *
from Comments
where postid = $postid and status = $cstatus
--- params
$postid literal
$cstatus literal



=== TEST 10: PostsByMonth (agentzh)
--- old
            select id, title, date_part('day', created) as day
            from Post
            where date_part('year', created) = $year and
                date_part('month', created) = $month
            order by created asc
--- newdef
select id , title , date_part ( 'day' , created ) as day
from Post
where date_part ( 'year' , created ) = $year and date_part ( 'month' , created ) = $month
order by created asc
--- params
$year literal
$month literal



=== TEST 11: RecentComments (agentzh)
--- old
            select Comment.id as id, post, sender, title
            from Post, Comment
            where post = Post.id
            order by Comment.id desc
            offset $offset | 0
            limit $limit | 10
--- newdef
select Comment.id as id , post , sender , title
from Post , Comment
where post = Post.id
order by Comment.id desc
offset $offset
limit $limit
--- params
$offset literal 0
$limit literal 10



=== TEST 12: PrevNextPost (agentzh)
--- old
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
--- newdef
( select id , title
from Post
where id < $current
order by id desc
limit 1 ) union ( select id , title
from Post
where id > $current
order by id asc
limit 1 )
--- params
$current literal
$current literal



=== TEST 13: PostCountByMonths (agentzh)
--- old
    select to_char(created, 'YYYY-MM-01') :: date as year_month,
        sum(1) as count
    from Post
    group by year_month
    order by year_month desc
    offset $offset | 0
    limit $limit | 12
--- newdef
select to_char ( created , 'YYYY-MM-01' ) :: date as year_month , sum ( 1 ) as count
from Post
group by year_month
order by year_month desc
offset $offset
limit $limit
--- params
$offset literal 0
$limit literal 12



=== TEST 14: FullPostsByMonth (agentzh)
--- old
    select *
    from Post
    where date_part('year', created) = $year and
        date_part('month', created) = $month
    order by id desc
    limit $count | 40
--- newdef
select *
from Post
where date_part ( 'year' , created ) = $year and date_part ( 'month' , created ) = $month
order by id desc
limit $count
--- params
$year literal
$month literal
$count literal 40




=== TEST 15: PrevNextArchive (agentzh)
--- old
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
--- newdef
( select 'next' as id , date_part ( 'month' , created ) as month , date_part ( 'year' , created ) as year
from Post
where created > $now and ( date_part ( 'month' , created ) <> $month )
order by created asc
limit 1 ) union ( select 'prev' as id , date_part ( 'month' , created ) as month , date_part ( 'year' , created ) as year
from Post
where created < $now and ( date_part ( 'month' , created ) <> $month )
order by created desc
limit 1 )
--- params
$now literal
$month literal
$now literal
$month literal



=== TEST 16: PostFeed (agentzh)
--- old
    select author, title, 'http://blog.agentzh.org/#post-' || id as link,
           content, created as published,
           'http://blog.agentzh.org/#post-' || id || ':comments' as comments
    from Post
    order by created desc
    limit $count | 20
--- newdef
select author , title , 'http://blog.agentzh.org/#post-' || id as link , content , created as published , 'http://blog.agentzh.org/#post-' || id || ':comments' as comments
from Post
order by created desc
limit $count
--- params
$count literal 20

