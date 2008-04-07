var sessionCookie = 'admin_session';
var serverCookie = 'admin_server';
var openresty = null;

$(document).ready(init);

function init () {
    //alert("HERE!");
    $("#register-link").click( function () {
        alert('For now, please write to "agentzh" <agentzh@yahoo.cn> to request one :)');
    } );
    $("#login-button").click(login);
}

function error (msg) {
    alert(msg);
}

function debug (msg) {
    $("#main").append(msg + "<br/>");
}


function login () {
    var server = $("#login-server").val();
    var user = $("#login-user").val();
    var password = $("#login-password").val();
    if (!server) {
        error("No server specified.");
        return false;
    }
    if (!user) {
        error("No user specified.");
        return false;
    }
    openresty = new OpenResty.Client( { server: server } );
    openresty.callback = afterLogin;
    openresty.login(user, password);
    return false;
}

function afterLogin (res) {
    //alert("After login!");
    if (!openresty.isSuccess(res)) {
        error("Failed to login: " + res.error);
        return;
    }
    $.cookie(sessionCookie, res.session, { path: '/', expires: 2 /* days */ });
    $.cookie(serverCookie, openresty.server, { path: '/', expires: 2 /* days */ });
    //alert("saved cookie: " + $.cookie(cookieName));
    location = 'index.html';
}

