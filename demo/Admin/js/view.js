function getViews (opts) {
    setStatus(true, 'getViews');
    if (opts.cache) {
        if (viewList != null) {
            renderViews(viewList);
            return;
        }
    } else {
        viewList = null;
    }
    openresty.callback = renderViews;
    openresty.get('/=/view');
    getViewMenu();
}

function renderViews (res) {
    setStatus(false, 'getViews');
    if (!openresty.isSuccess(res)) {
        error("Failed to get view list: " + res.error);
        return;
    }
    $("#main").html(
        Jemplate.process(
            'object-list.tt',
            { objects: res }
        )
    );
}

function getViewMenu () {
    setStatus(true, 'getViewMenu');
    if (viewList != null) {
        return renderViewMenu(viewList);
    }
    openresty.callback = renderViewMenu;
    openresty.get('/=/view');
}

function renderViewMenu (res) {
    setStatus(false, 'getViewMenu');
    if (!openresty.isSuccess(res)) {
        error("Failed to get the view menu: " + res.error);
        return;
    }
    $("#menu").html(
        Jemplate.process(
            'menu.tt',
            { active_item: 'Views', submenu: res }
        )
    );
}

$.fn.postprocess = function (className, options) {
    return this.find("a[@href^='#']").each( function () {
        var anchor = $(this).attr('href').replace(/^\#/, '');
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

