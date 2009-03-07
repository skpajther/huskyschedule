function XMLHttpPost(strURL) {
	var xmlHttpReq = getXmlHttp();
    if(xmlHttpReq != null) {
	    xmlHttpReq.open('GET', strURL, true);
	    xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	    xmlHttpReq.onreadystatechange = function() {
	        if (xmlHttpReq.readyState == 4) {
	        	if(xmlHttpReq.status == 200)
	            	showResults(xmlHttpReq.responseText);
	            else
	            	alert("Problem retrieving AJAX data");
	        }
	    }
	    searchStartDate = new Date();
	    xmlHttpReq.send(null);
	}
	else {
		alert("Sorry, this browser does not support AJAX.");
	}
}

function getXmlHttp() {
	var xmlHttp;
	try {
 		xmlHttp = new XMLHttpRequest(); // Firefox, Opera 8.0+, Safari
  	}
	catch(e) { //Internet Explorer
  		try {
    		xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
    	}
  		catch(e) {
    		try {
      			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
      		}
    		catch(e) {
      			alert("Sorry, your browser does not support AJAX. This map is unavailable.");
      		}
    	}
  	}
  	return xmlHttp;
}