var openapi;

$(window).ready(init);

function init () {
    var host = 'http://10.62.136.86';
    openapi = new OpenAPI.Client(
        { server: host, callback: 'display', user: 'agentzh.Public' }
    );
    //openapi.formId = 'new_model';
    openapi.callback = renderPostList;
    //openapi.user = 'agentzh.Public';
    openapi.get('/=/model/Post/~/~', {
        count: 5,
        order_by: 'created:desc'
    });
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
        goToPost(data.post);
    }
}

function goToPost (id) {
    //alert("Go to Post " + id);
    openapi.callback = renderPost;
    openapi.get('/=/model/Post/id/' + id);
}

function renderPost (posts) {
    //alert(JSON.stringify(post));
    if (typeof posts == 'object' && posts.success == 0 && posts.error) {
        alert("Failed to render post: " + JSON.stringify(posts));
    } else {
        $("#beta-inner.pkg").html(Jemplate.process('post-page.tt', { post: posts[0], comments: [] }));
        openapi.callback = renderComments;
        openapi.get('/=/model/Comment/~/~');
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

