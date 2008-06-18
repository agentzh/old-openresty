if (typeof window.OpenResty == "undefined") {

window.undefined = window.undefined;

var OpenResty = {
    callbackMap: {}
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
    args.data = content;
    this.get(url, args);
};

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

    if (this.session) args.session = this.session;
    if (!this.session && !args.user)
        args.user = this.user;

    args.last_response = Math.round( Math.random() * 1000000 );
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
            self.get('/=/last/response/' + args.last_response);
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
    args.data = content;
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
    this.post(content, url, args);
};


OpenResty.Client.prototype.get = function (url, args) {
    if (!args) args = {};
    if (!this.callback) throw "No callback specified for OpenResty.";
    if (!this.server) throw "No server specified for OpenResty.";
    //if (!this.user) throw "No user specified for OpenResty.";

    if (this.session) args.session = this.session;
    if (!this.session && !args.user)
        args.user = this.user;

    //args.password = this.password || '';
    if (url.match(/\?/)) throw "URL should not contain '?'.";
    args.rand = Math.round( Math.random() * 100000 );
    //alert(args.rand);
    //if (!isLogin) args.user = this.user;
    //args.password = this.password;
    if (typeof this.callback == 'string') {
        this.callback = eval(this.callback);
    }
    OpenResty.callbackMap[args.rand] = this.callback;
    args.callback = "OpenResty.callbackMap[" + args.rand + "]";
    var scriptTag = document.createElement("script");
    scriptTag.id = "openapiScriptTag" + args.rand;
    scriptTag.className = '_openrestyScriptTag';
    var arg_list = new Array();
    for (var key in args) {
        arg_list.push(key + "=" + encodeURIComponent(args[key]));
    }
    scriptTag.src = this.server + url + "?" + arg_list.join("&");
    scriptTag.type = "text/javascript";
    var headTag = document.getElementsByTagName('head')[0];
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
    var nodes = document.getElementsByTagName('script');
    for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        if (node.className == '_openrestyScriptTag') {
            node.parentNode.removeChild(node);
        }
    }
};

}

