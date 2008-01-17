var isIE = !!document.all;
if(isIE)
document.documentElement.addBehavior("#default#userdata");
function  saveUserData(key, value){
    var ex; 
    if(isIE){
        with(document.documentElement)try {
            load(key);
            setAttribute("value", value);
            save(key);
            return  getAttribute("value");
        }catch (ex){
            //alert(ex)
        }
    }else if(window.sessionStorage){//for firefox 2.0+
        try{
            sessionStorage.setItem(key,value)
        }catch (ex){
            alert(ex);
        }
    }else{
        alert("当前浏览器不支持userdata或者sessionStorage特性")
    }
}

function loadUserData(key){
    var ex; 
    if(isIE){
        with(document.documentElement)try{
            load(key);
            return getAttribute("value");
        }catch (ex){
          //  alert(ex.message);
          	return null;
        }
    }else if(window.sessionStorage){//for firefox 2.0+
        try{
            return sessionStorage.getItem(key)
        }catch (ex){
        //    alert(ex)
        }
    }else{
        alert("当前浏览器不支持userdata或者sessionStorage特性")
    }
}
function  deleteUserData(key){
    var ex; 
    if(isIE){
        with(document.documentElement)try{
            load(key);
            expires = new Date(315532799000).toUTCString();
            save(key);
        }
        catch (ex){
            //alert(ex.message);
        }
    }else if(window.sessionStorage){//for firefox 2.0+
        try{
            sessionStorage.removeItem(key)
        }catch (ex){
            alert(ex)
        }
    }else{
        alert("当前浏览器不支持userdata或者sessionStorage特性")
    }

    dojo.byId('autosavetip').style.display='none';
    dojo.byId('autosavetipx').style.display='none';
} 

function autosaveInit(){
        if(loadUserData("autosave"))
                dojo.byId("CCcontent").value = loadUserData("autosave");

}
function autosave(){
	setInterval(function(){
			if(dojo.byId("CCcontent").value=='') return;
			var d = new Date; 
			dojo.byId("autosavetip").innerHTML = " autosaved at : "+d; 
			dojo.byId("autosavetip").style.display="block";
			dojo.byId("autosavetipx").style.display="block";
			saveUserData("autosave",dojo.byId("CCcontent").value);
		    },5000);
}

dojo.addOnLoad(autosaveInit);
