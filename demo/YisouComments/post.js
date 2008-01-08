//var host = "http://10.62.136.86/";
//var host = "http://10.62.164.57/";
var host = "http://ced02.search.cnb.yahoo.com/openapi/";
/**
 * insertAfter
 * @param {obj} DomElementObj
 * @param {obj} DomElementObj
 */
function insertAfter(newElement,targetElement){
	var parent = targetElement.parentNode;
	if(parent.lastChild == targetElement)
		parent.appendChild(newElement);
	else
		parent.insertBefore(newElement,targetElement.nextSibling);
}

/**
 * getQuery
 * @param {str} name
 */
function getQuery(name){
 var str = location.search;
 var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
 var r = str.substr(str.indexOf("\?")+1).match(reg);
 if(r!=null)
 return decodeURI(r[2]);
 else
 return null;
}

/**
 * loadPersonName
 * @param {str} url
 * description: get the person name form url params 
 * 		write it into persionName div & searchbox
 */
function loadPersonName(url){
	var name = getQuery('id');
	dojo.byId('p').value= name;
	
	var as = dojo.query('#searchBox a');
	for(var a=0;a<as.length-1;a++)
		as[a].href+='&p='+encodeURI(getQuery('id'));
}

function alterOrder(container,parentid,offset,count,child_offset,child_count,dsc,orderby,obj){
	var old_order = dojo.cookie('YYisouCommentsOrder');
	var old_sort = dojo.cookie('YYisouCommentsSort');
	if(obj.nextSibling.id)
		obj.parentNode.removeChild(obj.nextSibling);
	var scrow = document.createElement("span");
	scrow.id="scrow";
	if(old_sort == 'desc') {
		dsc='asc';
		scrow.innerHTML = ' ↑ ';
	}else{
		dsc='desc';
		scrow.innerHTML = ' ↓ ';
	}
	insertAfter(scrow,obj);
	

	fetchResults(container,parentid,offset,count,child_offset,child_count,dsc,orderby);
	dojo.cookie('YYisouCommentsOrder',orderby);
	dojo.cookie('YYisouCommentsSort',dsc);
	
}

/**
 * init
 */
function init(){
	loadPersonName(document.URL);
	var orderby = dojo.cookie('YYisouCommentsOrder');
	var sort = dojo.cookie('YYisouCommentsSort');
	if(!orderby) orderby='id';
	if(!sort) sort='desc';
	try{
		countResults('commentsCount');
	}catch(e){}
	try{
		fetchResults('review',0,0,11,0,5,sort,orderby);
	}catch(e){}
}

/**
 * afterSub
 * @param {str} container: container div id 
 * @param {str} parentid: the id of current comment's parent (original 0) 
 * @param {str} offset: beginning id of this page 
 * @param {str} count
 * @param {str} child_offset: the children comments of current comment
 * @param {str} child_count
 * @param {str} dsc: 'desc' info in database
 * @param {str} orderby: 'order by' info in database
 * description: after submited new comment, 
 * 		this is used to count new result number and draw new comments
 */
function afterSub(container,parentid,offset,count,child_offset,child_count,dsc,orderby){
	countResults('commentsCount');
	fetchResults(container,parentid,offset,count,child_offset,child_count,dsc,orderby);
	dojo.byId('CCpid').value=0;
}

/**
 * countResults
 * @param {str} count_span: the div which the count number should be written in
 * description: fetch the total comment of the current page
 * 		store it in cookie for later usage
 */
function countResults(count_span){
	var count_div = dojo.byId(count_span);
	count_div.innerHTML = '';
	
	dojo.io.script.remove('jsonCountTag');
	
	var url=host+"=/post/action/.Select/lang/minisql?user=carrie&var=total&data=\"select count(*) from YisouComments where parentid=0 \"";
	
	var scriptTag = document.createElement("script");
        scriptTag.id = "jsonCountTag";
        scriptTag.src = url + "&rand="+Math.random(); 
        scriptTag.type = "text/javascript";
        var headTag = dojo.query('head')[0];
        headTag.appendChild(scriptTag);

        scriptTag.onload=scriptTag.onreadystatechange=function(){
                if(this.readyState && this.readyState=="loading") return;
//		try{
                	count_div.innerHTML = total[0]['count'];
			dojo.cookie('YYisouCommentsTotal',total[0]['count']);
//		}catch(e){}
        }


}

/**
 * fetchResults 
 * @param {str} container: container div id 
 * @param {str} parentid: the id of current comment's parent (original 0) 
 * @param {str} offset: beginning id of this page 
 * @param {str} count
 * @param {str} child_offset: the children comments of current comment
 * @param {str} child_count
 * @param {str} dsc: 'desc' info in database
 * @param {str} orderby: 'order by' info in database
 */
function fetchResults(container,parentid,offset,count,child_offset,child_count,dsc,orderby){
	dojo.byId('overlay').style.display='block';
	dojo.io.script.remove('jsonScriptTag');


	if(!orderby) orderby=dojo.cookie('YYisouCommentsOrder');
        if(!orderby) orderby='id';
	if(!dsc) dsc=dojo.cookie('YYisouCommentsSort');
        if(!dsc) dsc='desc';
		
	var url=host+"=/post/action/.Select/lang/minisql?user=carrie&var=comments&data=\"select * from yisou_comments_fetch_results("+parentid+",$q$$q$,$q$"+orderby+"$q$,"+offset+","+count+","+child_offset+","+child_count+",$q$"+dsc+"$q$)\"";

	var scriptTag = document.createElement("script");
	scriptTag.id = "jsonScriptTag";
	scriptTag.src = url + "&rand="+Math.random(); 
	scriptTag.type = "text/javascript";
	var headTag = dojo.query('head')[0];
	headTag.appendChild(scriptTag);

	scriptTag.onload=scriptTag.onreadystatechange=function(){
		if(this.readyState && this.readyState=="loading"){
			return;
		}
		try{
			drawComments(comments,container,parentid,offset,count,child_offset,child_count,dsc);
		}catch(e){
			alert(e.name);
			dojo.byId(container).innerHTML+='服务器错误，请刷新重试';
		}finally{
			dojo.byId('overlay').style.display = 'none';
			dojo.byId('overlay').innerHTML = '';
		}
	}
}


/**
 * updateScore
 * @param {str} method: 'add' or 'minus'
 * @param {int} value
 * @param {int} id: the db id of current comment
 * @param {str} cid: value span id 
 */
function updateScore(method,value,id,cid){
	var u = host+"=/post/action/.Select/lang/minisql?user=carrie&var=hello&data=\"select yisou_comments_update_score($q$"+method+"$q$,"+value+","+id+");\"";
	dojo.io.script.remove('addScoreScriptTag');
	
	var key = escape(getQuery('id')+id);
	if(dojo.cookie(key)!=null) return;

	var scriptTag = document.createElement("script");
        scriptTag.id = "addScoreScriptTag";
        scriptTag.src = u + "&rand="+Math.random(); 
        scriptTag.type = "text/javascript";
        var headTag = dojo.query('head')[0];
        headTag.appendChild(scriptTag);

        scriptTag.onload=scriptTag.onreadystatechange=function(){
                if(this.readyState && this.readyState=="loading") return;
		if(method == 'add')
			dojo.byId(cid).innerHTML = parseInt(dojo.byId(cid).innerHTML) + parseInt(value) ;
		if(method == 'minus')
			dojo.byId(cid).innerHTML = parseInt(dojo.byId(cid).innerHTML) + parseInt(value);
		dojo.cookie(key,1);
        }
	
}

/**
 * drawComments 
 * @param {str} container: container div id 
 * @param {str} parentid: the id of current comment's parent (original 0) 
 * @param {str} offset: beginning id of this page 
 * @param {str} count
 * @param {str} child_offset: the children comments of current comment
 * @param {str} child_count
 * @param {str} dsc: 'desc' info in database
 */
function drawComments(objs,container,parentid,offset,count,child_offset,child_count,dsc){
	if(objs.length == 0) return ;
	if(parentid != 0)
	{
		var nn = (objs.length == count)?count-1:objs.length;	
		for(var cc=0;cc<nn;cc++)
		{
			objc = objs[cc];
			var iidiv = document.createElement('div');
			iidiv.className = 'child';
			var base = dojo.byId('commentList'+objc['parentid']);
			base.parentNode.parentNode.appendChild(iidiv);
			drawContent(objc,iidiv);
		}		
		var im = dojo.byId(container+"_more");
                if(im)
                         im.parentNode.removeChild(im);

		if(objs.length < count)
			return ;	

		var more = document.createElement('a');
		more.href = '#';
		more.id = container+"_more";
		more.className = 'more';
		more.innerHTML = '更多针对此留言的回复';
		more.onclick = function(){
			fetchResults(container,parentid,offset+count-1,count,0,0,dsc);
			return false;
		}
		dojo.byId(container).parentNode.parentNode.appendChild(more);
		return;
	}

		

	var ul = dojo.byId(container);
	if(parentid == 0) 
		ul.innerHTML ='';

	var parent_num = 0 ;
	var child_num = 0;	

	var parents = new Array();
	var children = new Array();
	for(var i = 0;i<objs.length;i++)
	{
		if(objs[i]['parentid'] == 0)
			parents[parent_num++] = objs[i];
		else
			children[child_num++] = objs[i];
	}	

	var n = (parent_num == count)?count-1:parent_num;	
	for(var obj = 0; obj < n; obj++)
	{
		var comment = parents[obj];
		comment['drawChild'] = 0;
		var iidiv = document.createElement('div');
		iidiv.className = 'rw3pl_a';
		ul.appendChild(iidiv);
		var org_h4 = document.createElement('h4');
		iidiv.appendChild(org_h4);	
		var iidiv = document.createElement('div');
		org_h4.appendChild(iidiv);
		drawContent(comment,iidiv);

		for(var c = 0; c<child_num; c++){
			var objc = children[c];
			if(objc['parentid'] == comment['id'])
			{
				var iidiv = document.createElement('div');
				iidiv.className = 'child';
				var base = dojo.byId('commentList'+objc['parentid']);
				base.parentNode.parentNode.appendChild(iidiv);
				drawContent(objc,iidiv);	
				comment['drawChild']++;
			}
		}
			
		if(comment['drawChild'] < comment['children'])
		{
			var more = document.createElement('a');
			base.parentNode.parentNode.appendChild(more);
			more.href = '#';
			more.id = base['id']+"_more";
			more.className = 'more';
			more.innerHTML = '更对针对此留言的回复';
			more.onclick = (function(con,p,o,c){return function(){
				fetchResults(con,p,o,c,0,0,dsc);return false;
			}})(base['id'],comment['id'],child_offset+child_count-1,child_count);	
		}
	}


		

	if(parentid == 0)
	{
		var pages = dojo.query('.page');
	
		for (var p=0;p<pages.length;p++){
			var page = pages[p];
		page.innerHTML = '';
		if(offset != 0)
		{
			var pre = document.createElement('a');
			pre.href = "#";
			pre.className = 'nxt';
			pre.innerHTML = '上一页';
			pre.onclick = function(){
				fetchResults(container,0,offset-count+1,count,child_offset,child_count,dsc);return false;}	
			page.appendChild(pre);			
		}

	
		var current = Math.ceil(offset/count)+1;
		var total = dojo.cookie('YYisouCommentsTotal');
		var k=offset-count+1;
		m=0;
		while((m<5)&&(k>=0)){
			m++;
			var pp = document.createElement('a');
                        pp.href = '#';
                        pp.className = 'nxt';
                        pp.innerHTML = current-m;
                        pp.onclick = (function(a,b,c,d,e,f,g){ return function(){
                                fetchResults(a,b,c,d,e,f,g);
				return false;
			}})(container,0,k,count,child_offset,child_count,dsc); 
			k=k-count+1;
			insertAfter(pp,pre);
		}

		var current_page = document.createElement('b');
		current_page.innerHTML = current;
		page.appendChild(current_page);
		

		var k=offset+count-1;
		var m=0;
		while((m<5)&&(k<total)){
			m++;
			var nxt = document.createElement('a');
                        nxt.href = '#';
                        nxt.className = 'nxt';
                        nxt.innerHTML = current+m;
                        nxt.onclick = (function(a,b,c,d,e,f,g){ return function(){
                                fetchResults(a,b,c,d,e,f,g);
				return false;
			}})(container,0,k,count,child_offset,child_count,dsc); 
                        page.appendChild(nxt);
			k+=count-1;
		}

		if(parent_num == count)
		{
			var next = document.createElement('a');
			next.href = '#';
			next.className = 'nxt';
			next.innerHTML = '下一页';
			next.onclick = function(){
				fetchResults(container,0,offset+count-1,count,child_offset,child_count,dsc);return false;}	
			page.appendChild(next);
		}

		}
	}
	//make a note for current page:
	var info_div = document.createElement('div');
	info_div.id="info_div";
	info_div.setAttribute('count',count);
	info_div.setAttribute('offset',offset);
	info_div.setAttribute('child_count',child_count);
	info_div.setAttribute('child_offset',child_offset);
	info_div.setAttribute('desc',dsc);
	info_div.setAttribute('container',container);

	ul.appendChild(info_div);
}


/** 
 * drawContent
 * @param {obj} comment: current comment info
 * @param {obj} iidiv: DOMelementObj
 */
function drawContent(comment,iidiv){
	var idiv = iidiv;
	var id = 'commentList' + comment['id'];
	idiv.id = id;
	idiv.setAttribute('dbid',comment['id']);

	var title = document.createElement('h2');

	var d = Date.parse(comment['created'].substring(0,19).replace(/-/gm,"/")+" UTC");
	var dnow = new Date();
	dnow.setTime(d);
	title.innerHTML = '来自<b>'+comment['owner']+'</b>的发言 <span>'+dnow.toLocaleString()+'</span>';
	idiv.appendChild(title);
	var content = document.createElement('p');
	var c = comment['content'].replace(/&/gm, "&amp;").replace(/</gm, "&lt;").replace(/>/gm,"&gt;").replace(/"/gm, "&quot;").replace(/&lt;br&gt;/gm,'<br>')+"<br>";
	c=c.replace(/(http:\/\/|^mms:\/\/|rtsp:\/\/|pnm:\/\/|ftp:\/\/|mmst:\/\/|mmsu:\/\/)([^\r\n||^(<br>)]*)/igm,"<a href=$1$2>$1$2</a>");
	content.innerHTML = c;
	idiv.appendChild(content);
	

	if((comment['img']!=null)&&(comment['img']!='')){
		var imgObj = new Image();
		imgObj.src = comment['img'];
		var img = document.createElement('img');
		img.src = imgObj.src;
		if(imgObj.width>800)
			img.width = 800;
		content.appendChild(img);
		
	}

	if((comment['video']!=null)&&(comment['video']!=''))
	{
		var vp = document.createElement("p");
		vp.className="video";
		vp.innerHTML = "<br>";
		vp.innerHTML += "<object width=500px height=400px><param name=\"movie\" value=\""+comment['video']+"\"><embed width=\"500px\" height=\"400px\"  src=\""+comment['video']+"\"></embed>";
		content.appendChild(vp);	
	}

	if(comment['parentid']==0)
	{
		var ext = document.createElement('h3');
		idiv.appendChild(ext);
		
		var rpl_btn = document.createElement("a");
		rpl_btn.className = 'reply';
		rpl_btn.innerHTML= '回复此发言';

		rpl_btn.href="#";
		pid = "commentList"+comment['id'];
		rpl_btn.onclick = (function(obj){return function (){
			dojo.byId('CCpid').value = obj.substr(11,obj.length-1);
			dojo.byId('quoteContent').innerHTML = this.parentNode.parentNode.childNodes[1].innerHTML.substr(0,10)+"...";
			showLightbox();
			dojo.byId('CCcontent2').focus();
			return false;
		}})(pid);
		ext.appendChild(rpl_btn);	

		scoreid='score_'+id;
		
		var addScore = document.createElement('a');
		addScore.innerHTML = '支持';
		addScore.className = 'rw3pl_zc';
		addScore.setAttribute('scoreid',scoreid+'_up');
		addScore.href = '#';
		addScore.onclick=function(){
			updateScore('add',1,this.parentNode.parentNode.getAttribute('dbid'),this.getAttribute('scoreid'));
			return false;
		}
		ext.appendChild(document.createTextNode('  '));
		ext.appendChild(addScore);
		var support_num = document.createElement('span');
		support_num.id = scoreid+'_up';
		support_num.innerHTML = comment['support'];
		ext.appendChild(document.createTextNode("("));
		ext.appendChild(support_num);
		ext.appendChild(document.createTextNode(")"));

		var minScore = document.createElement('a');
		minScore.innerHTML = '反对';
		minScore.className = 'rw3pl_fd';
		minScore.setAttribute('scoreid',scoreid+'_down');
		minScore.href = '#';
		minScore.onclick=function(){
		       updateScore('minus',1,this.parentNode.parentNode.getAttribute('dbid'),this.getAttribute('scoreid'));
			return false;
		}
		ext.appendChild(minScore);
	  	var deny_num = document.createElement('span');
		deny_num.id = scoreid+'_down';
		deny_num.innerHTML = comment['deny'];
		ext.appendChild(document.createTextNode("("));
		ext.appendChild(deny_num);
		ext.appendChild(document.createTextNode(")"));

	}

}


/**
 * submitFunc
 * @param {int} parentid: determine whether the current submit is to the top of comments
 */
function submitFunc(parentid){
	if(parentid == 0){
		var c = dojo.byId("CCcontent").value;
		if((dojo.byId('anno').checked)||(dojo.string.trim(dojo.byId("CCuser").value) == ''))
			var u='匿名';
		else
		var u = dojo.byId("CCuser").value;
		var orderby = 'id';
	}else{
		var c = dojo.byId("CCcontent2").value;
		if((dojo.byId('anno2').checked)||(dojo.string.trim(dojo.byId("CCuser2").value) == ''))
			var u='匿名';
		else
		var u = dojo.byId("CCuser2").value;
	}
	c = c.replace(/"/g,'\\"');
	c = c.replace(/</g,'\<');
	c=dojo.string.trim(c);
	u = u.replace(/"/g,'\\"');
	u = u.replace(/</g,'\<');
	u=dojo.string.trim(u);

	if(c.length=='')
	{
		alert("留言内容不能为空");
		return;
	}

	var v = dojo.string.trim(dojo.byId('CCvideo').value);
	if((v!='')&&(v.indexOf('http://player.youku.com')==-1)&&(v.indexOf('http://vhead.blog.sina.com.cn')==-1)){
		alert('视频格式输入不正确，暂时只支持sina或youku视频的flash URL');
		dojo.byId('CCvideo').focus();
		return false;
	}

	var img = dojo.string.trim(dojo.byId('CCimg').value);
	if((img!='')&&(img.search(/gif|png|jpg/gm)<2)){
		alert('图片格式错误，支持gif、png、jpg格式');
		dojo.byId('CCimg').focus();
		return false;
	}
	
var params = new Array();
params[0] = 'title:""';
params[1] = 'owner:"' +u+ '"';
params[2] = 'content:"' + c.replace(/\n/g,'<br>') + '"';
params[3] = 'posturl:"' + document.URL + '"';
params[4] = 'host:"' + document.location.host+ '"';
params[5] = 'parentid:' + dojo.byId("CCpid").value;
params[6] = 'video:"' + v +'"';
params[7] = 'img:"' + dojo.byId("CCimg").value+'"';
var str = '';
for(var i=0;i<params.length;i++)
{
	if(str != '') str+=",";
	str += params[i];
}
console.log(str);
var ts = dojo.io.iframe.send({
    form: dojo.byId("myform"),
    url: host+"=/model/YisouComments/~/~?user=carrie",
    content: {data:"{"+str+"}"},
    preventCache: true,
    handlAs: 'html',
    handle:function(res,ioArgs){
	var info_div=dojo.byId('info_div');
	if(!info_div)
		init();
		afterSub(info_div.getAttribute('container'),0,info_div.getAttribute('offset'),info_div.getAttribute('count'),info_div.getAttribute('child_offset'),info_div.getAttribute('child_count'),info_div.getAttribute('desc'),orderby);
	dojo.byId('CCvideo').value='';	
	dojo.byId('CCimg').value='';
	dojo.byId('CCcontent').value='';
    }
});
return false;
}



dojo.addOnLoad(init);
