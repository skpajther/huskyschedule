//GLOBAL VARIABLES
var map;
var markers; //holds the markers
var selectedMarker; //the open marker
var currentMapType; //the maptype in use
var icon; //icon for the markers
var uw_center; //center of UW Map
var center; //center of G_SATELLITE_MAP & G_HYBRID_MAP
var displayCenter; //center of the map the user has moved to
var width; 
var height;
var opening; //currently opening a marker, avoid certain behavior
var displayingSearchResults; //true if search results are being displayed
var mapDiv; //div that holds the map
var searchResultsDiv; //div that holds the search restuls
var contentDiv; //div that holds all the content
var buildingsListDiv; //div with all the building options
var searchStartDate; //when we started a search
var breadcrumbsDiv; //div with the breadcrumbs
var streetview;
var streetviewCapable; //true if browser if capable of showing streetview
var streetviewDiv; //div holding the streetview
var showingStreetview; //true if we are showing streetview
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
	map = new GMap2(mapDiv);
	map.setCenter(center, 16); //UW campus
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
	svOverlay = new GStreetviewOverlay();
	//map.addOverlay(svOverlay);
}
		
function initializeFields(path) {
	currentMapType = G_SATELLITE_MAP;
	center = new GLatLng(47.6538037015491, -122.30777084827423);
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
	streetviewDiv = document.getElementById("streetview");
	contentDiv.removeChild(streetviewDiv);
	streetviewCapable = true;
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
				if(selectedMarker != null) {
					map.setZoom(16);
					openMarker(selectedMarker.abbrev);
				}
				else {
					map.setCenter(center, 16);
				}
			}
			else if(!(newMapType==G_HYBRID_MAP || newMapType==G_SATELLITE_MAP)) { //custom
				for(i in markers) {
					markerData = markers[i];
					markerData.marker.setLatLng(markerData.uw);
				}
				if(selectedMarker != null) {
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
	GEvent.addListener(map, "click",
		function(a,e,c) {
			var latlng = new GLatLng(e.lat(),e.lng());
			var myPOV = { yaw:0, pitch:0 };
			if(streetview==null)
				getNewStreetview();
			streetview.setLocationAndPOV(latlng, myPOV);
			lat = "sv_lat="+e.lat();
			lng = "sv_lng="+e.lng();
			s = "UPDATE huskyschedule_development.buildings SET "+lat+", "+lng+"WHERE abbrev = ''";
			sendtoclipboard(s);
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
	var lat = parseFloat(data.getAttribute("lat"));
	var lng = parseFloat(data.getAttribute("lng"));
	var uw_lat = parseFloat(data.getAttribute("uw_lat"));
	var uw_lng = parseFloat(data.getAttribute("uw_lng"));
	var regularPoint = new GLatLng(lat, lng);
	var uwPoint = new GLatLng(uw_lat, uw_lng);
	var abbrev = data.getAttribute("abbrev");
	var gmarker = new GMarker(regularPoint, icon);
	var id = parseInt(data.getAttribute("id"));
	var hasStreetview = data.getAttribute("sv_lat").length != 0;
	var markerPOV = null;
	var markerSvLatLng = null;
	if(hasStreetview) {
		var sv_lat = parseFloat(data.getAttribute("sv_lat"));
		var sv_lng = parseFloat(data.getAttribute("sv_lng"));
		var sv_yaw = parseFloat(data.getAttribute("sv_yaw"));
		var sv_pitch = parseFloat(data.getAttribute("sv_pitch"));
		var sv_zoom = parseInt(data.getAttribute("sv_zoom"));
		markerPOV = { yaw:sv_yaw, pitch:sv_pitch, zoom:sv_zoom };
		markerSvLatLng = new GLatLng(sv_lat, sv_lng);
	}
	gmarker.abbrev = abbrev;
	gmarker.title = name;
	var html = makeMarkerHTML(name, abbrev, path, id, hasStreetview);
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
				setBreadcrumbs(crumbs());
			}
			selectedMarker = null;
		}
	);
	GEvent.addListener(gmarker, "infowindowopen",
		function() {
			selectedMarker = gmarker;
			setBreadcrumbs(crumbsPlus(gmarker.title));
		}
	);
	map.addOverlay(gmarker);
	markers[abbrev] = { marker:gmarker, name:name, abbrev:abbrev, normal:regularPoint, uw:uwPoint, html:html, svPOV:markerPOV, svLatLng:markerSvLatLng };
}

function getNewStreetview() {
	streetview = new GStreetviewPanorama(streetviewDiv);
	GEvent.addListener(streetview, "error", 
		function(e) {
			if(e == 603) { //no flash available for 
				streetviewCapable = false;
				alert("This browser is incapable of powering streetview.");
				
			}
		}
	);
}

//called from gmarker's innerhtml
function viewStreetview(abbrev) {
	if(streetview == null)
		getNewStreetview();
	contentDiv.removeChild(mapDiv);
	element = markers[abbrev];
	streetview.setLocationAndPOV(element.svLatLng, element.svPOV);
	contentDiv.appendChild(streetviewDiv);
	setBreadcrumbs(crumbsPlus(element.name + " > Streetview"));
	showingStreetview = true;
}

function makeMarkerHTML(name, abbrev, path, id, streetview) {
    var picture = abbrev + ".JPG";
    var picture_path = path + "images/buildings/small/" + picture;
	var html = "<html>\n";
	html += "<b>"+name+"&nbsp;("+abbrev+")</b><br>\n";
	html += "<img src=\""+picture_path+"\" style='height:199px;width:300px;border:0;' onerror=\"this.src='"+path+"/images/poweredby300199.jpg';\"><br>\n";
	if(streetview && streetviewCapable)
		html += "<a href='#' onclick=\"viewStreetview('"+abbrev+"');\">View Streetview</a><br />\n";
	html += "<a href=\"" + path + "buildings/index?id=" + id + "\">View Building Details</a>\n";
	html += "</html>";
	return html;
}  

function streetviewData() {
	POV = streetview.getPOV();
	yaw = "sv_yaw="+POV.yaw;
	pitch = "sv_pitch="+POV.pitch;
	zoom = "sv_zoom="+POV.zoom;
	s = "UPDATE huskyschedule_development.buildings SET "+yaw+", "+pitch+", "+zoom+" WHERE abbrev = ''";
	sendtoclipboard(s);
}

function showStreetview() {
	if(!showingStreetview) {
		contentDiv.removeChild(mapDiv);
		contentDiv.appendChild(streetviewDiv);
	}
	else {
		contentDiv.removeChild(streetviewDiv);
		contentDiv.appendChild(mapDiv);
	}
	showingStreetview = !showingStreetview;
}    

//called when the selected index of the side list changes
function processSideIndexChanged(abbrev) {
	if(displayingSearchResults) {
		contentDiv.removeChild(searchResultsDiv);
		contentDiv.appendChild(mapDiv);
		displayingSearchResults = false;
		openMarker(abbrev);
	}
	else if(showingStreetview) {
		element = markers[abbrev];
		if(element.svPOV != null) {
			selectedMarker = element.marker;
			streetview.setLocationAndPOV(element.svLatLng, element.svPOV);
			setBreadcrumbs(crumbsPlus(element.name + " > Streetview"));
		}
		else {
			closeStreetview();
			openMarker(abbrev);
			contentDiv.appendChild(mapDiv);
		}
	}
	else {
		openMarker(abbrev);
	}
}

function closeStreetview() {
	contentDiv.removeChild(streetviewDiv);
	streetview.remove();
	streetview = null;
	showingStreetview = false;
}

//called when the user clicks the Map url in the breadcrumbs
function processReturnToMap() {
	if(displayingSearchResults)
		hideResultsClearSelected();
	else if(showingStreetview)
		hideStreetviewViewMap();
	else
		clearSelected();
}

function openMarker(abbrev) {
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
		searchStartDate = new Date();
		GDownloadUrl(URL+"?search_text="+searchField, 
			function(data) {
				showResults(data);
			}
		);
	}	
}

function showResults(results) {
	if(displayingSearchResults) {
		contentDiv.removeChild(searchResultsDiv);
	}
	else if(showingStreetview) {
		closeStreetview();
	} 
	else {
		map.closeInfoWindow();
		contentDiv.removeChild(mapDiv);
	}
	displayingSearchResults = true;
	setBreadcrumbs(crumbsPlus("Search Results"));
	var deltaMillis = (new Date()).getTime() - searchStartDate.getTime();
	var deltaSeconds = deltaMillis / 1000;
	results += "<br><br>Completed in " + deltaSeconds + " seconds.";
	searchResultsDiv.innerHTML = results;
	contentDiv.appendChild(searchResultsDiv);
}	

//called when the user click on a different building in the side list which doesn't have streetview data
function hideStreetviewViewMap() {
	closeStreetview();
	map.setCenter(selectedMarker.getLatLng());
	selectedMarker.openInfoWindowHtml(markers[selectedMarker.abbrev].html);
	contentDiv.appendChild(mapDiv);
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
	setBreadcrumbs(crumbs());
	displayingSearchResults = false;
	buildingsListDiv.selectedIndex = -1;
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

function setBreadcrumbs(s) {
	breadcrumbsDiv.innerHTML = s;
}

function crumbsPlus(append) {
	return crumbs() + " > " + append;
}

function crumbs() {
	return "<a href='index.html'>Home</a> > <a href='#' onclick='processReturnToMap();'>Map</a>";
}

//puts s to the clipboard, IE only
function sendtoclipboard(s) { 
	if(window.clipboardData && clipboardData.setData)
		clipboardData.setData("text", s); 
}