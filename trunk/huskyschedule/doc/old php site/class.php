<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
<?php
	$firstprintln = true;
	function println($st){
		global $firstprintln;
		$File = "testlog2.txt";
		if($firstprintln){
			$Handle = fopen($File, 'w');
			$firstprintln = false;
		}
		else
			$Handle = fopen($File, 'a');
		fwrite($Handle, "$st \r\n");
		fclose($Handle); 
		
	}
?>
<style type="text/css">
<!--
body {
font-size:80%;font-family:verdana,arial,helvetica,sans-serif;color:#3a3a3a;
}
#apDiv3 {
	position:absolute;
	width:958px;
	height:397px;
	z-index:5;
	left: 3px;
	top: 95px;
	}
	
.barrow{
	background-image: url(./images/bars/bar_greybg.gif);
	background-repeat: no-repeat;
	/*background-attachment:fixed;*/
	background-position: 1px 2px;
	width:100px;
}
.newlink{color: black; text-decoration: none; border-bottom: 1px solid #999999;}
	
.newlink:hover{color: grey; text-decoration: none; border-bottom: 1px solid #FFCC00;}	

#overview {
	background-image:url(images/Tab_overview_over.jpg);
}
/*#overview:hover{
	background-image:url(images/Tab_overview_over.jpg);
}*/
#classreviews {
	background-image:url(images/Tab_classreview.jpg);
}
/*#classreviews:hover{
	background-image:url(images/Tab_classreview_over.jpg);
}*/
#teacherreviews {
	background-image:url(images/Tab_teacherreview.jpg);
}
/*#teacherreviews:hover{
	background-image:url(images/Tab_teacherreview_over.jpg);
}*/
#specifications {
	background-image:url(images/Tab_specifications.jpg);
}
/*#specifications:hover{
	background-image:url(images/Tab_specifications_over.jpg);
}*/
	
	.title{
	font-family:Arial;
	font-size:16px;
	font-weight:bold;
	}
	
	.smalltitle{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:12px;
	/*font-weight:bold;*/
	}
-->
</style>
<script src="SpryTabbedPanels.js" type="text/javascript"></script>
<link href="SpryTabbedPanels.css" rel="stylesheet" type="text/css" />
</head>

<body>
<?php 	
		$sln = $_GET['sln'];
		$connection = mysql_connect("localhost","bix","beiderbecke");
		mysql_select_db("hs_courses",$connection);
		$select = mysql_query("SELECT parent FROM classes WHERE sln=$sln",$connection);
		$row = mysql_fetch_array($select);
		$catname = $row['parent'];
		$fixedcatname = str_replace(" ","%20",$catname);
		echo(file_get_contents("http://www.infymedia.com/infy/HuskySchedule/navBar.php?catname=$fixedcatname")); 
?>
<div id="apDiv3">
  <table width="958" height="172">
<tr>
   		  <td height="36" colspan="3" valign="top"><?php 
								//$catname = $_GET["catname"];
								$familytree = array();
								//$familytree[0] = $catname;
								$connection = mysql_connect("localhost","bix","beiderbecke");
								mysql_select_db("hs_courses",$connection);
								$tmpcatname = $catname;
								$hasparent = true;
								while($hasparent){
									$result = mysql_query("SELECT parent FROM categories WHERE col_name='$tmpcatname'", $connection);
									$row=mysql_fetch_array($result);
									if(($tmpid=$row["parent"]) != ""){
										//$tmpid=$row["parent"];
										$result = mysql_query("SELECT col_name FROM categories WHERE id=$tmpid",$connection);
										$row2 = mysql_fetch_array($result);
										array_push($familytree,$row2["col_name"]);
										//echo($row2["col_name"]);
										$tmpcatname = $row2["col_name"];
									}
									else
										$hasparent = false;
								}
								$parentlist = "<a href='./home.php'>Home</a>";
								$size = count($familytree);
								for($i=0;$i<$size;$i++){
									$poped = array_pop($familytree);
									$parentlist = $parentlist . "><a href='./category.php?catname=$poped'>$poped</a>";
								}
								$parentlist = $parentlist . "><a href='./category.php?catname=$catname'>$catname</a>>SLN:" . $sln;
								echo("&nbsp;&nbsp;&nbsp;&nbsp;".$parentlist);
					?></td>
      </tr>
   	  <tr>
      	<td></td>
   	    <td height="28" colspan="2" align="left" valign="top"><?php	mysql_select_db("hs_courses",$connection);
								$select = mysql_query("SELECT * FROM classes WHERE sln=$sln");
								$cl_row = mysql_fetch_array($select);
								$title = $cl_row['title'];
								$deptabriev = $cl_row['deptabriev'];
								$number = $cl_row['number'];
								echo("<p class='title'>$deptabriev $number: $title</p>");
								
						 ?>        </td>
    </tr>
   	  <tr>
   	    <td width="37"></td>
   	    <td valign='top' width="417"><?php
			function generateSmallSchedule($row){
			
			$num = 6;
			$num2 = $num;
			$reg = ":00";
			$half = ":30";
			$whole = true;
			for($i=0;$i<28;$i++){
				$tmp = $half;
				$st = "<font size='1' face='Verdana'>&nbsp;</font>";
				if($whole){
					$tmp = $reg;
					$num++;
					$num2++;
					if($num>12)
						$num = 1;
				}
				$st = "<font size='1' face='Verdana'>".$num.$tmp."</font>";
				$t_num = $num2;
				if(!$whole)
					$t_num+=0.5;
				//println("num$t_num");
				$weekdata = getTableRow($t_num,$row);
				$schedule = $schedule."<tr height='1'>
											<td>$st</td>
											$weekdata
											</tr>";
				$whole = !$whole;
			}
			$result = "<table width='2' border='1' cellpadding='0' cellspacing='0'>
							<tr>
          <td bgcolor='#DED1ED' width='33.5' height='8'>&nbsp;</td>
          <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Mon</font></td>
          <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Tues</font></td>
          <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Wed</font></td>
          <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>Thur</font></td>
          <td bgcolor='#DED1ED' width='68.5'><font size='1' face='Verdana'>&nbsp;Fri&nbsp;</font></td>
        </tr>
			$schedule
						</table>";
			return $result;
			}
			
			function getMilitaryTimes($strtime){
				$space = 1;
				if(strlen($strtime)==5)
					$space = 2;
				$sth = intval(substr($strtime,0,$space));
				$stm = intval(substr($strtime,$space,2));
				$stampm = $strtime{2+$space};
				if(strcmp($stampm,"P")==0&&$sth!=12)
					$sth+=12;
				$tmppeek = strcmp($stampm,"P");
				if($stm==30||$stm==20)
					$sth +=0.5;
				else if($stm==50){
					if($sth!=24)
						$sth+=1;
					else
						$sth = 1;
				}
				//println("$strtime,$stampm,$sth,$stm,$tmppeek");
				return array($sth,$stm);
			}
			
			function getTableRow($num, $row){
				//println("num$num");
				$days = array("monday","tuesday","wednesday","thursday","friday");
				$ans = "";
				for($i=0;$i<5;$i++){
					$time = $row[$days[$i]];
					$found = false;
					$ignorespace = false;
					if($time!=null&&strlen($time)>=3){
						$alltimes = split(";",$time);
						//println("here1");
						for($j=0;$j<count($alltimes);$j++){
							$rawsingletime = $alltimes[$j];
							$splittimebuilding = split(",",$rawsingletime);
							$nexttime = $splittimebuilding[0];
							$tmp = split("-",$nexttime);
							$tmp2 = getMilitaryTimes($tmp[0]);
							$sth = $tmp2[0];
							$stm = $tmp2[1];
							$tmp2 = getMilitaryTimes($tmp[1]);
							$endh = $tmp2[0];
							$endm = $tmp2[1];
							
							if($num == $sth){
								$rspan = 2*($endh-$sth);
								//println("$rspan");
								$ans = $ans . "<td bgcolor='#DED1ED' rowspan=$rspan ><font size='1' face='Verdana'>&nbsp;</font></td>";
								$found = true;
							}
							elseif($num>$sth&&$num<$endh){
								//donothing
								$ignorespace = true;
							}
						}
					}
					if(!$found && !$ignorespace)
							$ans = $ans . "<td><font size='1' face='Verdana'>&nbsp;</font></td>";
				}
				return $ans;
			}
			
			function generateFavorites($row, $small=false){
				$rating = intval($row['rating']);
				$result = "";
				$i=0;
				$spnum = 32;
				if($small)
					$spnum=24;
				for(;$i<$rating;$i++){
					$result = $result . "<img src='./images/favorites-{$spnum}x{$spnum}.png'/>";
				}
				for(;$i<5;$i++){
					$result = $result . "<img src='./images/favorites-{$spnum}x{$spnum}blank.png'/>";
				}
				return $result;
			}
			
			function generateTeacherReviewSummary(){
				
			}
			
			function generateClassReviewSummary($class_name,$rowdata){
				$result = "";
				$class_name = trim($class_name);
				$con2 = mysql_connect("localhost","bix","beiderbecke");
				mysql_select_db("hs_ratings",$con2);
				$select = mysql_query("SELECT * FROM classes WHERE class_name='$class_name'",$con2);
				$row3 = mysql_fetch_array($select);
				$totalratings=mysql_num_rows($select);
				$all = array(0,0,0,0,0);
				$all[(intval($row3['rating'])-1)]++;
				//println($totalratings);
				//println($row3['rating']);
				while(($row4=mysql_fetch_array($select))!=null){
					$all[(intval($row4['rating'])-1)]++;
				}
				$bartable = "<table>";
				for($i=1;$i<6;$i++){
					$bartable.="<tr><td>$i</td><td class='barrow'>";
					$percent = intval(($all[$i-1]/$totalratings)*100);
					if($percent>0)
						$bartable.="<img src='./images/bars/bar_yellowLeft.gif'>";
					for($j=8;$j<$percent;$j++){
						$bartable.="<img src='./images/bars/bar_yellowMid.gif'>";
					}
					if($percent>0)
						$bartable.="<img src='./images/bars/bar_yellowRight.gif'>";
					$bartable.="</td><td>$percent%</td></tr>";
				}
				$bartable.="</table>";
				$starrating=generateFavorites($rowdata);
				$rating_name=$row3['rating_name'];
				$pros = $row3['pros'];
				$cons = $row3['cons'];
				$other_thoughts = $row3['other_thoughts'];
				$creator = $row3['user_name'];
				$datecreated = $row3['date_created'];
				$first_rating = generateFavorites($row3,true);
				$deptab = $rowdata['deptabriev'];
				$cl_num = $rowdata['number'];
				$result .= "<table width='100%'>
								<tr>
									<td height='1' style='border-bottom:solid 1px #999'><a class='smalltitle'><strong>Class Review Summary</strong></a>&nbsp;(<a class='newlink' href='#'>read more reviews</a>,&nbsp;<a class='newlink' href='./createclassreview.php?deptabriev=$deptab&number=$cl_num'>write a review</a>)</td>
								</tr>
								<tr>
									<td>
										<table width='100%'>
											<tr>
												<td rowspan='2'>$bartable</td>
												<td height=1 align='right' valign='center'>Class Rating:</td>
												<td width='160' align='right'>$starrating</td>
											</tr>
											<tr><td colspan='2' valign='top'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Total Reviews:$totalratings</td></tr>
										</table>
									</td>
								</tr>
								<tr>
									<td height='1' style='border-bottom:solid 1px #999'><a class='smalltitle'><strong>$rating_name</strong></a></td>
								</tr>
								<tr><td><table width='100%'><tr><td valign='top'>Reviewed By: $creator on $datecreated</td><td align='right'>$first_rating</td></tr></table></tr>
								<tr><td><strong>Pros:</strong>&nbsp;$pros<td></tr>
								<tr><td><strong>Cons:</strong>&nbsp;$cons<td></tr>
								<tr><td><strong>Other Thoughts:</strong>&nbsp;$other_thoughts</td></tr>
							</table>";
				return $result;
			}
			$result = mysql_query("SELECT * FROM classes WHERE sln=$sln", $connection);
			$row=mysql_fetch_array($result);
			$schedule = generateSmallSchedule($row);
			echo($schedule);?></td>
        <td width="488" valign="top"><div id="TabbedPanels1" class="TabbedPanels">
          <ul class="TabbedPanelsTabGroup">
            <li onclick="handleTabClicks('overview')" class="TabbedPanelsTab" id="overview" tabindex="0"><div style="width:92px; height:15px"></div></li>
            <li onclick="handleTabClicks('classreviews')" id="classreviews" class="TabbedPanelsTab" tabindex="0"><div style="width:100px; height:15px"></div></li>
            <li onclick="handleTabClicks('teacherreviews')" id="teacherreviews" class="TabbedPanelsTab" tabindex="0"><div style="width:112px; height:15px"></div></li>
            <li onclick="handleTabClicks('specifications')" id="specifications" class="TabbedPanelsTab" tabindex="0"><div style="width:104px; height:15px"></div></li>
          </ul>
          <div class="TabbedPanelsContentGroup">
            <div class="TabbedPanelsContent"><?php echo($row['description']."<br/><br/>".
														"Teacher: ".$row['teacher']."<br/>".
														$row['fillratio']."<br/>".
														generateClassReviewSummary($row['deptabriev']." ".$row['number'],$row)
														); ?>
            </div>
            <div class="TabbedPanelsContent">Content 2</div>
            <div class="TabbedPanelsContent">Content 3</div>
            <div class="TabbedPanelsContent">Content 4</div>
          </div>
        </div>        </td>
    </tr>
  </table>
</div>
  </div>
<script type="text/javascript">
var MenuBar1 = new Spry.Widget.MenuBar("MenuBar1");
var TabbedPanels1 = new Spry.Widget.TabbedPanels("TabbedPanels1");
function handleTabClicks(id){
	//alert("madeit1"+id);
	//var tab = document.getElementById(id);
	var hover = new Array("url('images/Tab_overview_over.jpg')","url('images/Tab_classreview_over.jpg')","url('images/Tab_teacherreview_over.jpg')","url('images/Tab_specifications_over.jpg')");
	var normal = new Array("url('images/Tab_overview.jpg')","url('images/Tab_classreview.jpg')","url('images/Tab_teacherreview.jpg')","url('images/Tab_specifications.jpg')");
	var ids = new Array("overview","classreviews","teacherreviews","specifications");
	//tab.style.backgroundImage=hover[ids.indexof(id)];
			for(var i=0;i<ids.length;i++){
				if(ids[i] == id)
					document.getElementById(id).style.backgroundImage=hover[i];
				else
					document.getElementById(ids[i]).style.backgroundImage=normal[i];
			}
	//tab.style.backgroundImage="url('images/Tab_overview_over.jpg')";
	//alert("madeit"+document.getElementById(id));
}
</script>
</body>
</html>
