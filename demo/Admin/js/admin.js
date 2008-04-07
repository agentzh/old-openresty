var sessionCookie = 'admin_session';
var serverCookie = 'admin_server';

var openresty = null;

var loadingCount = 0;
var waitMessage = null;
var savedAnchor = null;

$(document).ready(init);

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
}


