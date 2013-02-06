<html>
 <head>
<?php
// Expect-lite web runner v0.9
// by Craig Miller 30 January 2013
// 
// Updated 5 Feb 2013 - v0.91
//   Added defaults, and dir listing
// 

$path="/home/cmiller/public_html";
// default test
$el_app="simple.elt";
$el_args="IP=3930-184";

function read_dir($path) {
     // Load up array with file names!

     $handle = opendir($path);

     $array_indx = 0;

     while (false !== ($file = readdir($handle))) {
     		//show only ELT files
     		if (strstr($file, ".elt") == ".elt" ) {
		$dir_array[$array_indx] = $file;
		$array_indx ++;
	     }
        }
	return $dir_array;
}

function show_dir($dir_array) {
	foreach ($dir_array as $n) {
		echo "<a href=\"$n\">",$n, "</a><BR>";
	}
}


?>
  <title>EL runner</title>
 </head>
 <body>
 
<H2 align="center">EL Web Runner</H2>
<HR />
<?php
 

 //$el_app=$_POST["el_app"];
 //$el_args=$_POST["el_args"];
 
 //$week= $_POST['week'];
 //if ($_POST["week"] == '') {
 //	$week = 1;
 //}
 if ($_POST["el_app"] == '') {
 	echo "<form action=\"el_run.php\" method=\"POST\">";
	echo "  Run: <input type=\"text\" name=\"el_app\" value=\"$el_app\" />";
	echo " args: <input type=\"text\" name=\"el_args\"value=\"$el_args\"  />";
	//echo " in Week: <input type=\"text\" name=\"week\" />";
	echo "  <input type=\"submit\" value=\"Run-It\">";
	echo " </form> ";
	echo "<b>Available tests:</b><BR>";
	$dir_list=read_dir($path);
	show_dir($dir_list);
	}
 else {
	$el_app=$_POST["el_app"];
	$el_args=$_POST["el_args"];

 	echo "You are looking at: $el_app";
	echo " <PRE>";
	// show_dir(read_dir($path));
	$pipe = popen ("export TERM=web; $path/$el_app $el_args *NOINTERACT", "r");
	//$pipe = popen ("export TERM=web; $path/expect-lite $path/$el_app $el_args *NOINTERACT", "r");
	while(!feof($pipe)) {
		$line = fread($pipe, 1024);
		echo $line;
		// show partial output
		flush();	
	}
	pclose($pipe);
	echo "</PRE>";
}
?>
<HR />
<i>el-web-runner</i> by Craig Miller &copy; 2013<BR>
 </body>
</html>
