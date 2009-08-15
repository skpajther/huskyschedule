//GLOBAL VARIABLES
var map;
var markers; //array of marker-data objects
var selectedMarker; //the open marker
var currentMapType; //the maptype in use
var customMapType; //the custom UW map type
var icon; //icon for the markers
var uw_center; //center of UW Map
var map_center; //center of normal maps
var displayingSearchResults; //true if search results are being displayed
var mapDiv; //div that holds the map
var searchResultsDiv; //div that holds the search restuls
var contentDiv; //div that holds all the content
var buildingsListDiv; //div with all the building options
var searchStartDate; //when we started a search
var breadcrumbsDiv; //div with the breadcrumbs
var streetview; // GStreetviewPanorama
var streetviewCapable; //true if browser if capable of showing streetview
var showingStreetview; //true if we are showing streetview
var path;
//END GLOBAL VARIABLES
		
function initialize(abbrev, url) {
	if(GBrowserIsCompatible()) {
		initializeFields(path);
		prepareMap();
	 	setMinimumZoomLevels();
		mapListeners();
		path = url;
		loadMarkers(abbrev);
	}
	else {
		alert("Your browser is incompatible. Please use IE, Firefox, Chrome, Safari, or Opera.");
	}
}
		
function prepareMap() {
	map = new GMap2(mapDiv);
	map.setCenter(map_center, zoom=17); //UW campus
	map.removeMapType(G_NORMAL_MAP);
	map.setMapType(currentMapType);
	map.enableContinuousZoom();
	map.enableScrollWheelZoom();
	map.addControl(new GSmallMapControl(), new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(10,10)));
	map.addControl(new GMapTypeControl());
	customMapType = new GmapUploaderMapType(map, "http://mt.gmapuploader.com/tiles/iGp7TBqnME", "png", 5);
	map.addMapType(customMapType);
}
		
function initializeFields() {
	currentMapType = G_SATELLITE_MAP;
	map_center = new GLatLng(47.6538037015491, -122.30777084827423);
	uw_center = new GLatLng(-5.5810546875, -10.37109375);
	markers = new Array();
	makeIcon(path);
	mapDiv = document.getElementById("map");
	searchResultsDiv = document.getElementById("searchResults");
	contentDiv = document.getElementById("content");
	contentDiv.removeChild(searchResultsDiv);
	buildingsListDiv = document.getElementById("mapmenu");
	breadcrumbsDiv = document.getElementById("crumbs");
	streetviewCapable = true;
}

function setMinimumZoomLevels() {
	var mapTypes = map.getMapTypes();
	mapTypes[0].getMinimumResolution = function() { return 15; } //G_SATELLITE_MAP
	mapTypes[1].getMinimumResolution = function() { return 15; } //G_HYBRID_MAP
	mapTypes[2].getMinimumResolution = function() { return 3; }  //UW Map
}

function makeIcon() {
	icon = new GIcon();
	icon.image = path+"images/map/wlogo.gif";
	icon.transparent = path+"images/map/wlogo_onclick.png";
	icon.printImage = icon.image;
	icon.mozPrintImage = icon.image;
	icon.iconSize = new GSize(25,25);
	icon.iconAnchor = new GPoint(icon.iconSize.width/2,icon.iconSize.height / 2);
	icon.infoWindowAnchor = new GPoint(icon.iconSize.width,0);
	icon.shadowSize = new GSize(0,0);
	icon.maxHeight = 5;
}

function mapListeners() {
	GEvent.addListener(map,"maptypechanged", 
		function() {
			var newMapType = map.getCurrentMapType();
			if(newMapType == customMapType) {
				for(var i in markers) {
					markerData = markers[i];
					if(markerData.marker == null)
						break;
					markerData.marker.setLatLng(markerData.uw);
				}
				if(selectedMarker != null) {
					openMarker(selectedMarker.abbrev);
					map.setZoom(4);
				}
				else {
					map.setCenter(uw_center, zoom=4);
				}
			}
			else if(currentMapType!=G_HYBRID_MAP && currentMapType!=G_SATELLITE_MAP){
				for(var i in markers) {
					markerData = markers[i];
					if(markerData.marker == null)
						break;
					markerData.marker.setLatLng(markerData.normal);
				}
				if(selectedMarker != null) {
					map.setZoom(17);
					openMarker(selectedMarker.abbrev);
				}
				else {
					map.setCenter(map_center, zoom=17);
				}
			}
			currentMapType = newMapType;
		}
	);
	GEvent.addListener(map, "click",
		function(a,e,c) {
			//e is the GLatLng
		}
	);
}

function loadMarkers(abbrev) {
	GDownloadUrl(path+"buildings/map_loader.xml", 
		function(data) {
			data = data.split("<respond_to?:to_xml/><to_xml/>")[0];  //ignore this
			var xml = GXml.parse(data);
			data = xml.documentElement.getElementsByTagName("building"); 
			for (var i=0; i<data.length; i++)
				createMarker(data[i], path);
			if(abbrev.length > 0)
				openMarker(abbrev);
		}
	);
}

function createMarker(data) {
	var name = data.getAttribute("name");  
	var abbrev = data.getAttribute("abbrev");
	var lat = parseFloat(data.getAttribute("lat"));
	var lng = parseFloat(data.getAttribute("lng"));
	var uw_lat = parseFloat(data.getAttribute("uw_lat"));
	var uw_lng = parseFloat(data.getAttribute("uw_lng"));
	var id = parseInt(data.getAttribute("id"));
	var sv_lat = data.getAttribute("sv_lat");
	var regular_point = new GLatLng(lat,lng);
	var uw_point = new GLatLng(uw_lat,uw_lng);
	var marker = new GMarker(regular_point, {title:name});
	marker.abbrev = abbrev;
	var html = makeMarkerHTML(name, abbrev, sv_lat.length!=0, id);
	marker.bindInfoWindowHtml(html, {maxWidth:300});
	GEvent.addListener(marker, "infowindowclose", 
		function() {
			buildingsListDiv.selectedIndex = -1;
			setBreadcrumbs(crumbs());
			selectedMarker = null;
		}
	);
	GEvent.addListener(marker, "infowindowopen",
		function() {
			buildingsListDiv.selectedIndex = getOptionIndex(marker.abbrev);
			selectedMarker = marker;
			setBreadcrumbs(crumbsPlus(name));
		}
	);
	var pov = null;
	var svLatLng = null;
	if(sv_lat.length != 0) {
		sv_lat = parseFloat(sv_lat);
		var sv_lng = parseFloat(data.getAttribute("sv_lng"));
		var sv_yaw = parseFloat(data.getAttribute("sv_yaw"));
		var sv_pitch = parseFloat(data.getAttribute("sv_pitch"));
		var sv_zoom = parseInt(data.getAttribute("sv_zoom"));
		pov = {yaw:sv_yaw, pitch:sv_pitch, zoom:sv_zoom};
		svLatLng = new GLatLng(sv_lat, sv_lng);
	}
	var object = {
		marker: marker, 
		normal: regular_point, 
		uw: uw_point, 
		html: html, 
		svPOV: pov, 
		svLatLng: svLatLng
	};
	markers[abbrev] = object;
	map.addOverlay(marker);
}

function makeMarkerHTML(name, abbrev, hasStreetview, id) {
	var html = "<html><div id='markerHTML'>";
	html += "<strong>"+name+"&nbsp;("+abbrev+")</strong><br />";
    if(hasStreetview)
    	html += "<br /><a href=\"javascript:viewStreetview('"+abbrev+"');\">streetview</a>";
    html += "<br /><a href=\""+path+"buildings/index?id="+id+"\">building details</a>";
    html += "</div></html>";
    return html;
}

function viewStreetview(abbrev) {
	contentDiv.removeChild(mapDiv);
	var div = document.createElement("div");
	div.setAttribute("id","streetview");
	contentDiv.appendChild(div);
	element = markers[abbrev];
	if(streetview == null) {
		var options = { latlng:element.svLatLng, pov:element.svPOV };
		streetview = new GStreetviewPanorama(div, options);
		GEvent.addListener(streetview, "error", 
			function(e) {
				if(e == FLASH_UNAVAILABLE) { //no flash available for 
					streetviewCapable = false;
					closeStreetview();
					alert("This browser is incapable of powering streetview.");
					return;
				}
			}
		);
	}
	else {
		streetview.setLocationAndPOV(element.svLatLng, element.svPOV);
	}
	showingStreetview = true;
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
		selectedMarker = element.marker;
		if(element.svPOV != null) {
			setBreadcrumbs(crumbsPlus(element.marker.getTitle()));
			streetview.setLocationAndPOV(element.svLatLng, element.svPOV);
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
	streetview.remove();
	contentDiv.removeChild(document.getElementById("streetview"));
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
	if(currentMapType == customMapType)
		map.panTo(element.uw);
	else
		map.panTo(element.normal);
	element.marker.openInfoWindowHtml(element.html, {maxWidth:300});
}

function searchFor(searchField, URL) {
	if(searchField != "") {
		$("map_loading_gif").style.display = "inline";
		buildingsListDiv.options.selectedIndex = -1;
		searchStartDate = new Date();
		if(showingStreetview) {
			closeStreetview();
		} 
		else if(displayingSearchResults) {
			contentDiv.removeChild(searchResultsDiv);
		}
		else {
			map.closeInfoWindow();
			contentDiv.removeChild(mapDiv);
		}
		searchResultsDiv.innerHTML = "";
		contentDiv.appendChild(searchResultsDiv);
		setBreadcrumbs(crumbsPlus("Search Results"));
		displayingSearchResults = true;
		GDownloadUrl(URL+"?search_text="+searchField, 
			function(data) {
				var deltaMillis = (new Date()).getTime() - searchStartDate.getTime();
				var deltaSeconds = deltaMillis / 1000;
				data += "<br /><br />Completed in " + deltaSeconds + " seconds.";
				searchResultsDiv.innerHTML = data;
				$("map_loading_gif").style.display = "none";
			}
		);
	}	
}

function hideStreetviewViewMap() {
	closeStreetview();
	map.setCenter(selectedMarker.getLatLng());
	openMarker(selectedMarker.abbrev);
	contentDiv.appendChild(mapDiv);
} 

function hideResultsOpenMarker(abbrev) {
	contentDiv.removeChild(searchResultsDiv);
	openMarker(abbrev);
	contentDiv.appendChild(mapDiv);
	displayingSearchResults = false;
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
	if(currentMapType == customMapType)
		map.panTo(uw_center);
	else
		map.panTo(map_center);
}

function getOptionIndex(abbrev) {
	var options = buildingsListDiv.options;
	var first = 0;
   	var last = options.length;
   	while(first <= last) {
   		var mid = Math.floor((first+last) / 2); 
   		var optionValue = options[mid].value;
   		if (optionValue == abbrev)
   			return mid;
   		else if(optionValue > abbrev) 
   			last = mid-1; 
		else
    		first = mid+1;     
	}
	return -1;
}

function setBreadcrumbs(s) {
	breadcrumbsDiv.innerHTML = s;
}

function crumbsPlus(append) {
	return crumbs() + "&nbsp;>&nbsp;" + append;
}

function crumbs() {
	return "<a href='index.html'>Home</a>&nbsp;>&nbsp;<a href=\"javascript:processReturnToMap();\">Map</a>";
}

//puts s to the clipboard, IE only
function sendtoclipboard(s) { 
	if(window.clipboardData && clipboardData.setData)
		clipboardData.setData("text", s); 
}