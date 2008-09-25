var openresty = null
var Server = 'api.openresty.org';
var savedAnchor = null;
var timer = null;

$(document).ready(init);

var Links = [
    ['/=/view/t/a/水煮鱼', {c:'北京',_user:"lifecai.s",t:50}],
    ['/=/view/Honorlist/limit/500', {_user:'qyliu.Public'}],
    ['/=/model/Post/~/~', {_offset:0, _count: 10, _user:'agentzh.Public'}],
    ['/=/view/FetchTitles/~/~', {container:'review', parentid:0, offset:0, count:11, child_offset:0, child_count:5, dsc:'desc', orderby:'updated', _user: 'carrie.Public'}],
    ['/=/view/FetchResults/~/~', {offset:0, _user:'people.Public', parentid:0, url:'http://www.yahoo.cn/person/bbs/index.html?id=%E5%88%98%E5%BE%B7%E5%8D%8E', offset:0, count:11, child_offset:0, child_count:5, dsc:'desc', orderby: 'support+deny,id'}],
    ['/=/view/ipbase/~/~', {q:'124.1.34.1', _user:'ipbase.Public'}],
    ['/=/view/getquery/spell/yao', { _user: 'yquestion.Public' }]
]

function init () {
    if (timer) {
        clearInterval(timer);
    }
    dispatchByAnchor();
    timer = setInterval(dispatchByAnchor, 600);
}

function dispatchByAnchor () {
    var anchor = location.hash;
    anchor = anchor.replace(/^\#/, '');
    if (savedAnchor == anchor)
        return;
    if (anchor == "") {
        anchor = 'posts/1';
        location.hash = 'posts/1';
    }
    savedAnchor = anchor;

    if (anchor) {
        server = anchor;
    } else {
        server = Server;
    }
    openresty = new OpenResty.Client(
        { server: server }
    );
    $("tr.result").remove();
    for (var i = 0; i < Links.length; i++) {
        //alert("i = " + i);
        var link = Links[i];
        genCallback(link);
        //for (var j = 0; j < 3; j++) {
        openresty.get(link[0], link[1]);
        //}
    }
}

function now () {
    return (new Date()).getTime();
}

function genCallback (link) {
    var beginTime = now();

    openresty.callback = function (res) {
        var elapsed = now() - beginTime;
        renderRes([link[0], link[1]], elapsed, res);
    };
}

function renderRes (link, elapsed, res) {
    //alert("HERE!");
    var row;
    var account = link[1]._user.replace(/\.\w+/, '');
    if (!openresty.isSuccess(res)) {
        //alert("Failed!");
        row = [
            '<span class="error">Fail</span>',
            elapsed.toString() + " ms",
            'Hash',
            res.error,
            account,
            toURL(link)
        ];
    } else {
        //alert("Success!");
        var type;
        if (typeof res == 'object') {
            if (res instanceof Array) {
                type = 'Array';
            } else {
                type = 'object';
            }
        } else {
            type = typeof res;
        }

        row = [
            '<span class="success">Success</span>',
            elapsed.toString() + " ms",
            type,
            res.length,
            account,
            toURL(link)
        ];
    }
    var html = genRowHtml(row);
    //alert(html);
    //alert($('#res>tbody').html());
    $("#res>tbody").append(html);
}

function genRowHtml (row) {
    var html = '<tr class="result">';
    for (var i = 0; i < row.length; i++) {
        html += '<td>' + row[i] + '</td>';
    }
    html += '</tr>\n';
    return html;
}

function toURL (link) {
    var url = 'http://' + server + link[0] + '?';
    var firstTime = true;
    var params = link[1];
    for (var key in params) {
        if (key == 'callback' || key == '_rand') continue;
        if (firstTime) {
            firstTime = false;
        } else {
            url += '&';
        }
        url += key + '=' + params[key];
    }
    return url;
}

