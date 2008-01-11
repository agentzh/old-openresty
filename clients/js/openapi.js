if (typeof window.OpenAPI == "undefined") {

window.undefined = window.undefined;

var OpenAPI = function (params) {
    if (params == undefined) params = {};
    this.callback = params.callback;
    this.server = params.server;
    this.user = params.user;
    this.password = params.password;
};

OpenAPI.prototype.post = function (content, url, args) {
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

OpenAPI.prototype.put = function (content, url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/put/');
    if (typeof(content) == 'object') {
        content = JSON.stringify(content);
    }
    //alert("type of content: " + typeof(content));
    //alert("content: " + content);
    args.data = content;
    this.get(url, args);
};

OpenAPI.prototype.get = function (url, args) {
    if (!args) args = {};
    if (!this.callback) throw "No callback specified for OpenAPI.";
    if (!this.server) throw "No server specified for OpenAPI.";
    if (!this.user) throw "No user specified for OpenAPI.";
    args.user = this.user;
    args.password = this.password || '';
    if (url.match(/\?/)) throw "URL should not contain '?'.";
    args.rand = Math.random();
    args.user = this.user;
    args.password = this.password;
    args.callback = this.callback;
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

OpenAPI.prototype.del = function (url, args) {
    if (!args) args = {};
    url = url.replace(/^\/=\//, '/=/delete/');
    this.get(url, args);
};

OpenAPI.prototype.purge = function () {
    // document.getElementByClassName('openapiScriptTag').remove();
    var nodes = document.getElementsByTagName('script');
    for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        if (node.className == 'openapiScriptTag') {
            node.removeNode(false);
        }
    }
};

}

