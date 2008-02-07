if (typeof window.OpenAPI == "undefined") {

window.undefined = window.undefined;

var OpenAPI = {
    callbackMap: {}
};

OpenAPI.Client = function (params) {
    if (params == undefined) params = {};
    this.callback = params.callback;
    this.server = params.server;
    this.user = params.user;
    //this.password = params.password;
};

OpenAPI.Client.prototype.isSuccess = function (res) {
    return (typeof res == 'object' && res.success == 0 && res.error);
};

OpenAPI.Client.prototype.login = function (user, password) {
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
    //this.callback = 'save_session';
    this.get('/=/login/' + user + '/' + password);
};

OpenAPI.Client.prototype.postByGet = function (content, url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/post/');
    if (typeof(content) == 'object') {
        content = JSON.stringify(content);
    }
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    args.data = content;
    this.get(url, args);
};

OpenAPI.Client.prototype.post = function (content, url, args) {
    if (!args) args = {};
    //url = url.replace(/^\/=\//, '/=/post/');
    if (url.match(/\?/)) throw "URL should not contain '?'.";
    if (!this.callback) throw "No callback specified for OpenAPI.";
    var formId = this.formId;
    if (!formId) throw "No form specified.";
    content = JSON.stringify(content);
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    args.rand = Math.random();
    args.session = this.session;
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
    var ts = dojo.io.iframe.send({
        form: document.getElementById(formId),
        url: this.server + url,
        content: { data: content },
        preventCache: true,
        method: "post",
        handleAs: 'html',
        handle: function () {
            //alert("Getting last response!");
            self.get('/=/last/response');
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

OpenAPI.Client.prototype.putByGet = function (content, url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/put/');
    content = JSON.stringify(content);
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    args.data = content;
    this.get(url, args);
};

OpenAPI.Client.prototype.put = function (content, url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/put/');
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    this.post(content, url, args);
};


OpenAPI.Client.prototype.get = function (url, args, isLogin) {
    if (!args) args = {};
    if (!this.callback) throw "No callback specified for OpenAPI.";
    if (!this.server) throw "No server specified for OpenAPI.";
    //if (!this.user) throw "No user specified for OpenAPI.";
    if (!args.user)
        args.user = this.user;
    //args.password = this.password || '';
    if (url.match(/\?/)) throw "URL should not contain '?'.";
    args.rand = Math.round( Math.random() * 100000 );
    args.session = this.session;
    //alert(args.rand);
    //if (!isLogin) args.user = this.user;
    //args.password = this.password;
    if (typeof this.callback == 'string') {
        this.callback = eval(this.callback);
    }
    OpenAPI.callbackMap[args.rand] = this.callback;
    args.callback = "OpenAPI.callbackMap[" + args.rand + "]";
    var scriptTag = document.createElement("script");
    scriptTag.id = "openapiScriptTag" + args.rand;
    scriptTag.className = 'openapiScriptTag';
    var arg_list = new Array();
    for (var key in args) {
        arg_list.push(key + "=" + encodeURIComponent(args[key]));
    }
    scriptTag.src = this.server + url + "?" + arg_list.join("&");
    scriptTag.type = "text/javascript";
    var headTag = document.getElementsByTagName('head')[0];
    headTag.appendChild(scriptTag);
};

OpenAPI.Client.prototype.del = function (url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/delete/');
    this.get(url, args);
};

OpenAPI.Client.prototype.purge = function () {
    // document.getElementByClassName('openapiScriptTag').remove();
    OpenAPI.callbackMap = {};
    var nodes = document.getElementsByTagName('script');
    for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        if (node.className == 'openapiScriptTag') {
            node.parentNode.removeChild(node);
        }
    }
};

}

