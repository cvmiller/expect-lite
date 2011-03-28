# Native Expect function to handle sudo prompt
# sudo is sometimes challenged by a password, and sometimes not
#
# by Craig Miller	June 2010
#

proc run_sudo { cmd pass } {
	global expect_out
	upvar expectlite::DEBUG DEBUG
	send "sudo -p 'sudo# ' $cmd \n"
	expect  -timeout 1 -notransfer -re "\nsudo# " {  send "$pass\n"; puts "sendpass\n"}
	# wait for bash prompt	
	#expect -re {.*\$ $} { } 
	if { $DEBUG } { 
		puts "  in<<$expect_out(buffer)>>"
		puts "\n"
	}
	
}
