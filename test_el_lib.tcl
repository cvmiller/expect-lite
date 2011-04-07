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
expectlite::_el_init_library "*EXP_INFO IP=10.5.5.5 *DEBUG"
puts "el_lib initialized"


# create spawn sessions and set prompt to identify the session
spawn bash
send "export PS1='0\$ '\n"
set session(default) $spawn_id

spawn bash
send "export PS1='1\$ '\n"
set session(dut1) $spawn_id

spawn bash
send "export PS1='2\$ '\n"
set session(dut2) $spawn_id

spawn bash
send "export PS1='3\$ '\n"
set session(dut3) $spawn_id

# remove global to simulate STAF
unset spawn_id

# Import the session array into EL
#	_el_import_session_ids <session list, alternating name spawn_id>
#	e.g. _el_import_session_ids dut3 exp9 dut1 exp7 dut2 exp8 def exp6
# Note: TCL does not actually pass arrays, therefore a list is passed
#
expectlite::_el_import_session_ids [array get session]

#
#	Import more vars into EL (as constants)
#
expectlite::_el_import_const "DUT=mydut *NOFAIL"

expectlite::_el_import_const "DUT2=thatdut "

################ initialization complete. Begin of script ############

proc test_funct { str } { 
	puts "calling test_funct param=$str"
	sleep 3
	return 0
}



puts "argv0 is:$argv0"

# read this file as el script, reference by buf_stack pointer
set cmd_file $argv0
set cmd_list_ptr [expectlite::_el_buffer $cmd_file]


# call el script exec
set RESULT [ expectlite::_el_script_exec "" $cmd_list_ptr ]

# Print result of test
switch $RESULT {
	0 	{ puts "\nTest Passed" }
	1	{ puts "\nTest Failed" }
	2	{ puts "\nTest Abend" }
}


#stop TCLSH from reading EL Script
exit 0

########## Embedded EL Scrtpt ###############
; === start script $IP
@2
*TIMESTAMP ISO
$IP=2001::DEAD
~junk
>date
<2011
>pwd
*FORK
>
*NOTIMESTAMP
*SHOW VARS
*TCL puts "\nARGV:$argv0"
*TCL puts [test_funct $cmd_list_ptr]
>echo "pau"
>
