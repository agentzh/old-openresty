if (typeof window.OpenResty == "undefined") {

window.undefined = window.undefined;

var OpenResty = {
    callbackMap: {},
    isDone: {},
    counter: 0
};

OpenResty.Client = function (params) {
    if (params == undefined) params = {};
    this.callback = params.callback;
    var server = params.server;
    if (!/^https?:\/\//.test(server)) {
        server = 'http://' + server;
    }
    this.server = server;
    this.user = params.user;
    //this.password = params.password;
};

OpenResty.Client.prototype.isSuccess = function (res) {
    return !(typeof res == 'object' && res.success == 0 && res.error);
};

OpenResty.Client.prototype.logout = function () {
    this.get('/=/logout');
};

OpenResty.Client.prototype.login = function (user, password) {
    this.user = user;
    var userCallback = this.callback;
    if (typeof userCallback == 'string') {
        userCallback = eval(userCallback);
    }

    var self = this;
    this.callback = function (data) {
        //alert(data.session);
        self.session = data.session;
        userCallback(data);
    };
    if (password == null)
        password = '';
    else
        password = hex_md5(password);
    //this.callback = 'save_session';
    this.get('/=/login/' + user + '/' + password);
};

OpenResty.Client.prototype.postByGet = function (url) {
    var args, content;
    if (arguments.length == 3) {
        args = arguments[1];
        content = arguments[2];
    } else {
        content = arguments[1];
    }
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/post/');
    content = JSON.stringify(content);
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    args._data = content;
    this.get(url, args);
};

OpenResty.Client.prototype.genId = function () {
    return ( Math.random() * 1000000 );
    //return this.counter++;
}

OpenResty.Client.prototype.post = function (url) {
    var args, content;
    if (arguments.length == 3) {
        args = arguments[1];
        content = arguments[2];
    } else {
        content = arguments[1];
    }
    if (!args) args = {};
    //url = url.replace(/^\/=\//, '/=/post/');
    if (url.match(/\?/)) throw "URL should not contain '?'.";
    if (!this.callback) throw "No callback specified for OpenResty.";
    var formId = this.formId;
    if (!formId) throw "No form specified.";

    if (this.session) args._session = this.session;
    if (!this.session && !args._user)
        args._user = this.user;

    args._last_response = this.genId();
    content = JSON.stringify(content);
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    //args.callback = this.callback;
    //args.as_html = 1;

    var arg_list = new Array();
    for (var key in args) {
        arg_list.push(key + "=" + encodeURIComponent(args[key]));
    }
    url += "?" + arg_list.join("&");
    //alert("URL: " + url);
    //alert("Content: " + content);
    //
    //
    var self = this;
    var form = document.getElementById(formId);
    form.method = 'POST';
    var ts = dojo.io.iframe.send({
        form: form,
        url: this.server + url,
        content: { data: content },
        preventCache: true,
        method: "post",
        handleAs: 'html',
        handle: function () {
            //alert("Getting last response!");
            self.get('/=/last/response/' + args._last_response);
        }
    });

    /*
    var form = document.getElementById('new_model');
    form.action = this.server + url;
    form.method = 'POST';
    form.target = 'blah';
    $("input[@name='data']").val(content);
    form.submit();
    */
    //this.get(url, args);
    //
};

OpenResty.Client.prototype.putByGet = function (url) {
    var args, content;
    if (arguments.length == 3) {
        args = arguments[1];
        content = arguments[2];
    } else {
        content = arguments[1];
    }
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/put/');
    content = JSON.stringify(content);
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    args._data = content;
    this.get(url, args);
};

OpenResty.Client.prototype.put = function (url) {
    var args, content;
    if (arguments.length == 3) {
        args = arguments[1];
        content = arguments[2];
    } else {
        content = arguments[1];
    }
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/put/');
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    this.post(url, args, content);
};


OpenResty.Client.prototype.get = function (url, args) {
    if (!args) args = {};
    if (!this.callback) throw "No callback specified for OpenResty.";
    if (!this.server) throw "No server specified for OpenResty.";
    //if (!this.user) throw "No user specified for OpenResty.";

    if (this.session) args._session = this.session;
    if (!this.session && !args._user)
        args._user = this.user;

    //args.password = this.password || '';
    if (url.match(/\?/)) throw "URL should not contain '?'.";
    var reqId = this.genId();
    //args._rand = reqId;

    var onerror = this.onerror;
    if (onerror == null)
        onerror = function () { alert("Failed to do GET " + url) };

    //alert(args._rand);
    //if (!isLogin) args.user = this.user;
    //args.password = this.password;
    var callback = this.callback;
    if (typeof callback == 'string') {
        callback = eval(callback);
    }
    OpenResty.isDone[reqId] = false;
    this.callback = function (res) {
        OpenResty.isDone[reqId] = true;
        OpenResty.callbackMap[reqId] = null;
        callback(res);
    };
    OpenResty.callbackMap[reqId] = this.callback;
    args._callback = "OpenResty.callbackMap[" + reqId + "]";

    var headTag = document.getElementsByTagName('head')[0];

    var scriptTag = document.createElement("script");
    scriptTag.id = "openapiScriptTag" + reqId;
    scriptTag.className = '_openrestyScriptTag';
    var arg_list = new Array();
    for (var key in args) {
        arg_list.push(key + "=" + encodeURIComponent(args[key]));
    }
    scriptTag.src = this.server + url + "?" + arg_list.join("&");
    scriptTag.type = "text/javascript";
    scriptTag.onload = scriptTag.onreadystatechange = function () {
        var done = OpenResty.isDone[reqId];
        if (done) {
            //alert("We're done!");
            setTimeout(function () {
                try {
                    headTag.removeChild(scriptTag);
                } catch (e) {}
            }, 0);
            return;
        }
        if (!this.readyState ||
                this.readyState == "loaded" ||
                this.readyState == "complete") {
            setTimeout(function () {
                if (!OpenResty.isDone[reqId]) {
                    //alert("reqId: " + reqId);
                    onerror();
                    OpenResty.isDone[reqId] = true;
                    setTimeout(function () {
                        try {
                            headTag.removeChild(scriptTag);
                        } catch (e) {}
                    }, 0);
                }
            }, 50);
        }
    };
    headTag.appendChild(scriptTag);
};

OpenResty.Client.prototype.del = function (url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/delete/');
    this.get(url, args);
};

OpenResty.Client.prototype.purge = function () {
    // document.getElementByClassName('openapiScriptTag').remove();
    OpenResty.callbackMap = {};
    OpenResty.isDone = {};
    var nodes = document.getElementsByTagName('script');
    for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        if (node.className == '_openrestyScriptTag') {
            node.parentNode.removeChild(node);
        }
    }
};

}

