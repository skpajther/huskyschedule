<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Campus Map | HuskySchedule</title>
<?php
	$firstprintln = true;
	function println($st){
		global $firstprintln;
		$File = "testlog.txt";
		if($firstprintln){
			$Handle = fopen($File, 'w');
			$firstprintln = false;
		}
		else
			$Handle = fopen($File, 'a');
		fwrite($Handle, "$st \r\n");
		fclose($Handle); 
	}
	$selected;
	if($_GET["show"] != NULL)
		$selected = $_GET["show"];
	else
		$selected = "";
?>
<style type="text/css">
   	body {
		font-size:80%;font-family:verdana,arial,helvetica,sans-serif;color:#3a3a3a;
	}
	table{
		font-size:100%;
	}
	#side {
		position:absolute;
		width:160px;;
		height:80px;
		left:37px;
		z-index:5;
		left: 3px;
		top: 95px;
	}
	#mainSection {
		width:790px;
		height:1000px;
		position:absolute;
		left:170px;;
		top:115px;
	}
	#footer {
		cursor:pointer;
		top:1100px;
		position:absolute;
		left:300px;
	}
	#map {
		width:780px;
		height:600px;
	}
	#crumbs {
		top:95px;
		left: 170px;
		position:absolute;
		width: 791px;
	}
	#coordinates {
		position:absolute;
		width:600px;
		text-align:left;
		top:95px;
		left:350px;
	}
	#sideTable {
		width:160px;
		position:absolute;
		cursor:default;
	}
	#searchWithin {
		top:90px;
		left:760px;
		position:absolute;
	}
	*.building_marker_opener {	
		cursor:pointer;
	}
	#searchGoButton {
		cursor:pointer;
	}
	*.customLink {
		text-decoration:none;
		color:black;
	}
</style>
<script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAASuQu2CS4gyV_0PBMtAhQmxTq2hRdhlyrxqNJP-kbJ_LGz2xTAhQmIySyY5okdypVbzAsga6vQ_niZw" type="text/javascript">
	</script>
    <script src="./gmapuploader.js" type="text/javascript"></script>
	<script type="text/javascript">
		
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
			document.getElementById("map").style.backgroundColor = 'white';
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
			var selected = "<?php echo $selected; ?>"
			var url = "./map_loader.php";
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
		
		function cleanText(text) {
			if(text.match(/&/)) {
				text.replace(/&/,"_AMP_");
			}
			return text;
		}
		
		function searchForBuilding(text) {
			text = cleanText(text);
			window.location.href = "./map.php?find=" + text;
		}
	
	</script>
</head>
<?php 	
   	echo(file_get_contents("http://www.infymedia.com/infy/HuskySchedule/navBar.php"));
	$connection = mysql_connect("localhost","mapper","mapgetter");
	mysql_select_db("hs_map",$connection);
?>
<body onLoad="initialize()" onUnload="GUnload();">
	<div id="mainSection">
    	<table id="mainTable" cellspacing="0" cellpadding="0">
			<?php
                global $connection;
				$searching;
                if($_GET["find"] != NULL) {
					$searching = true;
                    $text = $_GET["find"];
                    $query = mysql_query("SELECT name,abbrev FROM hs_campus_buildings WHERE abbrev LIKE '%$text%' OR name LIKE '%$text%' ORDER BY abbrev",$connection);
                    $results = array();
                    while($result = mysql_fetch_array($query,$connection))
                        array_push($results, $result["name"], $result["abbrev"]);
                    $count = count($results);
                    if($count == 0) {
                        //say no results found
                    }
                    else {
                        echo "<tr>\n";
                        echo "\t\t\t<td colspan='2'>&nbsp;&nbsp;".($count/2)." match".($count > 2 ? "es":"")." found:\n";
                        echo "\t\t\t\t<ul>\n";
                        for($i=0; $i<$count; $i+=2) {
							$abr = $results[$i+1];
							$str = $results[$i]." (".$abr.")";
                            echo "\t\t\t\t\t<li><a href='./map.php?show=$abr'>$str</a></li>\n";
                        }
                        echo "\t\t\t\t</ul>\n";
                        echo "\t\t\t</td>\n";
                        echo "\t\t</tr>\n";
						echo "\t\t<tr>\n";
						echo "\t\t\t<td><a href='./map.php'>Return to map</a></td>\n";
						echo "\t\t</tr>\n";
                    }
                } 
				else {
					$searching = false;
	                echo "\t\t<tr>\n";
    	            echo "\t\t\t<td colspan='2'><div id='map'></div></td>\n";
        	        echo "\t\t</tr>\n";
				}
            ?>
        </table>
    </div>
	<div id="side">
    	<table id="sideTable" border="0" cellpadding="3" cellspacing="0" bgcolor="#DED1ED" vspace="0">
         	<tr>
            	<td valign="top" bgcolor="#412164"><b><font color="#ffffff">Campus Map</font></b></td>
            </tr>
            <?php 
				global $connection;
				$query = mysql_query("SELECT name,abbrev FROM hs_campus_buildings ORDER BY name",$connection);
				while($result = mysql_fetch_array($query,$connection)) {
					$name = $result["name"];
					$abbrev = $result["abbrev"];
					echo "\t\t\t<tr>\n";
					if($searching)
						echo "\t\t\t\t<td valign='top' bgcolor='#DED1ED'><a href='./map.php?show=$abbrev' class='customLink'>$name&nbsp;($abbrev)</a></td>\n";
					else
						echo "\t\t\t\t<td valign='top' class='building_marker_opener' bgcolor='#DED1ED' onclick='openMarker(\"$abbrev\");'>$name&nbsp;($abbrev)</td>\n";
					echo "\t\t\t</tr>\n";
				}
				?>
        </table>
    </div>
    <div id="crumbs">
		<?php 
			if($searching) 
				echo "<a href='./map.php'>Map</a>>Search Results";
			else
				echo "Map";
		?>
	</div>
	<div id="coordinates"></div>
    <div id="searchWithin">
    	<input name="textsearchwithin" 
        	   type="text" 
               id="textsearchwithin" 
               value="Search Map" 
               onFocus="if(this.value == 'Search Map') { this.value=''; }" 
               onBlur="if(this.value == '') { this.value='Search Map'; }" 
               onKeyDown="var val = this.value; if(!(val=='' || val=='Search Map') && event.keyCode == 13) { searchForBuilding(val); }">
        <img src='images/gobutton.png' align="texttop" id='searchGoButton' onclick="var val = document.getElementById('textsearchwithin').value; if(!(val=='' || val=='Search Map')) { searchForBuilding(val); }" />
    </div>
    <div id="footer"><img src="images/poweredby290.jpg" onclick="window.location.href = 'http://www.infymedia.com/';"></div>
</body>
</html>
