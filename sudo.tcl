proc run_sudo { cmd pass } {
	global DEBUG expect_out
	send "sudo -p 'sudo# ' $cmd \n"
	expect  -timeout 1 -notransfer -re "\nsudo# " {  send "$pass\n"; puts "sendpass\n"}
	# wait for bash prompt	
	#expect -re {.*\$ $} { } 
	if { $DEBUG } { 
		puts "  in<<$expect_out(buffer)>>"
		puts "\n"
	}
	
}
