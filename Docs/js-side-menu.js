// external js code
	
// print array of lines, which becomes the side menu

menu_lines = [ '<ul>' , '<li><a href="expect-lite_simple.html">What is it?</a></li>', '<li><a href="expect-lite_install.html">Downloading and Installing</a></li>' , '<li><a href="expect-lite_doc.html">Documentation</a></li>' , '<li><a href="expect-lite_tips.html">Debugging Tips and Tricks</a></li>' ,'<li><a href="expect-lite_license.html">BSD-Style License</a></li>' ,'<li><a href="expect-lite_cygwin.html">Cygwin Support</a></li>','</ul>' ,''  ];


function print_menu_lines (lines) {
	var line_break = '<br/>';
	for (var line in lines) {
		document.writeln(lines[line]);
	}	
}

print_menu_lines(menu_lines);


