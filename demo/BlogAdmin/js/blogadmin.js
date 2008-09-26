var sessionCookie;
var serverCookie;
var userCookie;

var itemsPerPage = 20;
var openresty = null;

var loadingCount = 0;
var waitMessage = null;
var savedAnchor = null;
var savedPost = null;

$(document).ready(init);

$.fn.postprocess = function (className, options) {
    return this.find("a[@href*='#']").each( function () {
        var href = $(this).attr('href');
        var anchor = href.replace(/^.*?\#/, '');
        //debug("Anchor: " + anchor);
        $(this).click( function () {
            //debug(location.hash);
            location.hash = anchor;
            //alert(location.hash);
            if (savedAnchor == anchor) savedAnchor = null;
            dispatchByAnchor();
        } );
        //debug("about to process editable...");
    } );
};

function setStatus (isLoading, category) {
    //debug("set status: " + category + " => " + isLoading);
    if (isLoading) {
        if (++loadingCount == 1) {
            if (jQuery.browser.opera)
                $(waitMessage).css('top', '2px');
            else
                $(waitMessage).show();
        }
    } else {
        loadingCount--;
        if (loadingCount < 0) loadingCount = 0;
        if (loadingCount == 0) {
            // the reason we use this hack is to work around
            // a rendering bug in Win32 build of Opera
            // (at least 9.25 and 9.26)
            if (jQuery.browser.opera)
                $(waitMessage).css('top', '-200px');
            else
                $(waitMessage).hide();

        }
    }
    //count++;
    //debug("[" + count + "] setStatus: " + cat + ": " + loadingCount + "(" + isLoading + ")");
}

function debug (msg) {
    $("#copyright").append('<p>' + msg + "</p>");
}

function gotoLoginPage () {
    if (savedAnchor)
        location = "login.html#" + savedAnchor;
    else
        location = "login.html";
}

function error (msg) {
    if (/: Login required\.$/.test(msg)) {
        gotoLoginPage();
        return;
    }
    alert(msg);
}

function logout () {
    openresty.callback = function (res) {
        if (!openresty.isSuccess(res)) {
            error("Failed to logout: " + res.error);
        }
    };
    openresty.logout();
    removeCookies();
}

function removeCookies () {
    //alert("Hey!");
    $.cookie(serverCookie, null, { path: '/' });
    $.cookie(sessionCookie, null, { path: '/' });
    $.cookie(userCookie, null, { path: '/' });
}

function init () {
    //alert("HERE!");
    var server  = $.cookie(serverCookie);
    var session = $.cookie(sessionCookie);
    var user    = $.cookie(userCookie);
    //alert("server: " + server);
    //alert("session: " + session);
    if (!server || !session || !user) {
        var anchor = location.hash;
        anchor = anchor.replace(/^\#/, '');
        if (anchor) savedAnchor = anchor;

        gotoLoginPage();
        return;
    }
    var serverHost = server.replace(/^\w+:\/\//, '');
    var userAtHost = user + "@" + serverHost;
    $("#greeting").html("Hello, " + userAtHost + "!" +
            "<br/>If you are not " + user + ", please click " +
            '<a href="login.html" onclick="removeCookies()">' +
            "here" + '</a>.');

    waitMessage = document.getElementById('wait-message');

    openresty = new OpenResty.Client({server: server});
    openresty.session = session;

    dispatchByAnchor();
    setInterval(dispatchByAnchor, 600);
    //getVersionInfo();
}

function gotoNextPage (nextPage) {
    if (!nextPage) nextPage = savedAnchor;
    if (nextPage == savedAnchor) savedAnchor = null;
    location.hash = nextPage;
    dispatchByAnchor();
}

function dispatchByAnchor () {
    //debug(location.hash);
    var anchor = location.hash;
    anchor = anchor.replace(/^\#/, '');
    if (savedAnchor == anchor)
        return;
    if (anchor == "") {
        anchor = 'list/1';
        location.hash = anchor;
    }
    savedAnchor = anchor;

    // prevent memory leaks from dynamically created <script> nodes:
    //if (loadingCount <= 0) openresty.purge();
    loadingCount = 0;

    var match = anchor.match(/^edit\/(\d+)$/);
    if (match) {
        var postId = match[1];
        //alert("Post ID: " + postId);
        editPost(postId);
        return;
    }

    match = anchor.match(/^new$/);
    if (match) {
        newPost();
        return;
    }

    match = anchor.match(/^list\/(\d+)$/);
    var page = 1;
    if (match) {
        page = parseInt(match[1]);
        getPostList(page);
        return;
    }
    getPostList(page);

    $(".blog-top").attr('id', 'list/' + page);
}

function editPost (id) {
    setStatus(true, 'editPost');
    //alert("Editing..." + id);
    openresty.callback = renderEditPost;
    openresty.get('/=/model/Post/id/' + id);
}

function renderEditPost (res) {
    setStatus(false, 'editPost');
    if (!openresty.isSuccess(res)) {
        error("Failed to render Edit Post: " + res.error);
        return;
    }
    var post = res[0];
    $("#main").html(
        Jemplate.process('edit.tt',
            { post: post, title: 'Update post' }
        )
    ).postprocess();

    savedPost = post;
    jQuery(".edit-post-input").wymeditor({
       html: post.content
    });
    //setTimeout( function () {
        //savedPost.content = getRTEContent();
        //alert(savedPost.content);
    //}, 0 );
}

function getPostList (page) {
    var offset = itemsPerPage * (page - 1);

    setStatus(true, 'getPostList');
    openresty.callback = function (res) { renderPostList(res, offset) };
    openresty.get('/=/view/RecentPosts/limit/' + itemsPerPage, { offset: offset });
}

function renderPostList (res, offset) {
    setStatus(false, 'getPostList');
    if (!openresty.isSuccess(res)) {
        error("Failed to get post list: " + res.error);
    } else {
        //alert(JSON.stringify(data));
        $("#main").html(
            Jemplate.process('posts.tt', { posts: res, offset: offset, count: itemsPerPage })
        ).postprocess();
    }
    resetAnchor();
}

function updatePost (form, id) {
    //alert(form);
    var title = $("#title-input", form).val();
    //alert("iframes: " + $("iframe", form).length);
    //alert("iframe: " + iframe);
    //alert("iframe doc: " + iframe.contentWindow.document);
    //alert("div in iframe: " + $(".item-body", iframe.contentWindow.document).length);
    var author = $("#author-input", form).val();
    var content;
    var isRTE = ($("#edit-in-rte", form).css('display') == 'none');
    if (isRTE) {
        content = getRTEContent(form);
    } else {
        content = $("#content-input", form).val();
    }
    //alert("content: " + content);
    //return false;
    if (content == null) {
        alert("Failed to get content from RTE");
        return false;
    }
    //alert("content: " + content);
    //return false;
    //alert("title: " + title);
    //alert("author: " + author);
    var data = {};
    var changed = false;
    if (title != savedPost.title) {
        //alert("title changed!");
        changed = true;
        data.title = title;
    }
    if (content != savedPost.content) {
        changed = true;
        //alert("content changed!");
        data.content = content;
    }
    if (author != savedPost.author) {
        changed = true;
        //alert("author changed!");
        data.author = author;
    }
    if (!changed) {
        alert("No modification has been made.");
        return false;
    }
    //alert(JSON.stringify(data));

    setStatus(true, 'updatePost');
    openresty.callback = afterUpdatePost;
    openresty.formId = 'edit-post-form';
    openresty.put('/=/model/Post/id/' + id, data);
    return false;
}

function afterUpdatePost (res) {
    setStatus(false, 'updatePost');
    //alert("Res: " + JSON.stringify(res));
    if (!openresty.isSuccess(res)) {
        error("Failed to update post with id " + id + ": " + res.error);
        return;
    }
    gotoNextPage();
}

function getRTEContent (form) {
    var iframe = $("iframe", form)[0];
    return $("body", iframe.contentWindow.document).html();
}

function editInHTML () {
    var form = document.getElementById('edit-post-form');
    var text = $('#content-input', form)[0];
    //alert($('div.wym_box', form).length);
    $('div.wym_box', form).hide();
    var content = getRTEContent(form);
    $(text).val(content);
    $(text).show();
    $("#edit-in-html", form).hide();
    $("#edit-in-rte", form).show();
}

function editInRTE () {
    var form = document.getElementById('edit-post-form');
    var text = $('#content-input', form)[0];
    $(text).hide();
    var content = $(text).val();

    $('div.wym_box', form).remove();
    jQuery(".edit-post-input").wymeditor({
       html: content
    });
    $("#edit-in-html", form).show();
    $("#edit-in-rte", form).hide();
}

function resetAnchor () {
    var anchor = location.hash;
    location.hash = anchor.replace(/^\#/, '');
}

function deletePost (id, nextPage) {
    if (!confirm("Are you sure to delete post " + id + "?"))
        return;
    setStatus(true, 'deletePost');
    openresty.callback = function (res) {
        afterDeletePost(res, nextPage);
    };
    openresty.del("/=/model/Post/id/" + id);
}

function afterDeletePost (res, id, nextPage) {
    setStatus(false, 'deletePost');
    if (!openresty.isSuccess(res)) {
        error("Failed to delete post with id " + id + ": " + res.error);
        return;
    }
    gotoNextPage(nextPage);
}

function newPost () {
    $("#main").html(
        Jemplate.process('edit.tt',
            { title: 'New post', action: 'createPost', post: { id: 0 }  }
        )
    ).postprocess();

    jQuery(".edit-post-input").wymeditor({
       html: ''
    });

}

function createPost (form) {
    var title = $("#title-input", form).val();
    //alert("iframes: " + $("iframe", form).length);
    //alert("iframe: " + iframe);
    //alert("iframe doc: " + iframe.contentWindow.document);
    //alert("div in iframe: " + $(".item-body", iframe.contentWindow.document).length);
    var author = $("#author-input", form).val();
    var content;
    var isRTE = ($("#edit-in-rte", form).css('display') == 'none');
    if (isRTE) {
        content = getRTEContent(form);
    } else {
        content = $("#content-input", form).val();
    }
    //alert("content: " + content);
    //return false;
    if (content == null) {
        alert("Failed to get content from RTE");
        return false;
    }

    var data = {
        author: author,
        content: content,
        title: title
    };
    setStatus(true, 'newPost');
    openresty.callback = afterNewPost;
    openresty.formId = 'edit-post-form';
    openresty.post('/=/model/Post/~/~', data);
    return false;
}

function afterNewPost (res) {
    setStatus(false, 'newPost');
    if (!openresty.isSuccess(res)) {
        error("Failed to create post: " + res.error);
        return;
    }
    gotoNextPage('list/1');
}

