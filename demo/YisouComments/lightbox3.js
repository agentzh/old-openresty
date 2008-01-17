//
// getPageScroll()
// Returns array with x,y page scroll values.
// Core code from - quirksmode.org
//
function getPageScroll(){

	var yScroll;

	if (self.pageYOffset) {
		yScroll = self.pageYOffset;
	} else if (document.documentElement && document.documentElement.scrollTop){	 // Explorer 6 Strict
		yScroll = document.documentElement.scrollTop;
	} else if (document.body) {// all other Explorers
		yScroll = document.body.scrollTop;
	}

	arrayPageScroll = new Array('',yScroll) 
	return arrayPageScroll;
}



//
// getPageSize()
// Returns array with page width, height and window width, height
// Core code from - quirksmode.org
// Edit for Firefox by pHaez
//
function getPageSize(){
	
	var xScroll, yScroll;
	
	if (window.innerHeight && window.scrollMaxY) {	
		xScroll = document.body.scrollWidth;
		yScroll = window.innerHeight + window.scrollMaxY;
	} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
		xScroll = document.body.scrollWidth;
		yScroll = document.body.scrollHeight;
	} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
		xScroll = document.body.offsetWidth;
		yScroll = document.body.offsetHeight;
	}
	
	var windowWidth, windowHeight;
	if (self.innerHeight) {	// all except Explorer
		windowWidth = self.innerWidth;
		windowHeight = self.innerHeight;
	} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
		windowWidth = document.documentElement.clientWidth;
		windowHeight = document.documentElement.clientHeight;
	} else if (document.body) { // other Explorers
		windowWidth = document.body.clientWidth;
		windowHeight = document.body.clientHeight;
	}	
	
	// for small pages with total height less then height of the viewport
	if(yScroll < windowHeight){
		pageHeight = windowHeight;
	} else { 
		pageHeight = yScroll;
	}

	// for small pages with total width less then width of the viewport
	if(xScroll < windowWidth){	
		pageWidth = windowWidth;
	} else {
		pageWidth = xScroll;
	}


	arrayPageSize = new Array(pageWidth,pageHeight,windowWidth,windowHeight) 
	return arrayPageSize;
}

//
// showLightbox()
// Preloads images. Pleaces new image in lightbox then centers and displays.
//
function showLightbox(id)
{
	var videos = dojo.query('.video');
	for(var v=0;v<videos.length;v++){
		videos[v].style.display = 'none';		
	}
	// prep objects
	var objOverlay = document.getElementById('overlay');
	objBox = document.getElementById('rw3pl_yy');
	var arrayPageSize = getPageSize();
	var arrayPageScroll = getPageScroll();
	// set height of Overlay to take up whole page and show
	objOverlay.style.height = (arrayPageSize[1] + 'px');
	objOverlay.style.display = 'block';
	objBox.style.display = 'block';
//	filldata(id);

	var xy = [YUD.getViewportWidth()/2-180, YUD.getViewportHeight()/2-95+arrayPageScroll[1]];//2007-11-16
	YUD.setXY(objBox, xy);
	selects = document.getElementsByTagName("select");
        for (i = 0; i != selects.length; i++) {
                selects[i].style.visibility = "hidden";
        }
}


//
// hideLightbox()
//
function hideLightbox()
{
	var videos = dojo.query('.video');
	for(var v=0;v<videos.length;v++){
		videos[v].style.display = 'block';		
	}
	// prep objects
	objOverlay = document.getElementById('overlay');
	objBox = document.getElementById('rw3pl_yy');
	objOverlay.style.display = 'none';
	objBox.style.display = 'none';
	document.getElementById('CCcontent2').value= '';
	document.getElementById('CCpid').value= 0;
	selects = document.getElementsByTagName("select");
    for (i = 0; i != selects.length; i++) {
		selects[i].style.visibility = "visible";
	}
}
//
function filldata(id){
	YUD.get("portscrolldiv").innerHTML = gtdata[id];
	/*YUD.get("gt_0").innerHTML = gtdata[id][0];
	YUD.get("gt_1").innerHTML = gtdata[id][1];
	YUD.get("gt_2").innerHTML = gtdata[id][2];
	YUD.get("gt_3").innerHTML = gtdata[id][3];*/
}
