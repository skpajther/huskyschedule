//GLOBAL VARIABLES
var map;
var markers;
var currentMapType;
var smallMapControl;
var icon;
var uw_center;
var center;
var selectedMarker;
//END GLOBAL VARIABLES
		
function initialize() {
	 if(GBrowserIsCompatible()) {
	 	initializeFields();
	 	mapListeners();
		loadMarkers();
	}
}
		
function prepareMap() {
	map = new GMap2(document.getElementById("map"));
	map.setCenter(center, 16); //UW campus
	map.addMapType(G_SATELLITE_MAP);
	map.addMapType(G_HYBRID_MAP);
	map.removeMapType(G_NORMAL_MAP);
	map.setMapType(currentMapType);
	map.enableContinuousZoom();
	map.enableScrollWheelZoom();
	map.addControl(smallMapControl, new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(10, 10)));
	map.addControl(new GMapTypeControl());
	//document.getElementById("map").style.backgroundColor = 'white';
	var customMapType = new GmapUploaderMapType(map, "http://mt.gmapuploader.com/tiles/iGp7TBqnME", "png", 5);
	map.addMapType(customMapType);
}
		
function initializeFields() {
	currentMapType = G_SATELLITE_MAP;
	center = new GLatLng(47.6544,-122.3080);
	uw_center = new GLatLng(1.93359375,-5.2734375);
	smallMapControl = new GSmallMapControl();
	prepareMap();
	markers = new Array();
	makeIcon();
}

function makeIcon() {
	icon = new GIcon();
	icon.image = "./images/maps/wlogo.gif";
	icon.transparent = "./images/maps/wlogo_onclick.png";
	icon.printImage = icon.image;
	icon.mozPrintImage = icon.image;
	icon.iconSize = new GSize(25,25);
	icon.iconAnchor = new GPoint(0,icon.iconSize.height / 2);
	icon.infoWindowAnchor = new GPoint(icon.iconSize.width,0);
	icon.shadowSize = new GSize(0,0);
	icon.maxHeight = 5;
}

function mapListeners() {
	GEvent.addListener(map,"click", 
		function(a,c){
                  document.getElementById("coordinates").innerHTML = c.lat()+", "+c.lng();
			document.getElementById("textsearchwithin").blur();   
   			}
	);
	GEvent.addListener(map,"maptypechanged", 
		function(e) {
			var newMapType = map.getCurrentMapType();
			if((newMapType==G_HYBRID_MAP || newMapType==G_SATELLITE_MAP)&&
			  !(currentMapType==G_HYBRID_MAP || currentMapType==G_SATELLITE_MAP)) {
				currentMapType = newMapType;
				map.enableScrollWheelZoom();
				map.setCenter(center, 17); //UW campus
				map.addControl(smallMapControl,new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(10, 10)));
				for(var i=0; i<markers.length; i++) {
					var markerData = markers[i];
					markerData.marker.setLatLng(markerData.normal);
				}
			}
			else if(!(newMapType==G_HYBRID_MAP || newMapType==G_SATELLITE_MAP)) { //custom
				currentMapType = newMapType;
				map.disableScrollWheelZoom();
				map.setCenter(uw_center, 4); //middle of UW map
				map.removeControl(smallMapControl);
				for(var i=0; i<markers.length; i++) {
					var markerData = markers[i];
					markerData.marker.setLatLng(markerData.uw);
				}
			}
		}
	);
}
		
function loadMarkers() {
	//var selected = ""
	//var url = "http://www.huskyschedule.com/infy/huskyschedule/map_loader.php";
	if(selected.length > 0)
		url += "?show="+selected;
	GDownloadUrl(url, 
		function(data) {  
			var xml = GXml.parse(data);  
			var data = xml.documentElement.getElementsByTagName("marker"); 
			for (var i=0; i<data.length; i++)
				createMarker(data[i]);
			if(selected.length > 0) {
				var show = xml.documentElement.getElementsByTagName("panTo");
				openMarker(show[0].getAttribute("show"));
			}
		}
	);
}

function createMarker(data) {
	var name = data.getAttribute("name");  
	var lat = data.getAttribute("lat");
	var lng = data.getAttribute("lng");
	var uw_lat = data.getAttribute("uw_lat");
	var uw_lng = data.getAttribute("uw_lng");
	var regularPoint = new GLatLng(lat,lng);
	var uwPoint = new GLatLng(uw_lat,uw_lng);
	var gmarker = new GMarker(regularPoint, icon);
	var abbreviation = data.getAttribute("abbreviation");
	gmarker.title = name;
	var html = makeMarkerHTML(name, data, abbreviation)
	gmarker.bindInfoWindowHtml(html);
	GEvent.addListener(gmarker,"infowindowopen",
		function() { 
	selectedMarker = gmarker;
			document.getElementById("crumbs").innerHTML = "<font style='text-decoration:underline; color:blue; cursor:pointer;' onclick='clearSelected();'>Map</font>>"+name;
		}
	);
	GEvent.addListener(gmarker,"infowindowclose",
		function() {
			document.getElementById("crumbs").innerHTML = "Map";
		}
	);
	map.addOverlay(gmarker);
	markers.push( {marker:gmarker, name:name, abbrev:abbreviation, normal:regularPoint, uw:uwPoint, html:html} );
}

function makeMarkerHTML(name, data, abbreviation) {
	var picture = data.getAttribute("picture");
	var html = "<html>\n";
	html += "\t<b>"+name+"&nbsp;("+abbreviation+")</b><br>\n";
	if(picture.length > 0) {
		var picture_path = "./images/maps/building_pictures/" + picture;
		var large_picture_path = "./images/maps/building_pictures_large/" + picture;
		html += "\t<center><a href=\""+large_picture_path+"\" target=\"_blank\"><img src=\""+picture_path+"\" width=\"300\" height\"199\" border=\"0\"></a></center><br>\n";
	}
	html += "\t<a href=\"./building.php?building="+abbreviation+"\"><font style='color:blue; text-decoration:underline;'>View more info</font></a>&nbsp;<b><font style='color:red;'>New!</font></b><br><br>\n";
	html += "\t<center><img src=\"./images/poweredby290.jpg\" width=\"190\" height=\"30\" /></center>\n";
	html += "</html>";
	return html;
}       

function openMarker(given_abbrev) {
	for(var i=0; i<markers.length; i++) {
		var m = markers[i];
		if(m.abbrev == given_abbrev) {
			document.getElementById("crumbs").innerHTML = "<font style='text-decoration:underline; color:darkblue; cursor:pointer;' onclick='clearSelected();'>Map</font>>"+m.name;
			if(currentMapType == G_SATELLITE_MAP || currentMapType == G_HYBRID_MAP)
				map.panTo(m.normal);
			else //custon
				map.panTo(m.uw);
			m.marker.openInfoWindowHtml(m.html);
			selectedMarker = m.marker;
			break;
		}
	}
} 

function clearSelected() {
	selectedMarker.closeInfoWindow();
	selectedMarker = null;
	document.getElementById("crumbs").innerHTML = "Map";
	if(currentMapType == G_HYBRID_MAP || currentMapType == G_SATELLITE_MAP)
		map.panTo(center);
	else
		map.panTo(uw_center);
}