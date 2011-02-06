#!/usr/bin/env tclsh8.5
#
#	libexpect is compiled with tclsh version 8.5
#
#	expect-lite library demo script
#
#	by Craig Miller 5 Feb 2011
#

# Add library to search path
lappend auto_path "."
# Load el_lib
package require expect-lite
puts "el_lib loaded"

# Initialize EL library
#	_el_init_library <cli init string>
#	Loads libexpect, initializes el global variables, spawns bash session
#
_el_init_library "*EXP_INFO IP=10.5.5.5 *NODEBUG"
puts "el_lib initialized"


# create spawn sessions and set prompt to identify the session
spawn bash
send "export PS1='0\$ '\n"
set session(def) $spawn_id

spawn bash
send "export PS1='1\$ '\n"
set session(dut1) $spawn_id

spawn bash
send "export PS1='2\$ '\n"
set session(dut2) $spawn_id

spawn bash
send "export PS1='3\$ '\n"
set session(dut3) $spawn_id

_el_import_session_ids [array get session]


################ initialization complete. Begin of script ############33

proc test_funct { str } { 
	puts "calling test_funct param=$str"
	return 0
}



set session(default) 0
set session(dut1) 2
set session(dut2) 3
set session(dut3) 4

#test_array [array get session]

puts "argv0 is:$argv0"

# read this file as el script, reference by buf_stack pointer
set cmd_file $argv0
set cmd_list_ptr [_el_buffer $cmd_file]


# call el script exec
set RESULT [ _el_script_exec "" $cmd_list_ptr ]

# Print result of test
switch $RESULT {
	0 	{ puts "\nTest Passed" }
	1	{ puts "\nTest Abend" }
	2	{ puts "\nTest Failed" }
}


#stop TCLSH from reading EL Script
exit 0

########## Embedded EL Scrtpt ###############
; === start script $IP
@3
#*DEBUG
>date
<2011
*FORK
*TCL puts "\nARGV:$argv0"
*TCL puts [test_funct $cmd_list_ptr]
>echo "pau"
>
