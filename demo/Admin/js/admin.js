var itemsPerPage = 10;
var sessionCookie = 'admin_session';
var serverCookie  = 'admin_server';
var userCookie    = 'admin_user';

var openresty = null;

var loadingCount = 0;
var waitMessage = null;
var savedAnchor = null;

$(document).ready(init);

$.fn.postprocess = function (className, options) {
    return this.find("a[@href*='#']").each( function () {
        var href = $(this).attr('href');
        var anchor = href.replace(/^.*?\#/, '');
        //debug("Anchor: " + anchor);
        $(this).click( function () {
            //debug(location.hash);
            location.hash = anchor;
            //alert(location.hash);
            if (savedAnchor == anchor) savedAnchor = null;
            dispatchByAnchor();
        } );
        //debug("about to process editable...");
        setTimeout( function () {
            $(".editable").each( function () {
                var settings = {};
                var data = $(this).attr('resty_value');
                var type = $(this).attr('resty_type');
                //debug(type);
                if ((data && data.length > 128) || /\n.*?\n/.test(data)) {
                    type = 'textarea';
                }
                if (!type) type = 'text';
                if (type == 'textarea') {
                    //debug("found textarea!");
                    settings.width = 600;
                    settings.height = 200;
                }
                settings.data = data;
                settings.type = type;
                plantEditableHook(this, settings);
                $(this).attr('class', 'editable-hooked');
            } );
        }, 0);
    } );
};

function plantEditableHook (node, settings) {
    //debug("start plantEditableHook...");
    $(node).editable( function (value) {
        var path = $(this).attr('resty_path');
        var key = $(this).attr('resty_key');
        var isJSON = $(this).attr('resty_json');
        var data = {};
        if (isJSON) {
            var res = JSON.parse(value);
            if (res == false && typeof res == typeof false && value != false) {
                error("Invalid JSON value: " + value);
                return html2text(value);
            }
            value = res;
        }
        data[key] = value;
        //debug("PUT /=/" + path + " " + JSON.stringify(data));
        setStatus(true, 'editInplace');
        openresty.callback = afterEditInplace;
        openresty.putByGet('/=/' + path, data);
        return '<span class="loading-field"><img src="loading.gif/>&nbsp;Loading...</span>';
    }, {
        type: settings.type || 'text',
        style: "display: inline",
        submit: "Save",
        cancel: "Cancel",
        width: settings.width || 130,
        height: settings.height || 20,
        data: settings.data || '',
        tooltip   : 'Click to edit'
    } );
}

function afterEditInplace (res, revert) {
    setStatus(false, 'editInplace');
    if (!openresty.isSuccess(res)) {
        error("Failed to update the field: " + res.error);
    }
    gotoNextPage();
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

function debug (msg) {
    $("#copyright").append('<p>' + msg + "</p>");
}

function gotoLoginPage () {
    if (savedAnchor)
        location = "login.html#" + savedAnchor;
    else
        location = "login.html";
}

function error (msg) {
    if (/: Login required\.$/.test(msg)) {
        gotoLoginPage();
        return;
    }
    alert(msg);
}

function logout () {
    openresty.callback = function (res) {
        if (!openresty.isSuccess(res)) {
            error("Failed to logout: " + res.error);
        }
    };
    openresty.logout();
    removeCookies();
}

function removeCookies () {
    //alert("Hey!");
    $.cookie(serverCookie, null, { path: '/' });
    $.cookie(sessionCookie, null, { path: '/' });
    $.cookie(userCookie, null, { path: '/' });
}

function init () {
    //alert("HERE!");
    var server  = $.cookie(serverCookie);
    var session = $.cookie(sessionCookie);
    var user    = $.cookie(userCookie);
    //alert("server: " + server);
    //alert("session: " + session);
    if (!server || !session || !user) {
        var anchor = location.hash;
        anchor = anchor.replace(/^\#/, '');
        if (anchor) savedAnchor = anchor;

        gotoLoginPage();
        return;
    }
    var serverHost = server.replace(/^\w+:\/\//, '');
    var userAtHost = user + "@" + serverHost;
    $("#greeting").html("Hello, " + userAtHost + "!" +
            "<br/>If you are not " + user + ", please click " +
            '<a href="login.html" onclick="removeCookies()">' +
            "here" + '</a>.');

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
        { _offset: itemsPerPage * (page - 1), _count: itemsPerPage, _order_by: 'id:desc' }
    );
}

function getPager (name, page, prefix) {
    setStatus(true, 'getPager');
    openresty.callback = function (res) {
        renderPager(res, page, prefix);
    };
    openresty.postByGet(
        '/=/action/RunView/~/~',
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
    // we use the .each hack here to work aound a JS runtime error in IE 6:
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
    openresty.get('/=/role/' + name + '/~/~', { _order_by: 'id:asc' });
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

function deleteModelColumn (model, column, nextPage) {
    if (!confirm("Are you sure to delete column " + column +
                " from model " + model + "?"))
        return;
    setStatus(true, 'deleteModelColumn');
    openresty.callback = function (res) {
        afterDeleteModelColumn(res, model, column, nextPage);
    };
    openresty.del("/=/model/" + model + "/" + column);
}

function afterDeleteModelColumn (res, model, column, nextPage) {
    setStatus(false, 'deleteModelColumn');
    if (!openresty.isSuccess(res)) {
        error("Failed to delete column " + column + " from model " +
                model + ": " + res.error);
        return;
    }
    gotoNextPage(nextPage);
}

function deleteModelRow (model, id, nextPage) {
    if (!confirm("Are you sure to delete row with ID " + id +
                " from model " + model + "?"))
        return;
    setStatus(true, 'deleteModelRow');
    openresty.callback = function (res) {
        afterDeleteModelRow(res, model, id, nextPage);
    };
    // we need a 0 timeout here to workaround an IE bug:
    setTimeout(function () {
        openresty.del("/=/model/" + model + "/id/" + id);
    }, 0);
}

function afterDeleteModelRow (res, model, id, nextPage) {
    setStatus(false, 'deleteModelRow');
    if (!openresty.isSuccess(res)) {
        error("Failed to delete row with ID " + id + " from model " +
                model + ": " + res.error);
        return;
    }
    gotoNextPage(nextPage);
}

function deleteRoleRule (role, id, nextPage) {
    if (!confirm("Are you sure to delete ACL rule with ID " + id +
                " from role " + role + "?"))
        return;
    setStatus(true, 'deleteRoleRule');
    openresty.callback = function (res) {
        afterDeleteRoleRule(res, role, id, nextPage);
    };
    openresty.del("/=/role/" + role + "/id/" + id);
}

function afterDeleteRoleRule (res, role, id, nextPage) {
    setStatus(false, 'deleteRoleRule');
    if (!openresty.isSuccess(res)) {
        error("Failed to delete ACL rule with ID " + id + " from role " +
                role + ": " + res.error);
        return;
    }
    gotoNextPage(nextPage);
}

function gotoNextPage (nextPage) {
    if (!nextPage) nextPage = savedAnchor;
    if (nextPage == savedAnchor) savedAnchor = null;
    location.hash = nextPage;
    dispatchByAnchor();
}

function addNewColumn (model) {
    $("li.add-col").html(
        '<form onsubmit="return false;">' + Jemplate.process('column-inputs.tt') + '<input class="column-create-button" type="submit" value="Create" onclick="createColumn(\'' + model + '\')"></input></form>'
    );
}

function createColumn (model) {
    //alert("Creating column .column-inputsfor model " + model);
    var data;
    try {
        data = getColumnSpec(document);
    } catch (e) {
        error(e);
        return false;
    }
    if (data == null) {
        error("Column spec is empty.");
        return false;
    }
    //alert("Col json: " + JSON.stringify(data));
    setStatus(true, "createColumn");
    openresty.callback = afterCreateColumn;
    openresty.postByGet(
        '/=/model/' + model + "/~",
        data
    );
    return false;
}

function afterCreateColumn (res) {
    setStatus(false, "createColumn");
    if (!openresty.isSuccess(res)) {
        error("Failed to add a new column: " + res.error);
    } else {
        gotoNextPage();
    }
}

function addOneMoreColumn () {
    $("#create-model-columns").append(
        '<tr><td><span class="column-inputs">' + Jemplate.process('column-inputs.tt') + "</span></td></tr>"
    );
}

function createModel () {
    var name = $("#create-model-name").val();
    var desc = $("#create-model-desc").val();
    var cols = [];
    var columns = document.getElementById('create-model-columns');
    if (columns) {
        try {
            $(".column-inputs", columns).each( function () {
                var col = getColumnSpec(this);
                if (col) cols.push(col);
            } );
        } catch (e) {
            error(e);
            return false;
        }
    } else {
        error("columns not found!");
        return false;
    }
    var data = {
        name: name,
        description: desc,
        columns: cols
    };
    //debug("JSON: " + JSON.stringify(data));
    //return;
    setStatus(true, "createModel");
    openresty.callback = afterCreateModel;
    openresty.postByGet(
        '/=/model/~',
        data
    );
    return false;
}

function afterCreateModel (res) {
    setStatus(false, "createModel");
    if (!openresty.isSuccess(res)) {
        error("Failed to create model: " + res.error);
    } else {
        gotoNextPage('models');
    }
}

function getColumnSpec (container) {
    //alert("HERE!");
    var col = {};
    var found = false;
    //debug(div);
    $("input.column-input", container).each( function () {
        var key = $(this).attr('resty_key');
        //debug("Key: " + key);
        var val = $(this).val();
        if (!key) return;
        if (key == 'default' && val) {
            var res = JSON.parse(val);
            if (res == false && typeof res == typeof false && value != false) {
                throw("Invalid JSON for the column's default value: " + val);
            }
            val = res;
        }
        if (val != '') {
            col[key] = val;
            found = true;
        }
    } );
    return found ? col : null;
}

function createView () {
    var name = $("#create-view-name").val();
    var desc = $("#create-view-desc").val();
    var def = $("#create-view-def").val();
    if (!def) {
        error("View definition can't be empty.");
        return false;
    }
    setStatus(true, "createView");
    openresty.callback = afterCreateView;
    openresty.postByGet(
        '/=/view/~',
        { name: name, description: desc, definition: def }
    );
    return false;
}

function afterCreateView (res) {
    setStatus(false, "createView");
    if (!openresty.isSuccess(res)) {
        error("Failed to create view: " + res.error);
    } else {
        gotoNextPage('views');
    }
}

function createFeed () {
    var name = $("#create-feed-name").val();
    var desc = $("#create-feed-desc").val();
    var author = $("#create-feed-author").val();
    var link = $("#create-feed-link").val();
    var logo = $("#create-feed-logo").val();
    var lang = $("#create-feed-lang").val();
    var copyright = $("#create-feed-copyright").val();
    var view = $("#create-feed-view").val();
    var title = $("#create-feed-title").val();
    if (!view) {
        error("The driving view cannot be empty.");
        return false;
    }
    setStatus(true, "createFeed");
    openresty.callback = afterCreateFeed;
    openresty.postByGet(
        '/=/feed/~',
        { name: name,
          description: desc,
          author: author,
          title: title,
          link: link,
          logo: logo,
          language: lang,
          copyright: copyright,
          view: view
        }
    );
    return false;
}

function afterCreateFeed (res) {
    setStatus(false, "createFeed");
    if (!openresty.isSuccess(res)) {
        error("Failed to create feed: " + res.error);
    } else {
        gotoNextPage('feeds');
    }
}

function createRole () {
    var name = $("#create-role-name").val();
    var desc = $("#create-role-desc").val();
    var login_by = $("#create-role-login").val();
    var password = $("#create-role-password").val();
    if (password != null)
        password = hex_md5(password);
    setStatus(true, "createRole");
    openresty.callback = afterCreateRole;
    openresty.postByGet(
        '/=/role/~',
        { name: name, description: desc, login: login_by, password: password }
    );
    return false;
}

function afterCreateRole (res) {
    setStatus(false, "createRole");
    if (!openresty.isSuccess(res)) {
        error("Failed to create role: " + res.error);
    } else {
        gotoNextPage('roles');
    }
}

function createACLRule (role) {
    var method = $("#create-rule-method").val();
    var url = $("#create-rule-url").val();
    setStatus(true, "createACLRule");
    openresty.callback = afterCreateACLRule;
    openresty.postByGet(
        '/=/role/' + role + '/~/~',
        { method: method, url: url }
    );
    return false;
}

function afterCreateACLRule (res) {
    setStatus(false, "createACLRule");
    if (!openresty.isSuccess(res)) {
        error("Failed to create ACL rule: " + res.error);
    } else {
        gotoNextPage();
    }
}

function getModelRowForm (model) {
    setStatus(true, 'getModelRowForm');
    openresty.callback = renderModelRowForm;
    // we need a 0 timeout here to workaround an IE bug:
    setTimeout(function () {
        openresty.get('/=/model/' + model);
    }, 0);
}

function renderModelRowForm (res) {
    setStatus(false, 'getModelRowForm');
    if (openresty.isSuccess(res)) {
        $("#new-row").html(
            Jemplate.process(
                'create-row.tt',
                { model: res }
            )
        );
    } else {
        error("Failed to get model info: " + res.error);
    }
}

function getRowSpec () {
    //alert("HERE!");
    var col = {};
    var found = false;
    //debug(div);
    var container = document.getElementById('create-row-form');
    if (!container) { error("No create row form found"); return }
    $(".row-input", container).each( function () {
        var key = $(this).attr('resty_key');
        //debug("Key: " + key);
        var val = $(this).val();
        //debug("Value: " + val);
        if (!key) return;
        if (val != '') {
            col[key] = val;
            found = true;
        }
    } );
    return found ? col : null;
}

function createModelRow (model) {
    var data = getRowSpec();
    if (!data) {
        error("Cannot create empty row.");
        return false;
    }
    setStatus(true, 'createModelRow');
    openresty.callback = afterCreateModelRow;
    openresty.postByGet(
        '/=/model/' + model + '/~/~',
        data
    );
    return false;
}

function afterCreateModelRow (res) {
    setStatus(false, 'createModelRow');
    if (!openresty.isSuccess(res)) {
        error("Failed to create the row: " + res.error);
    }
    gotoNextPage();
}

function html2text (text) {
    text = text.replace(/&/g, '&amp;');
    text = text.replace(/</g, '&lt;');
    text = text.replace(/>/g, '&gt;');
    text = text.replace(/"/g, '&quot;'); // " end quote for emacs
    return text;
}

