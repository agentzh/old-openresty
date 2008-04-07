var itemsPerPage = 20;
var sessionCookie = 'admin_session';
var serverCookie = 'admin_server';

var openresty = null;

var loadingCount = 0;
var waitMessage = null;
var savedAnchor = null;

$(document).ready(init);

function debug (msg) {
    $("#footer").append(msg + "<br/>");
}

function error (msg) {
    alert(msg);
}

function removeCookies () {
    //alert("Hey!");
    $.cookie(serverCookie, null, { path: '/' });
    $.cookie(sessionCookie, null, { path: '/' });
}

function init () {
    //alert("HERE!");
    var server = $.cookie(serverCookie);
    var session = $.cookie(sessionCookie);
    //alert("server: " + server);
    //alert("session: " + session);
    if (!server || !session) {
        location = 'login.html';
    }

    waitMessage = document.getElementById('wait-message');

    openresty = new OpenResty.Client({server: server});
    openresty.session = session;

    dispatchByAnchor();
    setInterval(dispatchByAnchor, 600);
    getVersionInfo();
}

function getModelRows (name, page) {
    setStatus(true, 'renderModelRows');
    if (!page) page = 1;
    openresty.callback = function (res) { renderModelRows(res, name, page); };
    openresty.get(
        '/=/model/' + name + '/~/~',
        { offset: itemsPerPage * (page - 1), count: itemsPerPage, order_by: 'id:desc' }
    );
}

function getPager (name, page, prefix) {
    setStatus(true, 'getPager');
    openresty.callback = function (res) {
        renderPager(res, page, prefix);
    };
    openresty.postByGet(
        '/=/action/.Select/lang/minisql',
        "select count(*) as count from " + name
    );
}

function renderPager (res, page, prefix) {
    setStatus(false, 'getPager');
    if (!openresty.isSuccess(res)) {
        error("Failed to get the pager: " + res.error);
        return;
    }
    var pageCount = Math.ceil(parseInt(res[0].count) / itemsPerPage);
    //.processalert(pageCount);
    if (pageCount < 2) return;
    var html = Jemplate.process(
        'pager.tt',
        { page: page, page_count: pageCount, prefix: prefix }
    );
    //alert("HTML: " + html);
    $(".pager").each( function () {
        $(this).html(html);
    } ).postprocess();
}

//////////////////////////////////////////////////////////////////////
// static handlers (others can be found in template/js/handlers.tt)

function renderModelRows (res, model, page) {
    setStatus(false, 'renderModelRows');
    if (!openresty.isSuccess(res)) {
        error("Failed to get model rows: " + res.error);
        return;
    }
    if ($("#menu").find("#model-" + model).length == 0) {
        getModelMenu();
    }
    $("#main").html(
        Jemplate.process(
            'model-rows.tt',
            { model: model, rows: res }
        )
    ).postprocess();
    getPager(model, page, 'modelrows-' + model);
}

function getRoleRules (name) {
    setStatus(true, 'renderRoleRules');
    openresty.callback = function (res) { renderRoleRules(res, name); };
    openresty.get('/=/role/' + name + '/~/~', { order_by: 'id:asc' });
}

function renderRoleRules (res, role) {
    setStatus(false, 'renderRoleRules');
    if (!openresty.isSuccess(res)) {
        error("Failed to get role rows: " + res.error);
        return;
    }
    if ($("#menu").find("#role-" + role).length == 0) {
        getRoleMenu();
    }
    $("#main").html(
        Jemplate.process(
            'role-rules.tt',
            { role: role, rules: res }
        )
    ).postprocess();
}

function getVersionInfo () {
    setStatus(true, 'getVersionInfo');
    openresty.callback = renderVersionInfo;
    openresty.get('/=/version');
}

function renderVersionInfo (res) {
    setStatus(false, 'getVersionInfo');
    if (!openresty.isSuccess(res)) {
        error("Failed to get version info: " + res.error);
        return;
    }
    //res = res.replace(/\. /, '.\n');
    res = res.replace(/&/, '&amp;')
       .replace(/</, '&lt;')
       .replace(/>/, '&gt;')
       .replace(/"/, '&quot;')
       .replace(/\n/, '<br/>')
       .replace(/\(c\)/, '©');
    $("#copyright").html(res);
}

