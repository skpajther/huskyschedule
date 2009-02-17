//GLOBAL VARIABLES
var map;
var markers; //holds the markers
var selectedMarker; //the open marker
var currentMapType; //the maptype in use
var icon;
var uw_center; //center of UW Map
var center; //center of G_SATELLITE_MAP & G_HYBRID_MAP
var displayCenter; //center of the map the user has moved to
var width; 
var height;
var opening; //currently opening a marker, avoid certain behavior
var displayingSearchResults;
var markerOpen; //true if a marker is open
var mapDiv; //div that holds the map
var searchResultsDiv; //div that holds the search restuls
var contentDiv; //div that holds all the content
var buildingsListDiv; //div with all the building options
var searchStartDate; //when we started a search
var breadcrumbsDiv; //div with the breadcrumbs
//END GLOBAL VARIABLES
	
//window.onresize = function(){ resizer(); };
	
function initialize(abbrev, path) {
	if(GBrowserIsCompatible()) {
		initializeFields(path);
 		prepareMap();
 		setMinimumZoomLevels();
 		calculateDimensions();
	 	mapListeners();
		loadMarkers(abbrev, path);
	}
	else {
		alert("Your browser is incompatible. Please use IE, Firefox, Chrome, Safari, or Opera.");
	}
}
		
function prepareMap() {
	map = new GMap2(document.getElementById("map"));
	map.setCenter(center, 17); //UW campus
	map.addMapType(G_SATELLITE_MAP);
	map.addMapType(G_HYBRID_MAP);
	map.removeMapType(G_NORMAL_MAP);
	map.setMapType(currentMapType);
	map.enableContinuousZoom();
	map.enableScrollWheelZoom();
	map.addControl(new GSmallMapControl(), new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(10, 10)));
	map.addControl(new GMapTypeControl());
	var customMapType = new GmapUploaderMapType(map, "http://mt.gmapuploader.com/tiles/iGp7TBqnME", "png", 5);
	map.addMapType(customMapType);
}
		
function initializeFields(path) {
	currentMapType = G_SATELLITE_MAP;
	//center = new GLatLng(47.6544,-122.3080);
	center = new GLatLng(47.6538037015491, -122.30777084827423);
	//uw_center = new GLatLng(1.93359375,-5.2734375);
	uw_center = new GLatLng(-5.5810546875, -10.37109375);
	markers = new Array();
	makeIcon(path);
	displayCenter = center;
	mapDiv = document.getElementById("map");
	searchResultsDiv = document.getElementById("searchResults");
	contentDiv = document.getElementById("content");
	contentDiv.removeChild(searchResultsDiv);
	buildingsListDiv = document.getElementById("mapmenu");
	breadcrumbsDiv = document.getElementById("crumbs");
}

function calculateDimensions() {
	var bounds = map.getBounds();
	var sw = bounds.getSouthWest();
	var ne = bounds.getNorthEast();
	height = ne.lat() - sw.lat();
	width = ne.lng() - sw.lng();
}

function setMinimumZoomLevels() {
	var mapTypes = map.getMapTypes();
	mapTypes[0].getMinimumResolution = function() { return 15; } //G_SATELLITE_MAP
	mapTypes[1].getMinimumResolution = function() { return 15; } //G_HYBRID_MAP
	mapTypes[2].getMinimumResolution = function() { return 3; }  //UW Map
}

function makeIcon(path) {
	icon = new GIcon();
	icon.image = path+"images/map/wlogo.gif";
	icon.transparent = path+"images/map/wlogo_onclick.png";
	icon.printImage = icon.image;
	icon.mozPrintImage = icon.image;
	icon.iconSize = new GSize(25,25);
	icon.iconAnchor = new GPoint(0,icon.iconSize.height / 2);
	icon.infoWindowAnchor = new GPoint(icon.iconSize.width,0);
	icon.shadowSize = new GSize(0,0);
	icon.maxHeight = 5;
}

function resizer() {
	var verticalSpan = Geometry.getViewportHeight();
	//TODO: finish this
}

function mapListeners() {
	GEvent.addListener(map,"maptypechanged", 
		function() {
			var newMapType = map.getCurrentMapType();
			if((newMapType==G_HYBRID_MAP || newMapType==G_SATELLITE_MAP)&&
			  !(currentMapType==G_HYBRID_MAP || currentMapType==G_SATELLITE_MAP)) {
			  	for(i in markers) {
					markerData = markers[i];
					markerData.marker.setLatLng(markerData.normal);
				}
				if(markerOpen) {
					map.setZoom(17);
					openMarker(selectedMarker.abbrev);
				}
				else {
					map.setCenter(center, 17);
				}
			}
			else if(!(newMapType==G_HYBRID_MAP || newMapType==G_SATELLITE_MAP)) { //custom
				for(i in markers) {
					markerData = markers[i];
					markerData.marker.setLatLng(markerData.uw);
				}
				if(markerOpen) {
					openMarker(selectedMarker.abbrev);
					map.setZoom(4);
				}
				else {
					map.setCenter(uw_center, 4);
				}
			}
			currentMapType = newMapType;
		}
	);
	GEvent.addListener(map, "moveend",
		function() {
			displayCenter = map.getCenter();
		}
	);
	
}
		
function loadMarkers(abbrev, path) {
	GDownloadUrl(path+"buildings/map_loader.xml", 
		function(data) {
			data = data.split("<respond_to?:to_xml/><to_xml/>")[0];  //remove this crap
			var xml = GXml.parse(data);
			var data = xml.documentElement.getElementsByTagName("building"); 
			for (var i=0; i<data.length; i++)
				createMarker(data[i], path);
			if(abbrev.length > 0)
				openMarker(abbrev)
		}
	);
}

function createMarker(data, path) {
	var name = data.getAttribute("name");  
	var lat = data.getAttribute("lat");
	var lng = data.getAttribute("lng");
	var uw_lat = data.getAttribute("uw_lat");
	var uw_lng = data.getAttribute("uw_lng");
	var regularPoint = new GLatLng(lat, lng);
	var uwPoint = new GLatLng(uw_lat, uw_lng);
	var abbrev = data.getAttribute("abbrev");
	var gmarker = new GMarker(regularPoint, icon);
	gmarker.abbrev = abbrev;
	gmarker.title = name;
	var html = makeMarkerHTML(name, abbrev, path);
	gmarker.bindInfoWindowHtml(html);
	GEvent.addListener(gmarker, "click", 
		function(e) {
			buildingsListDiv.selectedIndex = getOptionIndex(gmarker.abbrev);
		}
	);
	GEvent.addListener(gmarker, "infowindowclose", 
		function() {
			if(!opening) {
				buildingsListDiv.selectedIndex = -1;
				breadcrumbsDiv.innerHTML = crumbs();
			}
			markerOpen = false;
			selectedMarker = null;
		}
	);
	GEvent.addListener(gmarker, "infowindowopen",
		function() {
			selectedMarker = gmarker;
			markerOpen = true;
			breadcrumbsDiv.innerHTML = crumbsPlus(gmarker.title);
		}
	);
	map.addOverlay(gmarker);
	markers[abbrev] = {marker:gmarker, name:name, abbrev:abbrev, normal:regularPoint, uw:uwPoint, html:html};
}

function crumbsPlus(append) {
	return crumbs() + " > " + append;
}

function crumbs() {
	return "<a href='index.html'>Home</a> > <a href='#' onclick='if(displayingSearchResults) { hideResultsClearSelected(); } else { clearSelected(); }'>Map</a>";
}

function makeMarkerHTML(name, abbrev, path) {
    var picture = abbrev + ".JPG";
    var picture_path = path + "images/buildings/small/" + picture;
	var html = "<html>\n";
	html += "<b>"+name+"&nbsp;("+abbrev+")</b><br>\n";
	html += "<div style='height:210px;width:300px;text-align:center;'>";
	if(picture.length > 0) {
		var picture_path = path+"images/buildings/small/" + picture;
		html += "<img src=\""+picture_path+"\" style='height:199px;width:300px;border:0;' onerror=\"this.src='"+path+"/images/poweredby300199.jpg';\"><br>\n";
	}
	html += "</div>\n</html>";
	return html;
}       

function openMarker(abbrev) {
	if(displayingSearchResults) {
		contentDiv.removeChild(searchResultsDiv);
		contentDiv.appendChild(mapDiv);
		displayingSearchResults = false;
	}
	element = markers[abbrev];
	if(currentMapType == G_SATELLITE_MAP || currentMapType == G_HYBRID_MAP)
		map.panTo(element.normal);
	else //UW Map
		map.panTo(element.uw);
	opening = true;
	element.marker.openInfoWindowHtml(element.html);
	opening = false;
}

function searchFor(searchField, URL) {
	if(searchField != "") {
		buildingsListDiv.options.selectedIndex = -1;
		XMLHttpPost(URL + "?search_text=" + searchField);
	}	
}

function fileExists(url) {
	var oHttp = null;
	if (window.XMLHttpRequest) // Mozilla/Safari
        oHttp = new XMLHttpRequest();
    else if (window.ActiveXObject) // Old IE
        oHttp = new ActiveXObject("Microsoft.XMLHTTP");
    if(oHttp != null) {
    	oHttp.open("HEAD", url, false);
		oHttp.onreadystatechange = function() {
			if(oHttp.readyState == 4) {
		 		return oHttp.status != 404; //404 = file not found
		 	}
		}
		oHttp.send(null);
	} 
	else {
		alert("AJAX error check if file exists");
		return false;
	}
}

function XMLHttpPost(strURL) {
	var xmlHttpReq = null;
    var self = this;
    if (window.XMLHttpRequest) // Mozilla/Safari
        self.xmlHttpReq = new XMLHttpRequest();
    else if (window.ActiveXObject) // Old IE
        self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
    if(self.xmlHttpReq != null) {
	    self.xmlHttpReq.open('GET', strURL, true);
	    self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	    self.xmlHttpReq.onreadystatechange = function() {
	        if (self.xmlHttpReq.readyState == 4) {
	        	if(self.xmlHttpReq.status == 200)
	            	showResults(self.xmlHttpReq.responseText);
	            else
	            	alert("Problem retrieving AJAX data");
	        }
	    }
	    searchStartDate = new Date();
	    self.xmlHttpReq.send(null);
	}
	else {
		alert("Sorry, this browser does not support AJAX.");
	}
}

function showResults(results) {
	if(displayingSearchResults) {
		contentDiv.removeChild(searchResultsDiv);
	}
	else {
		map.closeInfoWindow();
		contentDiv.removeChild(mapDiv);
		displayingSearchResults = true;
	}
	breadcrumbsDiv.innerHTML = crumbsPlus("Search Results");
	var deltaMillis = (new Date()).getTime() - searchStartDate.getTime();
	var deltaSeconds = deltaMillis / 1000;
	results += "<br><br>Completed in " + deltaSeconds + " seconds.";
	searchResultsDiv.innerHTML = results;
	contentDiv.appendChild(searchResultsDiv);
}	

function hideResultsOpenMarker(abbrev) {
	contentDiv.removeChild(searchResultsDiv);
	contentDiv.appendChild(mapDiv);
	displayingSearchResults = false;
	buildingsListDiv.selectedIndex = getOptionIndex(abbrev);
	openMarker(abbrev);
}

function hideResultsClearSelected() {
	contentDiv.removeChild(searchResultsDiv);
	contentDiv.appendChild(mapDiv);
	breadcrumbsDiv.innerHTML = crumbs();
	displayingSearchResults = false;
	buildingsListDiv.selectedIndex = -1;
	if(currentMapType == G_HYBRID_MAP || currentMapType == G_SATELLITE_MAP)
		map.panTo(center);
	else
		map.panTo(uw_center);
}

function clearSelected() {
	map.closeInfoWindow();
	if(currentMapType == G_HYBRID_MAP || currentMapType == G_SATELLITE_MAP)
		map.panTo(center);
	else
		map.panTo(uw_center);
}

function getOptionIndex(abbrev) {
	var options = buildingsListDiv.options;
	var first = 0;
   	var last = options.length;
   	while(first <= last) {
   		var mid = Math.floor((first + last) / 2); 
   		var optionValue = options[mid].value;
   		if (optionValue == abbrev)
   			return mid;
   		else if(optionValue > abbrev) 
   			last = mid - 1; 
		else
    		first = mid + 1;     
	}
	return -1;
}