var openapi;
var position;

$(window).ready(init);

function init () {
    //var host = 'http://10.62.136.86';
    var host = 'http://169.254.9.99';
    openapi = new OpenAPI.Client(
        { server: host, callback: 'display', user: 'agentzh.Public' }
    );
    //openapi.formId = 'new_model';
    setInterval(checkAnchor, 300);
    checkAnchor();
    getRecentComments();
    getRecentPosts();
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
    if (typeof res == 'object' && res.success == 0 && res.error) {
        alert("Failed to get the recent comments: " + JSON.stringify(res));
    } else {
        //alert("Get the recent comments: " + JSON.stringify(res));
        var html = Jemplate.process('recent-comments.tt', { comments: res });
        $("#recent-comments").html(html);
    }
}

function renderRecentPosts (res) {
    if (typeof res == 'object' && res.success == 0 && res.error) {
        alert("Failed to get the recent posts: " + JSON.stringify(res));
    } else {
        //alert("Get the recent posts: " + JSON.stringify(res));
        var html = Jemplate.process('recent-posts.tt', { posts: res });
        $("#recent-posts").html(html);
    }
}


function checkAnchor () {
    var hash = location.hash;
    if (position == hash) {
        return;
    }
    position = hash;
    var match = hash.match(/post-(\d+)(:comments|comment-(\d+))?/);
    if (match) {
        var postId = match[1];
        //alert("Post ID: " + postId);
        goToPost(postId);
    } else {
        openapi.callback = renderPostList;
        //openapi.user = 'agentzh.Public';
        openapi.get('/=/model/Post/~/~', {
            count: 5,
            order_by: 'id:desc'
        });
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
        alert("Comment text cannot be empty :)");
        return false;
    }
    //openapi.purge();
    openapi.callback = afterPostComment;
    //openapi.formId = 'comment-form';
    openapi.postByGet(data, '/=/model/Comment/~/~');
    return false;
}

function afterPostComment (res) {
    //alert("HERE!!!");
    if (typeof res == 'object' && res.success == 0 && res.error) {
        alert("Failed to post the comment: " + JSON.stringify(res));
    } else {
        //alert(JSON.stringify(res));
        openapi.callback = renderComments;
        var spans = $(".comment-count");
        var commentCount = parseInt(spans.text());
        var postId = spans.attr('post');
        openapi.get('/=/model/Comment/post/' + postId);
        openapi.callback = function (res) {
            if (typeof res == 'object' && res.success == 0 && res.error) {
                alert(JSON.stringify(res));
            } else {
                spans.text(commentCount + 1);
            }
        };
        openapi.putByGet({ comments: commentCount + 1 }, '/=/model/Post/id/' + postId);
    }
}

function goToPost (id) {
    //alert("Go to Post " + id);
    $(".blog-top").attr('id', 'post-' + id);
    //alert($(".blog-top").attr('id'));
    openapi.callback = renderPost;
    openapi.get('/=/model/Post/id/' + id);
}

function renderPost (posts) {
    //alert(JSON.stringify(post));
    if (typeof posts == 'object' && posts.success == 0 && posts.error) {
        alert("Failed to render post: " + JSON.stringify(posts));
    } else {
        var post = posts[0];
        $("#beta-inner.pkg").html(
            Jemplate.process('post-page.tt', { post: post })
        );
        openapi.callback = function (res) {
            renderPrevNextPost(post.id, res);
        };
        openapi.get('/=/view/PrevNextPost/current/' + post.id);

        openapi.callback = renderComments;
        openapi.get('/=/model/Comment/post/' + post.id);
    }
}

function renderPrevNextPost (currentId, res) {
    if (typeof res == 'object' && res.success == 0 && res.error) {
        alert("Failed to render prev next post navigation: " + JSON.stringify(res));
    } else {
        //alert("Going to render prev next post navigation: " + JSON.stringify(res));
        $(".content-nav").html(
            Jemplate.process('nav.tt', { posts: res, current: currentId })
        );
        location.hash = location.hash;
    }
}

function renderComments (res) {
    //alert("Comments: " + JSON.stringify(res));
    if (typeof data == 'object' && data.success == 0 && data.error) {
        alert("Failed to render post list: " + JSON.stringify(data));
    } else {
        $(".comments-content").html(
            Jemplate.process('comments.tt', { comments: res })
        );
        location.hash = location.hash;
    }
}

function renderPostList (data) {
    if (typeof data == 'object' && data.success == 0 && data.error) {
        alert("Failed to render post list: " + JSON.stringify(data));
    } else {
        //alert(JSON.stringify(data));
        $("#beta-inner.pkg").html(Jemplate.process('post-list.tt', { post_list: data }));
    }
}

