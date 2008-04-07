var sessionCookie = 'admin_session';
var serverCookie = 'admin_server';

var openresty = null;

var loadingCount = 0;
var waitMessage = null;
var savedAnchor = null;

var modelList = null;
var viewList = null;

$(document).ready(init);

function error (msg) {
    alert(msg);
}

function removeCookies () {
    //alert("Hey!");
    $.cookie(serverCookie, null, { path: '/' });
    $.cookie(sessionCookie, null, { path: '/' });
    location = 'login.html';
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
    $("#logout-link").click(removeCookies);

    waitMessage = document.getElementById('wait-message');

    openresty = new OpenResty.Client({server: server});
    openresty.session = session;

    dispatchByAnchor();
    setInterval(dispatchByAnchor, 600);
}

function dispatchByAnchor () {
    var anchor = location.hash;
    anchor = anchor.replace(/^\#/, '');
    if (savedAnchor == anchor)
        return;
    if (anchor == "") {
        anchor = 'models';
        location.hash = 'models';
    }
    savedAnchor = anchor;

    // prevent memory leaks from dynamically created <script> nodes:
    if (loadingCount <= 0) openresty.purge();
    loadingCount = 0;

    if (anchor == 'models') {
        getModels( { cache: false } );
        return;
    }
    if (anchor == 'views') {
        getViews( { cache: false } );
        return;
    }
    if (anchor == 'roles') {
        getRoles( { cache: false } );
        return;
    }

    alert("Not implemented :(");
}

