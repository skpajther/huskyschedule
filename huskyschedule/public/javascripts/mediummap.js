//GLOBAL VARIABLES
var map;
var currentMapType;
var markers;
var selectedMarker;
var uw_center; //center of UW Map
var center; //center of G_SATELLITE_MAP & G_HYBRID_MAP
var icon;
var set;
//END GLOBAL VARIABLES

function initMediumMap(path) {
	if(GBrowserIsCompatible()) {
		initializeMMapFields(path);
		prepareMediumMap();
		map.setCenter(center, 17);
		setMinimumZoomLevels();
		mapListeners();
	 	var ids = arguments[1];
	 	for(var i=2; i<arguments.length; i++) {
	 		ids += ","+arguments[i];	
		}
		loadMarkers(path, ids);
	}
	else {
		alert("Your browser is incompatible. Please use IE, Firefox, Chrome, Safari, or Opera.");
	}
}

function prepareMediumMap() {
	map = new GMap2(document.getElementById("mediumMap"));
	map.addMapType(G_SATELLITE_MAP);
	map.addMapType(G_HYBRID_MAP);
	map.removeMapType(G_NORMAL_MAP);
	map.setMapType(currentMapType);
	map.enableContinuousZoom();
	map.enableScrollWheelZoom();
	map.addControl(new GSmallMapControl(), new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(10, 10)));
	var customMapType = new GmapUploaderMapType(map, "http://mt.gmapuploader.com/tiles/iGp7TBqnME", "png", 5);
	map.addMapType(customMapType);
	map.addControl(new GMapTypeControl());
}

function initializeMMapFields(path) {
	icon = makeIcon(path);
	currentMapType = G_SATELLITE_MAP;
	center = new GLatLng(47.6538037015491, -122.30777084827423);
	uw_center = new GLatLng(-5.5810546875, -10.37109375);
	markers = new Array();
	set = false;
}

function makeIcon(path) {
	var iconT = new GIcon();
	iconT.image = path+"images/map/wlogo.gif";
	iconT.transparent = path+"images/map/wlogo_onclick.png";
	iconT.printImage = iconT.image;
	iconT.mozPrintImage = iconT.image;
	iconT.iconSize = new GSize(25,25);
	iconT.iconAnchor = new GPoint(0,iconT.iconSize.height / 2);
	iconT.infoWindowAnchor = new GPoint(iconT.iconSize.width,0);
	iconT.shadowSize = new GSize(0,0);
	iconT.maxHeight = 5;
	return iconT;
}

function setMinimumZoomLevels() {
	var mapTypes = map.getMapTypes();
	mapTypes[0].getMinimumResolution = function() { return 15; } //G_SATELLITE_MAP
	mapTypes[1].getMinimumResolution = function() { return 15; } //G_HYBRID_MAP
	mapTypes[2].getMinimumResolution = function() { return 3; }  //UW Map
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
}

function loadMarkers(path, ids) {
	GDownloadUrl(path+"buildings/map_loader.xml?find_multi="+ids, 
		function(data) {
			data = data.split("<respond_to?:to_xml/><to_xml/>")[0];  //remove this crap
			var xml = GXml.parse(data);
			var data = xml.documentElement.getElementsByTagName("building");
			for (var i=0; i<data.length; i++)
				createMarker(data[i], path);
		}
	);
}

function openMarker(abbrev) {
	element = markers[abbrev];
	if(currentMapType == G_SATELLITE_MAP || currentMapType == G_HYBRID_MAP)
		map.panTo(element.normal);
	else //UW Map
		map.panTo(element.uw);
	element.marker.openInfoWindowHtml(element.html);
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
	map.setCenter(regularPoint, 17);
	var gmarker = new GMarker(regularPoint, icon);
	gmarker.abbrev = abbrev;
	gmarker.title = name;
	var html = makeMarkerHTML(name, abbrev, path, id);
	gmarker.bindInfoWindowHtml(html);
	GEvent.addListener(gmarker, "infowindowclose", 
		function() {
			selectedMarker = null;
		}
	);
	GEvent.addListener(gmarker, "infowindowopen",
		function() {
			selectedMarker = gmarker;
		}
	);
	map.addOverlay(gmarker);
	if(!set) {
		map.setCenter(regularPoint, 17);
		set = true;
	}
	markers[abbrev] = { marker:gmarker, name:name, abbrev:abbrev, normal:regularPoint, uw:uwPoint, html:html };
}

function makeMarkerHTML(name, abbrev, path, id) {
	var picture = abbrev + ".JPG";
    var picture_path = path + "images/buildings/small/" + picture;
    var html = "<html>\n";
	html += "<strong>"+name+"&nbsp;("+abbrev+")</strong><br>\n";
	html += "<img src=\""+picture_path+"\" style='height:199px;width:300px;border:0;' onerror=\"this.src='"+path+"/images/poweredby300199.jpg';\"><br>\n";
	html += "<a href=\""+path+"buildings/map?id="+id+"\">View in full map</a><br>\n";
	html += "</html>";
	return html;
}