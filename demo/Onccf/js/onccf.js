var account = 'onccf';
//var host = 'http://api.openresty.org';
var host = '10.62.136.86';
var loadingCount = 0;
var waitMessage = null;
var timer = null;
var savedAnchor = null;

$.fn.postprocess = function (className, options) {
    return this.find("a[@href^='#']").each( function () {
        var href = $(this).attr('href');
        // We need the following hack because IE expands href to
        // absolute URL:
        var anchor = href.replace(/^.*?\#/, '');
        //debug("Anchor: " + anchor);
        $(this).click( function () {
            //debug(location.hash);
            location.hash = anchor;
            //alert(location.hash);
            if (savedAnchor == anchor) savedAnchor = null;
            dispatchByAnchor();
        } );
    } );
};

$(window).ready(init);

function error (msg) {
    alert(msg);
}

function debug (msg) {
    $("#ft").append(msg + "<br/>");
}

function setStatus (isLoading, category) {
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
    //debug("[" + count + "] setStatus: " + category + ": " + loadingCount + "(" + isLoading + ")");
}

function init () {
    loadingCount = 0;
    var now = new Date();
    if (jQuery.browser.msie)
        waitMessage = document.getElementById('ie-wait-message');
    else
        waitMessage = document.getElementById('wait-message');
    openresty = new OpenResty.Client(
        { server: host, user: account + '.Public' }
    );
    //openresty.formId = 'new_model';
    if (timer) {
        clearInterval(timer);
    }
    dispatchByAnchor();
    timer = setInterval(dispatchByAnchor, 600);
    //debug("before getSidebar...");
    //getSidebar();
    getMenuList();
}

function resetAnchor () {
    var anchor = location.hash;
    location.hash = anchor.replace(/^\#/, '');
}

function dispatchByAnchor () {
    //debug(location.hash);
    var anchor = location.hash;
    anchor = anchor.replace(/^\#/, '');
    if (savedAnchor == anchor)
        return;
    if (anchor == "") {
        anchor = 'menu/home';
        location.hash = 'menu/home';
    }
    savedAnchor = anchor;

    // prevent memory leaks from dynamically created <script> nodes:
    //if (loadingCount <= 0) openresty.purge();
    loadingCount = 0;

    var match = anchor.match(/^menu\/([^/]+)$/);
    if (match) {
        var menu = match[1];
        //alert("Post ID: " + postId);
        getSubmenu(menu);
        getContent(menu);
        return;
    }

    getContent('home');
    //debug("before getPager...");
    //$(".blog-top").attr('id', 'post-list-' + page);
}

function getMenuList () {
    setStatus(true, 'getMenuList');
    openresty.callback = renderMenuList;
    openresty.get('/=/view/MenuList/order_by/id');
}

function renderMenuList (res) {
    setStatus(false, 'getMenuList');
    //alert(JSON.stringify(res));
    if (!openresty.isSuccess(res)) {
        error("Failed to get menu list: " + res.error);
        return;
    }
    $("#mainNav").html(
        Jemplate.process(
            'menu.tt',
            { menu_list: res }
        )
    ).postprocess();
}

function getContent (menu) {
    setStatus(true, 'getContent');
    openresty.callback = renderContent;
    openresty.get('/=/model/Menu/name/' + encodeURIComponent(menu));
}

function renderContent (res) {
    setStatus(false, 'getContent');
    if (!openresty.isSuccess(res)) {
        error("Failed to get content: " + res.error);
        return;
    }
    var menu = res[0];
    $("#page-title").text(menu.label);
    var html = pod2html(menu.content);
    $("#page-content").html( html ).postprocess();
}

function getSubmenu (menu) {
    setStatus(true, 'getSubmenu');
    openresty.callback = function (res) {
        renderSubmenu(res, menu);
    }
    openresty.get('/=/view/SubMenuList/parent/' + encodeURIComponent(menu));
}

function renderSubmenu (res, menu) {
    setStatus(false, 'getSubmenu');
    if (!openresty.isSuccess(res)) {
        error("Failed to get submenu for menu " + menu + ": " + res.error);
        return;
    }
    //alert(JSON.stringify(res));
    //$(".submenu").html('');
    //alert("HERE 1");
    var list = $("#menu-" + menu);
    //list.html('');
    if ( ! list.attr('loaded')) {
        //alert("HERE 2");
        for (var i = 0; i < res.length; i++) {
            var submenu = res[i];
            //alert("submenu: " + foo);
            list.append(
                Jemplate.process(
                    'submenu.tt',
                    { menu: menu, submenu: submenu }
                )
            ).postprocess();
        }
        list.attr('loaded', 1);
        //alert("HERE???");
        //list.show();
        //alert("HERE!!!");
    } else {
        list.toggle();
    }
}

