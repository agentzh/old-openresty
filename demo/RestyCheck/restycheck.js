var openresty = null
var Server = 'ced02.search.cnb.yahoo.com';

$(document).ready(init);

var Links = [
    ['/=/view/t/a/水煮鱼', {c:'北京',user:"lifecai.s",t:50}],
    ['/=/view/Honorlist/limit/500', {user:'qyliu.Public'}],
    ['/=/model/Post/~/~', {offset:0, count: 10, user:'agentzh.Public'}],
    ['/=/view/FetchResults/~/~', {offset:0, user:'people.Public', parentid:0, url:'http://www.yahoo.cn/person/bbs/index.html?id=%E5%88%98%E5%BE%B7%E5%8D%8E', offset:0, count:11, child_offset:0, child_count:5, dsc:'desc', orderby: 'support+deny,id'}]
]

function init () {
    var loc = location.hash;
    loc = loc.replace(/^\#/, '');
    //alert(loc);
    if (loc) {
        server = loc;
    } else {
        server = Server;
    }
    openresty = new OpenResty.Client(
        { server: server }
    );
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
    var account = link[1].user.replace(/\.\w+/, '');
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
    var html = '<tr>';
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
        if (key == 'callback' || key == 'rand') continue;
        if (firstTime) {
            firstTime = false;
        } else {
            url += '&';
        }
        url += key + '=' + params[key];
    }
    return url;
}

