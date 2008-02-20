var openapi;
var position;
var itemsPerPage = 5;
var loadingCount = 0;

$(window).ready(init);

function error (msg) {
    alert(msg);
}

function setStatus (isLoading) {
    if (isLoading) {
        if (++loadingCount == 1)
            $("#wait-message").show();
    } else {
        if (--loadingCount <= 0)
            $("#wait-message").hide();
    }
}

function init () {
    //var host = 'http://10.62.136.86';
    //var host = 'http://127.0.0.1';
    var host = 'http://ced02.search.cnb.yahoo.com';
    openapi = new OpenAPI.Client(
        { server: host, user: 'agentzh.Public' }
    );
    //openapi.formId = 'new_model';
    setInterval(dispatchByAnchor, 300);
    getSidebar();
}

function dispatchByAnchor () {
    var hash = location.hash;
    //alert(hash);
    hash = hash.replace(/^\#/, '');
    if (position == hash)
        return;
    if (hash == "") {
        hash = 'main';
        location.hash = 'main';
    }
    position = hash;
    loadingCount = 0;

    var match = hash.match(/^post-(\d+)(:comments|comment-(\d+))?/);
    if (match) {
        var postId = match[1];
        //alert("Post ID: " + postId);
        goToPost(postId);
        return;
    }
    match = hash.match(/^(?:post-list|post-list-(\d+))$/);
    var page = 1;
    if (match)
        page = parseInt(match[1]) || 1;

    setStatus(true);
    openapi.callback = renderPostList;
    //openapi.user = 'agentzh.Public';
    openapi.get('/=/model/Post/~/~', {
        count: itemsPerPage,
        order_by: 'id:desc',
        offset: itemsPerPage * (page - 1),
        limit: itemsPerPage
    });
    openapi.callback = function (res) { renderPager(res, page); };
    openapi.get('/=/view/RowCount/model/Post');
    $(".blog-top").attr('id', 'post-list-' + page);
}

function getSidebar () {
    getCalendar();
    getRecentPosts();
    getRecentComments();
}

function getCalendar (year, month) {
    setStatus(true);
    if (year == undefined || month == undefined) {
        var now = new Date();
        year = now.getFullYear();
        month = now.getMonth();
    }
    var date = new Date(year, month, 1);
    var first_day_of_week = date.getDay();
    var end_of_month;
    if (month == 11) {
        end_of_month = 31;
    } else {
        var delta = new Date(year, month + 1, 1) - date;
        end_of_month = Math.round(delta/1000/60/60/24);
    }
    //alert(year);
    //alert(month);
    $(".module-calendar").html(
        Jemplate.process(
            'calendar.tt',
            {
                year: year,
                month: month,
                first_day_of_week: first_day_of_week,
                end_of_month: end_of_month
            }
        )
    );
    openapi.callback = function (res) {
        renderPostsInCalendar(res, year, month);
    };
    openapi.get('/=/view/PostsByMonth/~/~', { year: year, month: month + 1 });
}

function renderPostsInCalendar (res, year, month) {
    setStatus(false);
    if (!openapi.isSuccess(res)) {
        error("Failed to fetch posts for calendar: " +
            res.error);
    } else {
        //alert(res.error);
        var prev_day = 0;
        for (var i = 0; i < res.length; i++) {
            var line = res[i];
            if (prev_day == line.day) continue;
            prev_day = line.day;
            var id = 'day-' + year + '-' + month + '-' + line.day;
            //alert("ID: " + id);
            var cell = $("#" + id);
            if (cell.length == 0) return;
            //alert("cell html: " + cell.html());
            cell.html('<a href="#post-' + line.id + '">' +
                cell.html() + '</a>');
        }
    }
}

function getRecentComments () {
    openapi.callback = renderRecentComments;
    openapi.get('/=/view/RecentComments/limit/6');
}

function getRecentPosts () {
    openapi.callback = renderRecentPosts;
    openapi.get('/=/view/RecentPosts/limit/6');
}

function renderRecentComments (res) {
    if (!openapi.isSuccess(res)) {
        error("Failed to get the recent comments: " + res.error);
    } else {
        //alert("Get the recent comments: " + res.error);
        var html = Jemplate.process('recent-comments.tt', { comments: res });
        $("#recent-comments").html(html);
    }
}

function renderRecentPosts (res) {
    if (!openapi.isSuccess(res)) {
        error("Failed to get the recent posts: " + res.error);
    } else {
        //alert("Get the recent posts: " + res.error);
        var html = Jemplate.process('recent-posts.tt', { posts: res });
        $("#recent-posts").html(html);
    }
}

function postComment (form) {
    var data = {};
    data.sender = $("#comment-author").val();
    data.email = $("#comment-email").val();
    data.url = $("#comment-url").val();
    data.body = $("#comment-text").val();
    data.post = $("#comment-for").val();
    //alert(JSON.stringify(data));
    if (!data.body) {
        error("Comment text cannot be empty :)");
        return false;
    }
    //openapi.purge();
    setStatus(true);
    openapi.callback = afterPostComment;
    openapi.formId = 'comment-form';
    openapi.post(data, '/=/model/Comment/~/~');
    return false;
}

function afterPostComment (res) {
    setStatus(false);
    //alert("HERE!!!");
    if (!openapi.isSuccess(res)) {
        error("Failed to post the comment: " + res.error);
    } else {
        //alert(res.error);
        setStatus(true);
        openapi.callback = renderComments;
        var spans = $(".comment-count");
        var commentCount = parseInt(spans.text());
        var postId = spans.attr('post');
        openapi.get('/=/model/Comment/post/' + postId);
        openapi.callback = function (res) {
            if (!openapi.isSuccess(res)) {
                error("Failed to increment the comment count for post " +
                    postId + ": " + res.error);
            } else {
                spans.text(commentCount + 1);
            }
        };
        openapi.putByGet(
            { comments: commentCount + 1 },
            '/=/model/Post/id/' + postId
        );
    }
}

function goToPost (id) {
    //alert("Go to Post " + id);
    $(".blog-top").attr('id', 'post-' + id);
    //alert($(".blog-top").attr('id'));
    setStatus(true);
    openapi.callback = renderPost;
    openapi.get('/=/model/Post/id/' + id);
}

function renderPost (res) {
    setStatus(false);
    //alert(JSON.stringify(post));
    if (!openapi.isSuccess(res)) {
        error("Failed to render post: " + res.error);
    } else {
        var post = res[0];
        $("#beta-inner.pkg").html(
            Jemplate.process('post-page.tt', { post: post })
        );
        openapi.callback = function (res) {
            renderPrevNextPost(post.id, res);
        };
        openapi.get('/=/view/PrevNextPost/current/' + post.id);

        setStatus(true);
        openapi.callback = renderComments;
        openapi.get('/=/model/Comment/post/' + post.id);
        $("#beta-pager.pkg").html('');
    }
}

function renderPrevNextPost (currentId, res) {
    if (!openapi.isSuccess(res)) {
        error("Failed to render prev next post navigation: " +
            res.error);
    } else {
        //alert("Going to render prev next post navigation: " + res.error);
        $(".content-nav").html(
            Jemplate.process('nav.tt', { posts: res, current: currentId })
        );
        location.hash = location.hash;
    }
}

function renderComments (res) {
    setStatus(false);
    //alert("Comments: " + res.error);
    if (!openapi.isSuccess(res)) {
        error("Failed to render post list: " + res.error);
    } else {
        $(".comments-content").html(
            Jemplate.process('comments.tt', { comments: res })
        );
        location.hash = location.hash;
    }
}

function renderPostList (res) {
    setStatus(false);
    if (!openapi.isSuccess(res)) {
        error("Failed to render post list: " + res.error);
    } else {
        //alert(JSON.stringify(data));
        $("#beta-inner.pkg").html(
            Jemplate.process('post-list.tt', { post_list: res })
        );
    }
    location.hash = location.hash;
}

function renderPager (res, page) {
    if (!openapi.isSuccess(res)) {
        error("Failed to render pager: " + res.error);
    } else {
        var pageCount = Math.ceil(parseInt(res[0].count) / itemsPerPage);
        if (pageCount < 2) return;
        $("#beta-pager.pkg").html(
            Jemplate.process(
                'pager.tt',
                { page: page, page_count: pageCount, title: 'Pages' }
            )
        );
        location.hash = location.hash;
    }
}

