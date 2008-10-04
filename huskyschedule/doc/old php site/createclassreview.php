<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
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
#pagetitle {
	width:100%;
	height:25px;
	background-color:#412164;
	color:#FFFFFF;
	font-size:14px;
}

.newlink{	
	font-family: Courier New; 
	font-size: 20px; 
	font-weight: bold; 
	color: black; 
	text-decoration: none; 
	border-bottom: 1px solid #999999;
}
	
.newlink:hover{
	font-family: Courier New; 
	font-size: 20px; 
	font-weight: bold; 
	color: black; 
	text-decoration: none; 
	border-bottom: 1px solid #FFCC00;
}
	
</style>
</head>
<?php 	$connection = mysql_connect("localhost","bix","beiderbecke");
		mysql_select_db("hs_courses",$connection);
		$sln = $_GET['sln'];
		$row=NULL;
	  	if($sln!=NULL){
			$select = mysql_query("SELECT * FROM classes WHERE sln='$sln'",$connection);
			$row = mysql_fetch_array($select);
			$deptabriev = $row['deptabriev'];
			$cl_number = $row['number'];
		}
		else{
			$deptabriev = $_GET['deptabriev'];
			$cl_number = $_GET['number'];
			$select = mysql_query("SELECT * FROM classes WHERE deptabriev='$deptabriev' AND number='$cl_number'",$connection);
			$row = mysql_fetch_array($select);
			$sln = $row['sln'];
		}
		$catname = $row['parent'];
		$fixedcatname = str_replace(" ","%20",$catname);//$catname);
		//echo("WOW".$fixedcatname);
		echo(file_get_contents("http://www.infymedia.com/infy/HuskySchedule/navBar.php?catname=$fixedcatname")); 
?>
<body>
<div id="apDiv3">
  <table width="100%" height="100%" border="0">
    <tr>
      <td height="1">breadcrumbs</td>
    </tr>
    <tr>
      <td valign="top" height="56"><div id="pagetitle"><strong>Write A Class Review</strong></div>Husky Schedule's Class Rating let's you interact with other students and contribute to blah blah</td>
    </tr>
    <tr>
      <td height="1"><?php 
	  			$title = $row['title'];
	  			echo("<a class = 'newlink' href='./class.php?sln=$sln'><font>$deptabriev $cl_number: $title</font></a><br/>What other info should Go HERE!!!Credits?Current Rating?ETC?");	
	  	 ?>
      </td>
    </tr>
    <tr>
      <td valign="top"><table>
      		<tr><hr width=100%></tr>
            <tr>
      		<td valign="top" width=40%><strong>Class Review Guidelines</strong><br/>
This site reads all reviews before posting them and reserves the right to deny any review. Here are some of the things that can cause a review to be denied:<br/>
•	Offensive or abusive language.<br/>
•	References to cheating or other behavior not condoned by the university.<br/>
•	Hyperlinks / URLs.<br/>
•	Replies to existing reviews; please do not attempt to initiate discussions here.<br/>
•	Criticism of this site<br/>
•	Illegal content<br/>
•	Invasion of personal privacy<br/>
•	Pornography or obscenity<br/>
•	Hate or incitement of violence, threats of harm or safety of a person<br/>
•	Graphic violence or other acts resulting in serious injury or death.<br/>
•	Any violations of copyright.<br/>
•	Any violations of laws and/or copyrighted musical works.<br/></td>
            <td><form onsubmit="return validate_form(this)" action="./inputclassreview.php?deptabriev=<?php echo("$deptabriev&number=$cl_number"); ?>" method="post">
            		<table width="100%">
                   	  <tr><td >Review Title:</td>
                   	  <td ><input type="text" name="r_title" /></td></tr>
                    	<tr><td>Overall Rating:*</td><td><label>
                    	<select name="r_rating" value="Please Choose A Value">
                    	  <option value="0" selected="selected">Please Choose A Value</option>
                    	  <option value="5">5-Excellent</option>
                    	  <option value="4">4-Good</option>
                    	  <option value="3">3-Average</option>
                    	  <option value="2">2-Poor</option>
                    	  <option value="1">1-Very Poor</option>
                    	</select>
                    	</label></td></tr>
                        <tr><td>When Did You Take This Class:*</td><td><label>Quarter:&nbsp;
                    	<select name="r_quarter" value="Please Choose A Value">
                    	  <option value="0" selected="selected">Please Choose A Value</option>
                    	  <option value="aut">Autumn</option>
                    	  <option value="winter">Winter</option>
                    	  <option value="spring">Spring</option>
                    	  <option value="summer">Summer</option>
                    	</select>
                    	</label>
                        Year:&nbsp;<input name="r_year" type="text" size="8" maxlength="4" />
                        </td></tr>
                        <tr><td height="69">Pros:*<br/>(1,000 characters max)</td><td><textarea name="pros" cols="50" rows="7" onKeyDown="limitText(this.form.pros,1000);" onKeyUp="limitText(this.form.pros,1000);"></textarea></td></tr>
                        <tr><td height="69">Cons:*<br/>(1,000 characters max)</td><td><textarea name="cons" cols="50" rows="7" onKeyDown="limitText(this.form.cons,1000);" onKeyUp="limitText(this.form.cons,1000);"></textarea></td></tr>
                        <tr><td height="69">Other Thoughts:<br/>(1,000 characters max)</td><td><textarea name="other_thoughts" cols="50" rows="7" onKeyDown="limitText(this.form.other_thoughts,1000);" onKeyUp="limitText(this.form.other_thoughts,1000);"></textarea></td></tr>
                        <tr><td >(If Guest (change this in code to check if is guest))Nickname:</td>
                   	  <td><input type="text" name="r_username" /></td></tr>
                      <tr><td><input type="submit" value="Submit" /></td></tr>
                     </table>
            	 </form>    
            </td>
            </tr>
      	  </table>
      </td>
    </tr>
  </table>
</div>
</div>

<script type="text/javascript">
var MenuBar1 = new Spry.Widget.MenuBar("MenuBar1");
	function validate_form(thisform){
		noerrors = true;
		if(thisform.r_rating.value==0)
			noerrors = false;
		if(thisform.r_quarter.value==0)
			noerrors = false;
		noerrors = (noerrors && checkYear(thisform.r_year));
		//alert(thisform.r_rating);
		return noerrors;
	}
	
	function checkYear(formyear){
		if(strlen(thisform.r_year.value)==2){
			if(intval(year)<50)
				thisform.r_year.value = "20"+year;
			else
				thisform.r_year.value = "19"+year;
		}
		if(strlen(thisform.r_year.value)!=4){
			return false;
		}
		return true;
	}
	
	function limitText(limitField, limitNum) {
		if (limitField.value.length > limitNum) {
			limitField.value = limitField.value.substring(0, limitNum);
		}/* else {
			limitCount.value = limitNum - limitField.value.length;
		}*/
	}
</script>
</body>
</html>
