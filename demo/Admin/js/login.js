var sessionCookie = 'admin_session';
var serverCookie = 'admin_server';
var userCookie    = 'admin_user';

var savedAnchor = null;
var openresty = null;

var waitMessage = null;
var loadingCount = 0;

$(document).ready(init);

function init () {
    var anchor = location.hash;
    anchor = anchor.replace(/^\#/, '');
    if (anchor) savedAnchor = anchor;
    //alert("HERE!");
    $("#register-link").click( function () {
        alert('For now, please write to "agentzh" <agentzh@yahoo.cn> to request one :)');
    } );
    $("#login-button").click(login);
    waitMessage = document.getElementById('wait-message');
    if (jQuery.browser.opera)
        $(waitMessage).css('top', '-200px');
    else
        $(waitMessage).hide();
}

function gotoMainPage () {
    if (savedAnchor)
        location = "index.html#" + savedAnchor;
    else
        location = "index.html";
}

function error (msg) {
    alert(msg);
}

function debug (msg) {
    $("#main").append(msg + "<br/>");
}

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

function login () {
    var server = $("#login-server").val();
    var user = $("#login-user").val();
    var password = $("#login-password").val();
    loadingCount = 0;
    if (!server) {
        error("No server specified.");
        return false;
    }
    if (!user) {
        error("No user specified.");
        return false;
    }
    openresty = new OpenResty.Client( { server: server } );

    setStatus(true, 'login');
    openresty.callback = afterLogin;
    openresty.onerror = function () {
        alert("Failed to login.\n  Is your server \"" +
                server + "\" correct?\n");
        setStatus(false, 'login');
    };
    openresty.login(user, password);
    return false;
}

function afterLogin (res) {
    //alert("After login!");
    setStatus(false, 'login');
    if (!openresty.isSuccess(res)) {
        error("Failed to login: " + res.error);
        return;
    }
    $.cookie(sessionCookie, res.session, { path: '/', expires: 2 /* days */ });
    $.cookie(serverCookie, openresty.server, { path: '/', expires: 2 /* days */ });
    $.cookie(userCookie, openresty.user, { path: '/', expires: 2 /* days */ });
    //alert("saved cookie: " + $.cookie(cookieName));
    gotoMainPage();
}

