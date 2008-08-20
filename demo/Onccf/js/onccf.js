var account = 'onccf';
var host = 'http://api.openresty.org';

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

