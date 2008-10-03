<?php  require("./maps_connection_info.php"); 
	// Start XML file, create parent node
	$dom = new DOMDocument("1.0");
	$node = $dom->createElement("markers");
	$parnode = $dom->appendChild($node); 
	// Opens a connection to a MySQL server
	$connection = mysql_connect("localhost",$username,$password);
	if (!$connection) {  
		die('Not connected: '.mysql_error());
	} 
	// Set the active MySQL database
	$db_selected = mysql_select_db($database,$connection);
	if (!$db_selected) {  
		die ('Can\'t use db: '.mysql_error());
	}
	// Select all the rows in the markers table
	$query = "SELECT * FROM hs_campus_buildings";
	$result = mysql_query($query);
	if (!$result) {    
		die('Invalid query: '.mysql_error());
	} 
	header("Content-type: text/xml"); 
	// Iterate through the rows, adding XML nodes for each
	while ($row = @mysql_fetch_assoc($result)) {    
		// ADD TO XML DOCUMENT NODE    
		$node = $dom->createElement("marker");    
		$newnode = $parnode->appendChild($node);     
		$newnode->setAttribute("name",$row['name']);  
		$newnode->setAttribute("lat", $row['lat']);    
		$newnode->setAttribute("lng", $row['lng']); 
		$newnode->setAttribute("picture", $row['picture']);
		$newnode->setAttribute("abbreviation", $row['abbrev']);
		$newnode->setAttribute("uw_lat", $row['uw_lat']);
		$newnode->setAttribute("uw_lng", $row['uw_lng']);
	} 
	if($_GET["show"] != NULL) {
		$node = $dom->createElement("panTo");
		$newnode = $parnode->appendChild($node);
		$newnode->setAttribute("show", $_GET["show"]);
	}
	echo $dom->saveXML();
	
?>