<html>
<head>
<title>Untitled Document</title>
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
?>
<style type="text/css">

	body {
	font-size:80%;font-family:verdana,arial,helvetica,sans-serif;color:#3a3a3a;
	}
	table{
	font-size:100%;
	}
	
	#apDiv3 {
	position:absolute;
	width:958px;
	height:397px;
	z-index:5;
	left: 3px;
	top: 95px;
	}
	
	.newlink{font-family: Courier New; font-size: 20px; font-weight: bold; color: black; text-decoration: none; border-bottom: 1px solid #999999;}
	
	.newlink:hover{font-family: Courier New; font-size: 20px; font-weight: bold; color: black; text-decoration: none; border-bottom: 1px solid #FFCC00;}
#apDiv1 {
	position:absolute;
	width:924px;
	height:115px;
	z-index:1;
	left: 13px;
	top: 407px;
}
</style>
</head>
<?php 	include("./database.php");
		$catname = $_GET['catname']; 
		$fixedcatname = str_replace(" ","%20",$catname);
		echo(file_get_contents("http://www.infymedia.com/infy/HuskySchedule/navBar.php?catname=$fixedcatname")); 
?>
<body>

  <div id="apDiv3">
    <table width="955" height="300" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="160" valign="top"><table width="160" border="0" cellpadding="3" cellspacing="0" bgcolor="#DED1ED">
          <tr>
            <td bgcolor="#412164"><b><font color="#ffffff"><?php echo($catname = $_GET["catname"]); ?></font></b></td>
          </tr>
          <?php
			
			$result = mysql_query("SELECT children FROM categories WHERE col_name='$catname'", $connection);
			$row=mysql_fetch_array($result);
			//echo($row["children"]);
			if(($row["children"]) != ""){
				$row2 = split(",", $row["children"]);
				//echo($row2[0]);
				for($i=0;$i<count($row2);$i++){
					$tmpid = $row2[$i];
					$result = mysql_query("SELECT col_name FROM categories WHERE id=$tmpid",$connection);
					$row3 = mysql_fetch_array($result);
					//echo($row3["col_name"]);
					$subcat = $row3["col_name"];
					$cattype = getCatType($subcat);
					echo("<tr><td><a href='./$cattype.php?catname=$subcat' style='{text-decoration:none; color:black; font-size:12}'>".$subcat."</td></tr>");
					//echo links and names of all the direct children
				}
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
		?>
        </table>
        </td>
        <td width="768" align="left" valign="top" >
          <div align="left">
            <table width="100%" height="181" border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td height="18" align="left" valign="top">
                  <table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                    	<td align="left"><?php 
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
								$parentlist .= ">" . $catname;
								echo("&nbsp;&nbsp;&nbsp;&nbsp;".$parentlist);
					?></td>
                    </tr>
                    <tr>
					<td align="right"><?php
								$range = $_GET["classes"];
								if($range==null)
									$range = "0-9";
								$tmpsp = split("-",$range);
								$startclass = $tmpsp[0];
								$endclass = $tmpsp[1];
								$classlength = ($endclass-$startclass)+1;
								$fchildren = getFormattedChildren($catname);
								$classes = mysql_query("SELECT * FROM classes WHERE parent IN $fchildren", $connection);
								$numclasses = mysql_num_rows($classes);
								$classesperpage = $classlength;
								//echo("helo".$classesperpage);
								$currpage = intval($_GET["page"]);
								if($currpage == NULL)
									$currpage = 1;
								$pagenumlist="";
								$loopnum = ceil($numclasses/$classesperpage);
								if($loopnum == 0)
									$loopnum = 1;
								if($currpage>1){
									$prevpage = $currpage-1;
									$min = (($prevpage-1) * $classesperpage);//+1;
									$max = (($prevpage * $classesperpage)-1);//min((($prevpage * $classesperpage)-1),$numclasses);
									$pagenumlist = $pagenumlist . "&nbsp;<a href='./category.php?catname=$catname&page=$prevpage&classes=$min-$max'><font><font size='1'><<</font>Prev</font></a>";
								}
								else
									$pagenumlist = $pagenumlist . "<font color='gray'><font size='1'><<</font>Prev</font>";
								for($i=1;$i<=$loopnum;$i++){
									if($i==$currpage)
										$pagenumlist = $pagenumlist . "&nbsp;<b>$i</b>";
									else{
										$min = (($i-1) * $classesperpage);//+1;
										$max = (($i * $classesperpage)-1);//min((($i * $classesperpage)-1),$numclasses);
										$pagenumlist = $pagenumlist ."&nbsp;<a href='./category.php?catname=$catname&page=$i&classes=$min-$max'>$i</a>";
									}
								}
								//echo("numclasses $numclasses currpage $currpage classesperpage $classesperpage");
								//echo(($loopnum>1)." ". ($numclasses>=((($currpage+1) * $classesperpage)-1)));
								if($loopnum>1&&$numclasses>=((($currpage+1) * $classesperpage)-1)){
									$nextpage = $currpage+1;
									$min = (($nextpage-1) * $classesperpage);//+1;
									$max = (($nextpage * $classesperpage)-1);//min((($nextpage * $classesperpage)-1),$numclasses);
									$pagenumlist = $pagenumlist . "&nbsp;<a href='./category.php?catname=$catname&page=$nextpage&classes=$min-$max'><font>Next>></font></a>";
								}else
									$pagenumlist = $pagenumlist . "&nbsp;<font color='gray'>Next<font size='1'>>></font></font>";
								echo($pagenumlist);
		
				?></td>
			  		</tr>
                    <tr>
                    	<td align="right"><input name="textsearchwithin" type="text" id="textsearchwithin" value="Search Within">
                        	<select name="classperpage" id="classperpage">
                        	  <option selected>Best Class Rating</option>
                        	  <option>Best Teacher Rating</option>
                        	  <option>Number of Credits</option>
                        	  <option>Credit Type</option>
                        	  <option>Earliest</option>
                        	  <option>Latest</option>
                   	      </select>
                        	<select onChange="onPerPageChange(this.options[this.selectedIndex].value,<?php echo($startclass);?>);" name="sortby" id="sortby">
                        	  <option value="5" <?php if($classesperpage==5)echo("selected"); ?>>5</option>
                        	  <option value="10" <?php if($classesperpage==10)echo("selected");?>>10</option>
                        	  <option value="20" <?php if($classesperpage==20)echo("selected");?>>20</option>
                              <option value="50" <?php if($classesperpage==50)echo("selected");?>>50</option>
                                                                </select>                       	</td>
                    </tr>
                    </table>
            	</tr>
              <tr>
                <td height="118" align="left" valign="top">
                  <table width="100%" border="1" cellpadding="10" cellspacing="0" bordercolor="#CCCCCC" FRAME=VOID RULES=ALL>
                    <?php
			function generateSmallSchedule($row){
			
			$num = 6;
			$reg = ":00";
			$half = ":30";
			$whole = true;
			for($i=0;$i<14;$i++){
				$tmp = $half;
				$st = "<font size='1' face='Verdana'>&nbsp;</font>";
				if($whole){
					$tmp = $reg;
					$num++;
					if($num>12)
						$num = 1;
					$st = "<font size='1' face='Verdana'>".$num.$tmp."</font>";
				}
				$weekdata = getTableRow($i+7,$row);
				$schedule = $schedule."<tr height='1'>
											<td>$st</td>
											$weekdata
											</tr>";
				//$whole = !$whole;
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
						</table>
						This is where the time should be displayed";
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
				//println("$strtime,$stampm,$sth,$stm,$tmppeek");
				return array($sth,$stm);
			}
			
			function getTableRow($num, $row){
				$days = array("monday","tuesday","wednesday","thursday","friday");
				$ans = "";
				for($i=0;$i<5;$i++){
					$time = $row[$days[$i]];
					$found = false;
					$ignorespace = false;
					if($time!=null&&strlen($time)>=3){
						$alltimes = split(";",$time);
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
								$rspan = $endh-$sth;
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
			
			function generateFavorites($row){
				$rating = intval($row['rating']);
				$result = "";
				$i=0;
				for(;$i<$rating;$i++){
					$result = $result . "<img src='./images/favorites-32x32.png'/>";
				}
				for(;$i<5;$i++){
					$result = $result . "<img src='./images/favorites-32x32blank.png'/>";
				}
				return $result;
			}
			
			function generateClassCell($row){
				global $connection;
				//$result = mysql_query("SELECT * FROM classes WHERE sln='11700'", $connection);
				//$row2=mysql_fetch_array($result);
				//$getLab = ;
				$miniSchedule = generateSmallSchedule($row);
				$stars = generateFavorites($row);
				$title = $row['title'];
				$description = $row['description'];
				$credits = $row['credits'];
				$teacher = $row['teacher'];
				$fillratio = $row['fillratio'];
				$parent = $row['parent'];
				$deptabriev = $row['deptabriev'];
				$number = $row['number'];
				$sln = $row['sln'];
				$getQuiz = getQuizSections($deptabriev, $number);
				$cell = "<table border='0' cellpadding='3' cellspacing='0'>
							<tr height='1'>
								<td rowspan='6' width = '1' align='left'>$miniSchedule</td>
								<td colspan = '3' align='left' valign='top'><a class = 'newlink' href='./class.php?sln=$sln'>$deptabriev $number: $title</a> </td>
							</tr>
							<tr height='1'>
								<td align='left' valign='top' >$stars</td>
								<td align='left' valign='top'><img src='./images/credits/$credits.jpg' height='47' width='50'/></td>
								<td  align='left' valign='top'>$fillratio</td>
							</tr>
							<tr>
								<td align='left' valign='top' colspan='3'>$description</td>
							</tr>
							<tr>
								<td colspan='2' align='left' valign='top'><table><tr><td><img src='./images/offline-user-48x48.png'/></td><td align='left' valign='top'>$teacher</td></tr></table></td>
								
							</tr>
							<tr><td>$parent</td></tr>
							</table>";
				return $cell;
				
			}
			
			function getOrderBy(){
				$tmp = $_GET["order"];
				if($tmp==null)
					$tmp="rating";
				return $tmp;
			}
			
			function getChildren($catname){
				global $connection;
				$allchildren = array( );
				array_push($allchildren,$catname);
				$children = mysql_query("SELECT children FROM categories WHERE col_name='$catname'", $connection);
				$row = mysql_fetch_array($children);
				$nums = $row["children"];
				if($nums!=null&&$nums!=""){
					$chlist = split(",",$nums);
					for($i=0;$i<count($chlist);$i++){
						$nextch = $chlist[$i];
						$childname = mysql_query("SELECT col_name FROM categories WHERE id=$nextch", $connection);
						$row2 = mysql_fetch_array($childname);
						$tmpcol = $row2["col_name"];
						$tomerge = getChildren($tmpcol);
						$allchildren = array_merge($allchildren,$tomerge);
					}
				}
				return $allchildren;
			}
			
			function getFormattedChildren($catname){
				$children = getChildren($catname);
				$result = "('".$children[0]."'";
				for($i=1;$i<count($children);$i++){
					$result = $result . "," . "'$children[$i]'";
				}
				$result = $result . ")";
				return $result;
			}
			
			$orderby = getOrderBy();
			//$numperpage = 
			
			//echo("$fchildren $startclass $classlength $orderby");
			$classes = mysql_query("SELECT * FROM classes WHERE parent IN $fchildren ORDER BY $orderby LIMIT $startclass, $classlength", $connection);
			
			while($row=mysql_fetch_array($classes)){
				$classcell = generateClassCell($row);
				$tmp =$row['parent'];
				echo("<tr><td align='left' bgcolor='#FFFFFF'>$classcell</td></tr>");
			}
		?>
                </table></td>
            </tr>
              </table>
        </div></td>
        <td width="27" valign="top">&nbsp;</td>
      </tr>
    </table>
    </div>
  </div>

<script type="text/javascript">
	var MenuBar1 = new Spry.Widget.MenuBar("MenuBar1");
	
	function onPerPageChange(newperpage,currstartclass){
		var endcl = parseInt(currstartclass-1)+parseInt(newperpage);
		var matches = window.location.href.toString().match(/classes=(.*)&/);
		//document.write("hello"+matches.length);
		if(matches!=null&&matches.length>0)
			window.location.href = window.location.href.toString().replace(/classes=(.*)&/,'classes='+currstartclass+'-'+endcl+'&');
		else
			window.location.href = window.location.href.toString() + '&classes='+currstartclass+'-'+endcl+'&';
	}
	
</script>


</body>
</html>

