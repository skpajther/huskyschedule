//GLOBAL VARIABLES
var map;
var markerWrapper;
var currentMapType;
var customMapType;
var markerOpen;
//END GLOBAL VARIABLES

function initialize(path, buildingID) {
	if(GBrowserIsCompatible()) {
		prepareMap();
 		setMinimumZoomLevels();
	 	mapListeners();
		loadMarker(path, buildingID);
	}
	else {
		alert("Your browser is incompatible. Please use IE, Firefox, Chrome, Safari, or Opera.");
	}
}

function prepareMap() {
	map = new GMap2(document.getElementById("minimap"));
	map.addMapType(G_SATELLITE_MAP);
	map.addMapType(G_HYBRID_MAP);
	map.removeMapType(G_NORMAL_MAP);
	currentMapType = G_SATELLITE_MAP;
	map.setMapType(currentMapType);
	map.enableContinuousZoom();
	map.enableScrollWheelZoom();
	map.addControl(new GSmallMapControl(), new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(5, 5)));
	customMapType = new GmapUploaderMapType(map, "http://mt.gmapuploader.com/tiles/iGp7TBqnME", "png", 5);
	map.addMapType(customMapType);
	map.addControl(new GMapTypeControl());
}

function setMinimumZoomLevels() {
	var mapTypes = map.getMapTypes();
	mapTypes[0].getMinimumResolution = function() { return 15; } //G_SATELLITE_MAP
	mapTypes[1].getMinimumResolution = function() { return 15; } //G_HYBRID_MAP
	mapTypes[2].getMinimumResolution = function() { return 3; }  //UW Map
}

function makeIcon(path) {
	var icon = new GIcon();
	icon.image = path+"images/map/wlogo.gif";
	icon.transparent = path+"images/map/wlogo_onclick.png";
	icon.printImage = icon.image;
	icon.mozPrintImage = icon.image;
	icon.iconSize = new GSize(25,25);
	icon.iconAnchor = new GPoint(0,icon.iconSize.height / 2);
	icon.infoWindowAnchor = new GPoint(icon.iconSize.width,0);
	icon.shadowSize = new GSize(0,0);
	icon.maxHeight = 5;
	return icon;
}

function mapListeners() {
	GEvent.addListener(map,"maptypechanged", 
		function() {
			var newMapType = map.getCurrentMapType();
			if(newMapType == customMapType) {
			  	markerWrapper.marker.setLatLng(markerWrapper.uw);
				map.setCenter(markerWrapper.uw, zoom=4);
				if(markerOpen) {
					map.setZoom(4);
					markerWrapper.marker.openInfoWindowHtml(markerWrapper.html, {maxWidth:200});
				}
			}
			else if(currentMapType!=G_HYBRID_MAP && currentMapType!=G_SATELLITE_MAP) {
				markerWrapper.marker.setLatLng(markerWrapper.normal);
			  	map.setCenter(markerWrapper.normal, zoom=17);
				if(markerOpen) {
					map.setZoom(17);
					markerWrapper.marker.openInfoWindowHtml(markerWrapper.html, {maxWidth:200});
				}
			}
			currentMapType = newMapType;
		}
	);	
}

function loadMarker(path, buildingID) {
	GDownloadUrl(path+"buildings/map_loader.xml?id="+buildingID, 
		function(data) {
			data = data.split("<respond_to?:to_xml/><to_xml/>")[0];  //remove this crap
			var xml = GXml.parse(data);
			var data = xml.documentElement.getElementsByTagName("building"); 
			createMarker(data[0], path);
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
	var id = parseInt(data.getAttribute("id"));
	map.setCenter(regularPoint, zoom=17);
	var gmarker = new GMarker(regularPoint, {title:name});
	gmarker.abbrev = abbrev;
	var html = makeMarkerHTML(name, abbrev, path, id);
	gmarker.bindInfoWindowHtml(html, {maxWidth:200});
	GEvent.addListener(gmarker, "infowindowclose", 
		function() { markerOpen = false; }
	);
	GEvent.addListener(gmarker, "infowindowopen",
		function() { markerOpen = true; }
	);
	map.addOverlay(gmarker);
	markerWrapper = { marker:gmarker, abbrev:abbrev, normal:regularPoint, uw:uwPoint, html:html };
}

function makeMarkerHTML(name, abbrev, path, id) {
	var html = "<html><div id='markerHTML'>";
	html += "<strong>"+name+"&nbsp;("+abbrev+")</strong><br />";
    html += "<br /><a href=\""+path+"buildings/map?id="+id+"\">return to map</a>";
    html += "</div></html>";
    return html;
}