function getModels (opts) {
    setStatus(true, 'getModels');
    if (opts.cache) {
        if (modelList != null) {
            renderModels(modelList);
            return;
        }
    } else {
        modelList = null;
    }
    openresty.callback = renderModels;
    openresty.get('/=/model');
    getModelMenu();
}

function renderModels (res) {
    setStatus(false, 'getModels');
    if (!openresty.isSuccess(res)) {
        error("Failed to get model list: " + res.error);
        return;
    }
    $("#main").html(
        Jemplate.process(
            'model-list.tt',
            { models: res }
        )
    );
}

function getModelMenu () {
    setStatus(true, 'getModelMenu');
    if (modelList != null) {
        return renderModelMenu(modelList);
    }
    openresty.callback = renderModelMenu;
    openresty.get('/=/model');
}

function renderModelMenu (res) {
    setStatus(false, 'getModelMenu');
    if (!openresty.isSuccess(res)) {
        error("Failed to get the model menu: " + res.error);
        return;
    }
    $("#menu").html(
        Jemplate.process(
            'menu.tt',
            { active_item: 'Models', submenu: res }
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

