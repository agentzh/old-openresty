var itemsPerPage = 20;
var sessionCookie = 'admin_session';
var serverCookie  = 'admin_server';
var userCookie    = 'admin_user';
var cachedModelCount = {};

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
            $(".location-anchor")[0].id = anchor;
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
                if ((data && data.length > 30) || /\n/.test(data)) {
                    type = 'textarea';
                }
                if (!type) type = 'text';
                if (type == 'textarea') {
                    //debug("found textarea!");
                    settings.width = 600;
                    settings.height = 200;
                } else {
                    settings.width = data ? (data.length + 5 + 'em') : '5em';
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
        openresty.formId = 'dummy-form';
        openresty.put('/=/' + path, data);
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

function getModelRows (name, page, pat) {
    setStatus(true, 'renderModelRows');
    if (!page) page = 1;
    openresty.callback = function (res) { renderModelRows(res, name, page, pat); };
    if (/\%[A-Za-z0-9]{2}/.test(pat)) {
        pat = decodeURIComponent(pat);
    }
    openresty.get(
        '/=/model/' + name + '/~/' + pat,
        { _offset: itemsPerPage * (page - 1), _count: itemsPerPage, _order_by: 'id:desc', _op: 'contains' }
    );
}

function getPager (name, page, prefix, suffix) {
    setStatus(true, 'getPager');
    var count = cachedModelCount[name];
    if (count == null) {
        openresty.callback = function (res) {
            renderPager(res, page, prefix, suffix, name);
        };
        openresty.postByGet(
            '/=/action/RunView/~/~',
            "select count(*) as count from " + name
        );
    } else {
        //alert("Hit cache count: " + count);
        renderPager([{count: count}], page, prefix, suffix, name);
    }
}

function renderPager (res, page, prefix, suffix, model) {
    //alert("Render pager: " + JSON.stringify(res));
    setStatus(false, 'getPager');
    if (!openresty.isSuccess(res)) {
        error("Failed to get the pager: " + res.error);
        return;
    }
    var count = res[0].count;
    cachedModelCount[model] = count;
    $(".total-rows").html('For total <b>' + res[0].count + '</b> rows.');
    var pageCount = Math.ceil(parseInt(count) / itemsPerPage);
    //.processalert(pageCount);
    if (pageCount < 2) return;
    var html = Jemplate.process(
        'pager.tt',
        { page: page, page_count: pageCount, prefix: prefix, suffix: suffix }
    );
    //alert("HTML: " + html);
    // we use the .each hack here to work aound a JS runtime error in IE 6:
    $(".pager").each( function () {
        $(this).html(html);
    } ).postprocess();
}

//////////////////////////////////////////////////////////////////////
// static handlers (others can be found in template/js/handlers.tt)

function renderModelRows (res, model, page, pat) {
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
            { model: model, rows: res, pat: pat }
        )
    ).postprocess();
    getPager(model, page, 'modelrows/' + model + '/', '/' + pat);
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
    openresty.get('/=/version/verbose');
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
       .replace(/\n.*/, '')
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
    delete cachedModelCount[model];
    openresty.del("/=/model/" + model + "/id/" + id);
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

function searchRows () {
    var pat = $("#search-box-input").val();
    if (!pat) pat = '~';
    var anchor = savedAnchor;
    var matches = anchor.match(/^modelrows\/(\w+)\/\d+\/(.*)$/);
    if (matches) {
        var model = matches[1];
        anchor = 'modelrows/' + model + '/1/' + pat;
    } else {
        matches = anchor.match(/^modelrows\/\w+\/\d+$/);
        if (matches)
            anchor += '/' + pat;
        else
            return;
    }
    gotoNextPage(anchor);
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
    setTimeout( function () {
        //alert($('.column-input-name:last').length);
        $('.column-input-name:last')[0].focus();
        //$('column-input :last')[0].focus();
    }, 0 );
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

/* in create model */
function addOneMoreColumn () {
    //debug("HERE!");
    $("#create-model-columns").append(
        '<table><tr><td><span class="column-inputs">' + Jemplate.process('column-inputs.tt') + "</span></td></tr></table>"
    );
    //alert("HERE!");
        //alert("HERE!");
    setTimeout( function () {
        //alert($('.column-input-name:last').length);
        $('.column-input-name:last')[0].focus();
        //$('column-input :last')[0].focus();
    }, 0 );
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
    var prohibiting = $("#create-rule-prohibiting").val();
    setStatus(true, "createACLRule");
    var data = { method: method, url: url };
    if (prohibiting == "true")
        data.prohibiting = true;
    openresty.callback = afterCreateACLRule;
    openresty.postByGet('/=/role/' + role + '/~/~', data);
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

function deleteAllModelRows (model) {
    //alert("No implemented yet!");
    if (confirm("Are you sure to remove all the rows in model \""
                + model + "\"?")) {
        openresty.callback = afterDeleteAllModelRows;
        delete cachedModelCount[model];
        openresty.del("/=/model/" + model + "/~/~");
    }
}

function afterDeleteAllModelRows (res) {
    alert(JSON.stringify(res));
    gotoNextPage();
}

function getModelBulkRowForm (model) {
    $("#new-row").html(
        Jemplate.process(
            'create-bulk-row.tt',
            { model: model }
        )
    );
}

function createModelBulkRow (model) {
    var data = $("form#create-row-bulk-form>textarea").val();
    //alert(data);
    if (!data) { alert("No lines found!"); return; }
    var lines = data.split(/\n/);
    var resLines = [];
    for (var i = 0; i < lines.length; i++) {
        value = lines[i];
        if (/^\s*$/.test(value)) continue;
        var res = JSON.parse(value);
        if (res == false && typeof res == typeof false && value != false) {
            error("Invalid JSON value for line " + (i+1) + ": " + value);
            return false;
        }
        resLines.push(value);
    }
    var json = "[" + resLines.join(",") + "]";
    //alert(json);
    setStatus(true, 'createModelBulkRow');
    delete cachedModelCount[model];
    openresty.formId = 'dummy-form';
    openresty.callback = afterCreateModelBulkRow;
    openresty.post("/=/model/" + model + "/~/~", JSON.parse(json));
    //alert("HERE! ;)");
    return false;
}

function afterCreateModelBulkRow (res) {
    //alert("HERE!");
    setStatus(false, 'createModelBulkRow');
    if (openresty.isSuccess(res)) {
        $("form#create-row-bulk-form>textarea").val('');
        gotoNextPage();
    } else {
        alert("Failed to import: " + res.error);
    }
    //$("#import-results").html(JSON.stringify(res));
    //alert(JSON.stringify(res));
}

function getModelRowForm (model) {
    setStatus(true, 'getModelRowForm');
    openresty.callback = renderModelRowForm;
    openresty.get('/=/model/' + model);
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
    delete cachedModelCount[model];
    openresty.callback = afterCreateModelRow;
    openresty.formId = 'dummy-form';
    openresty.post(
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

function addOneMoreParam () {
    //debug("HERE!");
    $("#create-action-params").append(
        '<table><tr><td><span class="param-inputs">' + Jemplate.process('param-inputs.tt') + "</span></td></tr></table>"
    );
    //alert("HERE!");
        //alert("HERE!");
    setTimeout( function () {
        //alert($('.column-input-name:last').length);
        $('.param-input-name:last')[0].focus();
        //$('column-input :last')[0].focus();
    }, 0 );
}

function createAction () {
    var name = $("#create-action-name").val();
    var desc = $("#create-action-desc").val();
    var def = $("#create-action-def").val();
    var params = [];
    var parameters = document.getElementById('create-action-params');
    if (parameters) {
        try {
            $(".param-inputs", parameters).each( function () {
                var param = getParamSpec(this);
                if (param) params.push(param);
            } );
        } catch (e) {
            error(e);
            return false;
        }
    } else {
        error("parameters not found!");
        return false;
    }
    var data = {
        name: name,
        description: desc,
        parameters: params,
        definition: def
    };
    //debug("JSON: " + JSON.stringify(data));
    //return;
    setStatus(true, "createAction");
    openresty.callback = afterCreateAction;
    openresty.postByGet(
        '/=/action/~',
        data
    );
    return false;
}

function afterCreateAction (res) {
    setStatus(false, "createAction");
    if (!openresty.isSuccess(res)) {
        error("Failed to create action: " + res.error);
    } else {
        gotoNextPage('actions');
    }
}

function getParamSpec (container) {
    //alert("HERE!");
    var col = {};
    var found = false;
    //debug(div);
    $("input.param-input", container).each( function () {
        var key = $(this).attr('resty_key');
        //debug("Key: " + key);
        if (!key) return;
        var val = $(this).val();
        if (val != '') {
            col[key] = val;
            found = true;
        }
    } );
    return found ? col : null;
}

function deleteActionParam (action, param, nextPage) {
    if (!confirm("Are you sure to delete parameter " + param +
                " from action " + action + "?"))
        return;
    setStatus(true, 'deleteActionParam');
    openresty.callback = function (res) {
        afterDeleteActionParam(res, action, param, nextPage);
    };
    openresty.del("/=/action/" + action + "/" + param);
}

function afterDeleteActionParam (res, action, param, nextPage) {
    setStatus(false, 'deleteActionParam');
    if (!openresty.isSuccess(res)) {
        error("Failed to delete parameter " + param + " from action " +
                action + ": " + res.error);
        return;
    }
    gotoNextPage(nextPage);
}

function addNewParam (action) {
    $("li.add-param").html(
        '<form onsubmit="return false;">' + Jemplate.process('param-inputs.tt') + '<input class="param-create-button" type="submit" value="Create" onclick="createParam(\'' + action + '\')"></input></form>'
    );
    setTimeout( function () {
        //alert($('.column-input-name:last').length);
        $('.param-input-name:last')[0].focus();
        //$('column-input :last')[0].focus();
    }, 0 );
}

function createParam (action) {
    //alert("Creating column .column-inputsfor model " + model);
    var data;
    try {
        data = getParamSpec(document);
    } catch (e) {
        error(e);
        return false;
    }
    if (data == null) {
        error("Parameter spec is empty.");
        return false;
    }
    //alert("Col json: " + JSON.stringify(data));
    setStatus(true, "createParam");
    openresty.callback = afterCreateParam;
    openresty.postByGet(
        '/=/action/' + action + "/~",
        data
    );
    return false;
}

function afterCreateParam (res) {
    setStatus(false, "createParam");
    if (!openresty.isSuccess(res)) {
        error("Failed to add a new parameter: " + res.error);
    } else {
        gotoNextPage();
    }
}

