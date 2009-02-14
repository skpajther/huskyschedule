//GLOBAL VARIABLES
var map;
var markers;
var selectedMarker;
var currentMapType;
var icon;
var uw_center;
var center;
var displayCenter;
var width;
var height;
var opening;
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
		alert("Your browser is incompatible. Please use IE, Firefox, Chrome, or if nothing else, Safari.");
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
	opening = false;
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
			  	map.setCenter(center, 17);
				for(i in markers) {
					markerData = markers[i];
					markerData.marker.setLatLng(markerData.normal);
				}
			}
			else if(!(newMapType==G_HYBRID_MAP || newMapType==G_SATELLITE_MAP)) { //custom
				map.setCenter(uw_center, 4);
				for(i in markers) {
					markerData = markers[i];
					markerData.marker.setLatLng(markerData.uw);
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
	gmarker.title = abbrev;
	var html = makeMarkerHTML(name, abbrev, path);
	gmarker.bindInfoWindowHtml(html);
	GEvent.addListener(gmarker, "click", 
		function(e) {
			var options = document.getElementById("mapmenu").options;
	       	var first = 0;
	       	var last = options.length;
	       	var mid = 0;
	       	while(first <= last) {
	       		mid = Math.floor((first + last) / 2); 
	       		var optionValue = options[mid].value;
	       		if (optionValue == gmarker.title)
           			break;
           		else if(optionValue > gmarker.title) 
           			last = mid - 1; 
       			else
           			first = mid + 1;     
   			}
   			document.getElementById("mapmenu").selectedIndex = mid;
		}
	);
	GEvent.addListener(gmarker, "infowindowclose", 
		function() {
			if(!opening)
				document.getElementById("mapmenu").selectedIndex = -1;
			selectedMarker = null;
		}
	);
	GEvent.addListener(gmarker, "infowindowopen",
		function() {
			selectedMarker = gmarker;
		}
	);
	map.addOverlay(gmarker);
	markers[abbrev] = {marker:gmarker, name:name, abbrev:abbrev, normal:regularPoint, uw:uwPoint, html:html};
}

function makeMarkerHTML(name, abbrev, path) {
    var picture = abbrev + ".JPG";
	var html = "<html>\n";
	html += "<b>"+name+"&nbsp;("+abbrev+")</b><br>\n";
	html += "<div style='height:210px;width:300px;'>";
	if(picture.length > 0) {
		var picture_path = path+"images/buildings/small/" + picture;
		html += "<img src=\""+picture_path+"\" width=\"300\" height\"199\" border=\"0\"><br>\n";
	}
	html += "</div>\n</html>";
	return html;
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

function clearSelected() {
	map.closeInfoWindow();
	if(currentMapType == G_HYBRID_MAP || currentMapType == G_SATELLITE_MAP)
		map.panTo(center);
	else
		map.panTo(uw_center);
}