#!/usr/bin/env tclsh
#
#	Load the correct expect-library
#

# script will core dump if libexpect is wrong version
#load /usr/lib/libexpect.so.5
#puts "platform:$tcl_platform(platform)"
puts "tclsh version:[info patchlevel]"
switch $tcl_platform(platform) {
    windows {
        load [file join /usr/lib libexpect526.a]
    }
    unix {
        load [file join /usr/lib libexpect[info sharedlibextension].5]
    }
}


# test expect extensions
send_user "expect library loaded\n"

# set el library mode
set ::EL_LIBRARY 1

source el_lib

puts "el_lib loaded"

# Set arguments to el_lib and call el_read_args
set ac 4
set av "-r none IP=10.5.5.5 *DEBUG"
_el_read_args $ac $av


puts "argv0 is:$argv0"

# read this file as el script, reference by buf_stack pointer
set cmd_file $argv0
set buf_stack [_el_buffer $cmd_file]


# spawn to bash for now
_el_connect_localhost ""

# call el script exec
_el_script_exec "" $buf_stack


# Print result of test
if {$_el(test_failed) && $NOFAIL} {
	# test must have failed somewhere but NOFAIL was true
	if {$INFO} {cputs "\n\n##Overall Result: FAILED (*NOFAIL on)\n\n" $el_err_color }
	exit 1
} else {
	#If we get this far, then we passed!
	if {$INFO} {cputs "\n\n##Overall Result: PASS \n\n" $el_info_color }
}


#stop TCLSH from reading EL Script
exit 0

########## EL Scrtpt ###############
; === start script $IP
>date
<2011
>echo "pau"
>
