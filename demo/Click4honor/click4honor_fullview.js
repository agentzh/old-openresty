//var restyhost = 'http://api.openresty.org';
var restyhost = 'http://localhost';
var account = 'qyliu';

var openresty;
var districts = [
'安徽',
'澳门',
'北京',
'重庆',
'福建',
'甘肃',
'广东',
'广西',
'贵州',
'海南',
'河北',
'河南',
'黑龙江',
'湖北',
'湖南',
'吉林',
'江苏',
'江西',
'辽宁',
'内蒙古',
'宁夏',
'青海',
'山东',
'山西',
'陕西',
'上海',
'深圳',
'四川',
'台湾',
'天津',
'西藏',
'香港',
'新疆',
'云南',
'浙江',
];
var itemsPerPage = 5;
var captchaID;

$(window).ready(init);

function err (msg) { alert(msg) }

function error (msg, id) {
    if (!id) id = "errmsg";
    var errdiv = document.getElementById(id);
    if (errdiv) {
        errdiv.style.display = "block";
        errdiv.innerHTML = msg;
    } else {
        alert(msg);
    }
}

function errorclear(id) {
    if (!id) id = "errmsg";
    var errdiv = document.getElementById(id);
    if (errdiv) {
        errdiv.style.display = "none";
        errdiv.innerHTML = "";
    } else {
    }
}

function clearscore() {
    document.getElementById("cccc").innerHTML = "0";
}

function init () {
    openresty = new OpenResty.Client(
        { server: restyhost, callback: '', user: account + '.Public' }
    );
    listDistricts();
    getHonorlist();
}

function refreshCaptcha(res) {
    if(res && res.success != 0) { //submit successfully
        clearscore();
        document.getElementById("csubmit").style.display = "none";
        errorclear("errmsg2");
        return;
    }
    if(res && res.success == 0){
        //alert("Error: Wrong Captcha Input: " + JSON.stringify(res));
        //console.log(res.error);
        error("验证码输入错误", "errmsg2");
    }
    openresty.callback = renderCaptcha;
    openresty.get('/=/captcha/id');
}

function renderCaptcha(res) {
    if (!openresty.isSuccess(res)) {
        error("Failed to get captcha id: " + JSON.stringify(res));
    }
    else {
        //alert("Get the captch id: " + JSON.stringify(res));
        captchaID = res;
        var img = document.getElementById("captchaImg");
        img.src = restyhost + "/=/captcha/id/" + captchaID + "?lang=en";
        //error(captchaID);
    }

}

function listDistricts() {
        var tpl = {
            "self": "<select id=wwww>{$}</select>",
            "self[*]": function(x) {
                //return "<option value=" + escape(x) + ">" + x + "</option>";
                return "<option value=" + escape(x).replace(/%/g, '_') + ">" + x + "</option>";
            }
        };
        document.getElementById("wwwwspan").innerHTML = jsonT(districts, tpl);
}

function getHonorlist() {
    openresty.callback = renderHonorlist;
    openresty.get('/=/view/Honorlist/limit/500'); //top 500
}

function renderHonorlist(res) {
    if (!openresty.isSuccess(res)) {
        error("Failed to get the honor list: " + JSON.stringify(res));
    }
    else {
        //alert("Get the honor list: " + JSON.stringify(res));
        var tpl = {
            "self": "<ol>{$}</ol>",
            //"self[*]": function(x) { return "<li>"+unescape(x.w) + " - "+x.c+"</li>"; }
            "self[*]": function(x) { return "<li>"+ unescape(x.w.replace(/_/g, '%')) + " - "+x.c+"</li>"; }
        };
        document.getElementById("honorlist").innerHTML = jsonT(res, tpl);
    }
}

function support() {
    var cccc = document.getElementById('cccc');
    var new_c = parseInt(cccc.innerHTML) + 1;
    cccc.innerHTML = new_c;
}

function savec() {
    errorclear("errmsg2");
    refreshCaptcha();
    document.getElementById("csubmit").style.display = "block";
}

function submit() {
    var userSolution = document.getElementById("captchainput").value;
    document.getElementById("captchainput").value = "";
    var sel = document.getElementById('wwww');
    var district = sel.value;
    openresty.callback = function(res) {
        if (!openresty.isSuccess(res)) {
            error("Failed to support: " + JSON.stringify(res));
        }
        else {
            //alert(JSON.stringify(res));
            //alert(district);
            var captchaValidation = captchaID + ':' + userSolution;
            var captchaUser = "qyliu.Poster";
            //error(captchaValidation);

            var cccc = document.getElementById('cccc');
            var newscore = parseInt(cccc.innerHTML);
            if (newscore <= 0) {
                error("点击数为0，不能提交哦", "errmsg2");
                return;
            }
            var new_c = (res[0]?parseInt(res[0].c):0) + parseInt(cccc.innerHTML);
            openresty.callback = supportCallback;
            //(res[0]?openresty.putByGet:openresty.postByGet)({ c: new_c }, '/=/model/Honorlist/w/\'' + district + '\'');
            if (res[0])
                openresty.putByGet('/=/model/Honorlist/w/' + district, { _user: captchaUser, _captcha: captchaValidation }, { c: new_c });
            else
                openresty.postByGet('/=/model/Honorlist/~/~', { _user: captchaUser, _captcha: captchaValidation }, { w: district, c: new_c });
        }
    };
    openresty.get('/=/model/Honorlist/w/' + district);
}

function supportCallback(res) {
    if (!openresty.isSuccess(res)) {
        error("Failed to support: " + res.error);
    }
    else {
        refreshCaptcha(res);
        getHonorlist();
    }
}

