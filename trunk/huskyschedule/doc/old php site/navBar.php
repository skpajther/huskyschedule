<style type="text/css">

#apDiv1 {
	position:absolute;
	width:1009px;
	height:84px;
	z-index:1;
	left:37px;
	top:5px;
}
#apDiv2 {
	position:absolute;
	width:212px;
	height:29px;
	z-index:4;
	left: 103px;
	top: 26px;
}

#apDiv4 {
	position:absolute;
	width:974px;
	height:347px;
	z-index:3;
	left: 38px;
	top: 5px;
}

	<?php 	$catname = $_GET['catname'];
			$tohighlight = highlightCategory();?>
	
	<?php if(strcmp($tohighlight,"Arts and Sciences")==0)
			echo("#artssciences{background-image:url(images/Cat_over_artscience.jpg);}");
		  else
		  	echo("#artssciences{background-image:url(images/Cat_artscience.jpg);}");	
	?>
	#artssciences:hover{background-image:url(images/Cat_over_artscience.jpg);}
	#artssciences{width:81px}
	#artssciences{height:12px}
	
	<?php if(strcmp($tohighlight,"Engineering")==0)
			echo("#engineering{background-image:url(images/Cat_over_engineering.jpg);}");
		  else
		  	echo("#engineering{background-image:url(images/Cat_engineering.jpg);}");	
	?>
	#engineering:hover{background-image:url(images/Cat_over_engineering.jpg);}
	#engineering{width:57px}
	#engineering{height:12px}
	
	<?php if(strcmp($tohighlight,"Business")==0)
			echo("#business{background-image:url(images/Cat_over_business.jpg);}");
		  else
		  	echo("#business{background-image:url(images/Cat_business.jpg);}");	
	?>
	#business:hover{background-image:url(images/Cat_over_business.jpg);}
	#business{width:41px}
	#business{height:12px}
	
	<?php if(strcmp($tohighlight,"Law")==0)
			echo("#law{background-image:url(images/Cat_over_law.jpg);}");
		  else
		  	echo("#law{background-image:url(images/Cat_law.jpg);}");	
	?>
	#law:hover{background-image:url(images/Cat_over_law.jpg);}
	#law{width:13px}
	#law{height:12px}
	
	<?php if(strcmp($tohighlight,"Medicine")==0)
			echo("#medicine{background-image:url(images/Cat_over_medicine.jpg);}");
		  else
		  	echo("#medicine{background-image:url(images/Cat_medicine.jpg);}");	
	?>
	#medicine:hover{background-image:url(images/Cat_over_medicine.jpg);}
	#medicine{width:40px}
	#medicine{height:12px}
	
	<?php if(strcmp($tohighlight,"Dentistry")==0)
			echo("#dentist{background-image:url(images/Cat_over_dentist.jpg);}");
		  else
		  	echo("#dentist{background-image:url(images/Cat_dentist.jpg);}");	
	?>
	#dentist:hover{background-image:url(images/Cat_over_dentist.jpg);}
	#dentist{width:53px}
	#dentist{height:12px}
	
	<?php if(strcmp($tohighlight,"Architecture")==0)
			echo("#arch{background-image:url(images/Cat_over_arch.jpg);}");
		  else
		  	echo("#arch{background-image:url(images/Cat_arch.jpg);}");	
	?>
	#arch:hover{background-image:url(images/Cat_over_arch.jpg);}
	#arch{width:62px}
	#arch{height:12px}
	
	<?php if(strcmp($tohighlight,"Education")==0)
			echo("#edu{background-image:url(images/Cat_over_edu.jpg);}");
		  else
		  	echo("#edu{background-image:url(images/Cat_edu.jpg);}");	
	?>
	#edu:hover{background-image:url(images/Cat_over_edu.jpg);}
	#edu{width:44px}
	#edu{height:12px}
	
	<?php if(strcmp($tohighlight,"Forest Resources")==0)
			echo("#forest{background-image:url(images/Cat_over_forest.jpg);}");
		  else
		  	echo("#forest{background-image:url(images/Cat_forest.jpg);}");	
	?>
	#forest:hover{background-image:url(images/Cat_over_forest.jpg);}
	#forest{width:83px}
	#forest{height:12px}
	
	<?php if(strcmp($tohighlight,"Information School")==0)
			echo("#info{background-image:url(images/Cat_over_info.jpg);}");
		  else
		  	echo("#info{background-image:url(images/Cat_info.jpg);}");	
	?>
	#info:hover{background-image:url(images/Cat_over_info.jpg);}
	#info{width:94px}
	#info{height:12px}
	
	<?php if(strcmp($tohighlight,"Nursing")==0)
			echo("#nurse{background-image:url(images/Cat_over_nurse.jpg);}");
		  else
		  	echo("#nurse{background-image:url(images/Cat_nurse.jpg);}");	
	?>
	#nurse:hover{background-image:url(images/Cat_over_nurse.jpg);}
	#nurse{width:34px}
	#nurse{height:12px}
	
	<?php if(strcmp($tohighlight,"Fishery Sciences")==0)
			echo("#fish{background-image:url(images/Cat_over_fish.jpg);}");
		  else
		  	echo("#fish{background-image:url(images/Cat_fish.jpg);}");	
	?>
	#fish:hover{background-image:url(images/Cat_over_fish.jpg);}
	#fish{width:83px}
	#fish{height:12px}
	
	<?php if(strcmp($tohighlight,"Other")==0)
			echo("#other{background-image:url(images/Cat_over_other.jpg);}");
		  else
		  	echo("#other{background-image:url(images/Cat_other.jpg);}");	
	?>
	#other:hover{background-image:url(images/Cat_over_other.jpg);}
	#other{width:23px}
	#other{height:12px}
</style>
<script src="SpryAssets/SpryMenuBar.js" type="text/javascript">;</script>
<link href="SpryAssets/SpryMenuBarHorizontal.css" rel="stylesheet" type="text/css" />


<div id="apDiv2">
  <input type="text" name="search" id="search" />  
  <img src="images/gobutton.png" alt="gobutton" width="42" height="18" />
</div>
<div id="apDiv4">
	<?php
		$rows = array();
		$connection = mysql_connect("localhost","bix","beiderbecke");
		mysql_select_db("hs_courses",$connection);
		$result = mysql_query("SELECT children FROM categories WHERE id BETWEEN 1 and 13", $connection);
		$k=0;
			while($row=mysql_fetch_array($result)){
				$result1 = mysql_query("SELECT col_name FROM categories Where id IN (".$row['children'].")", $connection);
				while($rows2=mysql_fetch_array($result1)){
					$names = $names.",;,".$rows2["col_name"];
				}
				$rows[$k++]=$names;
				$names = "";
			}
			
			function highlightCategory(){
				//$catname = $_GET["catname"];
				global $catname;
				global $connection;
				if($connection==null){
					$connection = mysql_connect("localhost","bix","beiderbecke");
					mysql_select_db("hs_courses",$connection);
				}
				$stoploop = false;
				$getans = mysql_query("SELECT * FROM categories WHERE col_name='$catname'",$connection);
				$row = mysql_fetch_array($getans);
				while(!$stoploop){
					if(intval($row['id'])<=13)
						return $row['col_name'];
					$par=$row['parent'];
					if($par!=null&&$par!=""){
						$getans = mysql_query("SELECT * FROM categories WHERE id=$par",$connection);
						$row = mysql_fetch_array($getans);
					}else
						return "error on page";
				}
				return $row['col_name'];	
			}
			
			function getCatType($Icol_name){
				global $connection;
				$getans = mysql_query("SELECT children FROM categories WHERE col_name='$Icol_name'",$connection);
				$srow = mysql_fetch_array($getans);
				if($srow["children"]=="")
					return "subcategory";
				else
					return "category";
			}
			
			function getInnerHTMLForMB1($num){
				global $rows;
				$output = "<ul>\n";
				$subcats = split(",;,",$rows[$num]);
				if(1<count($subcats)){
					for($j=1;$j<count($subcats);$j++){
						$cattype = getCatType($subcats[$j]);
						$output = $output . "\t<li><a href='./$cattype.php?catname=$subcats[$j]'>" . $subcats[$j] . "</a></lin";
					}
					$output = $output . "</ul>\n";
					return $output;
				}
				return "";
			}
	?>
  <table width="958" height="81" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="1007" height="54"><img src="./images/topbar.jpg" alt="topbar" width="956" height="54" /></td>
    </tr>
    <tr>
      <td height="27"><ul id="MenuBar1" class="MenuBarHorizontal">
          <li id="mb11"><a id="artssciences" class="MenuBarItemSubmenu" href="./category.php?catname=Arts and Sciences"></a>
              <ul>
                <li><a href="#">Item 1.1</a></li>
                <li><a href="#">Item 1.2</a></li>
                <li><a href="#">Item 1.3</a></li>
              </ul>
          </li>
        <li id="mb12"><a href="./category.php?catname=Engineering" class="MenuBarItemSubmenu" id="engineering"></a><?php echo(getInnerHTMLForMB1(1)); ?></li>
        <li id="mb13"><a href="./category.php?catname=Business" class="MenuBarItemSubmenu" id="business"></a><?php echo(getInnerHTMLForMB1(2)); ?></li>
        <li id="mb14"><a href="./category.php?catname=Law" class="MenuBarItemSubmenu" id="law"></a><?php echo(getInnerHTMLForMB1(3)); ?></li>
        <li id="mb15"><a href="./category.php?catname=Dentistry" class="MenuBarItemSubmenu" id="dentist"></a><?php echo(getInnerHTMLForMB1(4)); ?></li>
        <li id="mb16"><a href="./category.php?catname=Medicine" class="MenuBarItemSubmenu" id="medicine"></a><?php echo(getInnerHTMLForMB1(5)); ?></li>
        <li id="mb17"><a href="./category.php?catname=Architecture" class="MenuBarItemSubmenu" id="arch"></a><?php echo(getInnerHTMLForMB1(6)); ?></li>
        <li id="mb18"><a href="./category.php?catname=Education" class="MenuBarItemSubmenu" id="edu"></a><?php echo(getInnerHTMLForMB1(7)); ?></li>
        <li id="mb19"><a href="./category.php?catname=Forest Resources" class="MenuBarItemSubmenu" id="forest"></a><?php echo(getInnerHTMLForMB1(8)); ?></li>
        <li id="mb110"><a href="./category.php?catname=Information School" class="MenuBarItemSubmenu" id="info"></a><?php echo(getInnerHTMLForMB1(9)); ?></li>
        <li id="mb111"><a href="./category.php?catname=Nursing" class="MenuBarItemSubmenu" id="nurse"></a><?php echo(getInnerHTMLForMB1(10)); ?></li>
        <li id="mb112"><a href="./category.php?catname=Fishery Sciences" class="MenuBarItemSubmenu" id="fish"></a><?php echo(getInnerHTMLForMB1(11)); ?></li>
        <li id="mb113"><a href="./category.php?catname=Other" class="MenuBarItemSubmenu" id="other"></a><?php echo(getInnerHTMLForMB1(12)); ?></li>
      </ul></td>
    </tr>
  </table>

