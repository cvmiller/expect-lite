<html>
 <head>
<?php
// Expect-lite web runner v0.9
// by Craig Miller 30 January 2013
// 
// Updated 5 Feb 2013 - v0.91
//   Added defaults, and dir listing
// 

// Updated 6 Dec 2013 - v0.92
//   Updated with checkbox for script help
//   Added dir sorting, and 'view' link
// 

// Updated 8 Dec 2013 - v0.93
//   Updated to walk subdirectories, starting at $path
//   Directories are sort at top of list
//

// 
//	CAUTION: this code is still experimental
//
//	It provides a method to run expect-lite scripts via a web interface with colour output
//		based on setting the terminal type to 'web'
//	It has the following limitations
//		o $path must be an absolute path to this script, and expect-lite scripts
//		o $el_app must be runable script
//		o $el_args can be any valid expect-lite cli argument, constants, directives, etc
//		o This script has only been tested with an Apache webserver with PHP enabled
//			It can be a HUGE security hole, DO NOT allow external access to this script
//


// ===== Change these vars to valid values in your environment ====
// path to this script and expect-lite scripts
$path="/home/cvmiller/public_html";
// default test
$el_app="simple.elt";
$el_args="IP=3930-184";
// ================================================================

// initialize vars - Don't change
$el_path=".";
$cur_path="";

function read_dir($path,$type) {
     // Load up array with file names!
	 $dir_array=array();
     $handle = opendir($path);

     $array_indx = 0;

     while (false != ($file = readdir($handle))) {

     		//show only ELT files
			if ($type == "elt") {
     			if (strstr($file, ".elt") == ".elt" ) {
					$dir_array[$array_indx] = $file;
					$array_indx ++;
	     		}
			} elseif ($type == "dir") {
				if (is_dir($file) && $file != ".") {
					$dir_array[$array_indx] = $file;
					$array_indx ++;
				}
			}
        }
	if (!empty($dir_array)) {
		array_multisort($dir_array);
		}
	return $dir_array;
}

function show_dir($dir_array,$cur_path) {
	if (!empty($dir_array)) {
		foreach ($dir_array as $n) {
			//echo "<a href=\"$n\">",$n, "</a><BR>";
				$p="$n";			
			if (is_dir($n)) {
				echo "<small><small>dir</small></small>  <a href=\"el_run.php?el_path=$cur_path/$p\">",$n, "</a><BR>";
			} else {
				echo "<a href=\"./$cur_path/$n\"><small><small>view</small></small></a>  <a href=\"el_run.php?el_app=$n&el_path=$cur_path\">",$n, "</a><BR>";
			}
		}
	}
}

function calc_path($path) {
	$el_path=getcwd();
	$el_path=str_replace("$path","","$el_path");
	//echo getcwd() . "\n";
	//echo "$path/ $el_path \n";
	return $el_path;
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
 
 if (!empty($_GET)) {
	 if (isset($_GET["el_app"])) {
 		$el_app=$_GET["el_app"];
		}
	 if ($_GET["el_path"] != '') {
 		$el_path=$_GET["el_path"];
		chdir("$path/$el_path");
		$el_path=calc_path($path);
		}
 }
 if (!empty($_POST)) {
	 if ($_POST["el_path"] != '') {
 		$el_path=$_POST["el_path"];
		chdir("$path/$el_path");
		$el_path=calc_path($path);
		}
 }

 if (empty($_POST)) {
 	echo "<form action=\"el_run.php\" method=\"POST\">";
	echo "  Run: <input type=\"text\" name=\"el_app\" value=\"$el_app\" style=\"width: 150px\"/>";
	echo " <small>with help </small><input type=\"checkbox\" name=\"with_help\" checked=\"checked\" value=\"true\">";
	echo " args: <input type=\"text\" name=\"el_args\"value=\"$el_args\" style=\"width: 350px\" />";
	//echo " in Week: <input type=\"text\" name=\"week\" />";
	echo "  <input type=\"hidden\" name=\"el_path\" value=\"$el_path\" >";
	echo "  <input type=\"submit\" value=\"Run-It\">";
	echo " </form> ";
	echo "<b>Available tests:</b><BR>";
	$dir_list=read_dir(getcwd(),"dir");
	show_dir($dir_list,$el_path);
	$dir_list=read_dir(getcwd(),"elt");
	show_dir($dir_list,$el_path);
	}
 else {
	$el_app=$_POST["el_app"];
	$el_args=$_POST["el_args"];
	//echo getcwd() . "/$el_app $el_args";
	$cdir=getcwd();

 	echo "You are looking at: $el_app";
	echo " <PRE>";
	// show_dir(read_dir($path));
	if (!isset($_POST["with_help"])) {
		$pipe = popen ("export TERM=web;export PATH=/usr/bin:/bin;$cdir/$el_app $el_args *NOINTERACT", "r");
	} else {
		$pipe = popen ("export TERM=web;export PATH=/usr/bin:/bin;$cdir/$el_app $el_args -h ", "r");
	}
	//$pipe = popen ("export TERM=web; $path/expect-lite $path/$el_app $el_args *NOINTERACT", "r");
	while(!feof($pipe)) {
		$line = fread($pipe, 1024);
		echo $line;
		// show partial output
		flush();	
	}
	pclose($pipe);
	// show form again without help checkbox checked
	echo "</PRE>";

	echo "<HR />";
 	echo "<form action=\"el_run.php\" method=\"POST\">";
	echo "  Run: <input type=\"text\" name=\"el_app\" value=\"$el_app\" style=\"width: 150px\"/>";
	echo " <small>with help </small><input type=\"checkbox\" name=\"with_help\" value=\"true\">";
	echo " args: <input type=\"text\" name=\"el_args\"value=\"$el_args\" style=\"width: 350px\" />";
	//echo " in Week: <input type=\"text\" name=\"week\" />";
	echo "  <input type=\"hidden\" name=\"el_path\" value=\"$el_path\" >";
	echo "  <input type=\"submit\" value=\"Run-It\">";
	echo " </form> ";

}
?>
<HR />
<i>el-web-runner</i> by Craig Miller &copy; 2013<BR>
 </body>
</html>
