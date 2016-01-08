###############################################################
# Heart of expect-lite crg (constrained random generator) lite 
# 	functions. The functions are called from expect-lite
# 
# set_random_seed <seed>	sets the random seed
# random <start> <end>	returns random number in range start-end
# randomize <var> <start> <end>	
# 	sets expect-lite variable to random value in range start-end
# 
# Include file sets seed, and initialized Random Number Generator
################################################################
# 
# Additonal functions in this file
#
# dec2hex <hex_var_name>	converts decimal a hexadecimal
# incr_wrap <var> <start> <end>
# 	increments expect-lite var unless at $end, 
#	then wraps to $start
# 
# show_all_vars <filter_str>
#	Shows all defined expect-lite Vars using 'str' as filter
#	use "*" to show all defined variables
#
# mark_time <var_name>
#	grabs current time (with milisecond resolution) and places value in var_name
#
# show_time <var_time_ms> <var_name>
#	var_time_ms is time in miliseconds (from the epoch) returned by mark_time
#	returns date/time formatted string in var_name
#
################################################################

# Updated for expect-lite 4.10 namespace - 8/18/11
# Updated with time functions (version 4.7.0) - 3/30/14

########## Include file which 'sources' tcl functions


# Define random functions
!proc set_random_seed { var } {
# proc sets the random seed based on expect-lite variable $var
!	set seed $::expectlite::user_namespace($var)
!	if { $seed == "none" } {
!		set seed [clock seconds]
!		expr srand($seed)
!		set ::expectlite::user_namespace($var) $seed
!	} else {
!		expr srand($seed)
!	}
!	puts "Seed is:$seed"
!}
!proc random { start end } {
# proc returns random number in range start-end
!	set range [ expr $end +1  - $start ]
!	return [expr int(rand()*$range) + $start]
!}
!proc randomize { var start end } {
# proc sets expect-lite variable to random value in range start-end
!       set ::expectlite::user_namespace($var) [random $start $end]
!}
>

#
# Define Additional Functions
#
!proc dec2hex { hex_var_name } {
!	# A Procedure that converts decimal a hexadecimal value, updates expect-lite variable
!	set x $::expectlite::user_namespace($hex_var_name)
!	set x [format %02X $x]
!	set ::expectlite::user_namespace($hex_var_name) $x
!}
!proc bitwise { var oper val } {
# proc sets expect-lite variable to bitwise operation 'oper' by $val
# supports oper: << >> & | ^ + = * / %
# depricated by expect-lite math function
!       set ::expectlite::user_namespace($var) [expr $::expectlite::user_namespace($var) $oper $val]
!}
>
!proc incr_wrap { var start end } {
# increments expect-lite var unless at $end, then wraps to $start
!	if { $::expectlite::user_namespace($var) == [expr $end ] } {
!		set ::expectlite::user_namespace($var) $start
!	} else {
!		incr ::expectlite::user_namespace($var)
!	}
!}
>

# Shows all defined expect-lite Vars using 'str' as filter
!proc show_all_vars { str } {
!	set var_list [array names ::expectlite::user_namespace]
!	set var_list_sorted [lsort $var_list]
!	puts "Displaying expect-lite Variables:"
!	foreach i $var_list_sorted {
!		if { $str != "*" } {
!			if { [ regexp ".*$str.*" $i ] } {
!				puts "Var:$i \t\t\Value:$::expectlite::user_namespace($i)"
!			}
!		} else {
!	     	puts "Var:$i \t\t\Value:$::expectlite::user_namespace($i)"
!		}
!	}
!}
>

# Time function: mark time, place into expect-lite variable (reference by name)
!proc mark_time { var_name } {
!	# A Procedure that marks current time in milliseconds and, updates expect-lite variable
!	set time [clock clicks -milliseconds ]
!	set ::expectlite::user_namespace($var_name) $time
!}

# Time function: converts time format (in miliseconds) and places into expect-lite variable (reference by name)
!proc show_time { var_time_ms var_name} {
!	# A Procedure that converts time from milliseconds and, updates expect-lite variable
!	set date $::expectlite::user_namespace($var_time_ms)
!	set ms [expr $date % 1000]
!	set date [expr int($date / 1000)]
!	set date_str [clock format $date -format "%Y-%m-%d %H:%M:%S"]
!	set date_str "$date_str.$ms"
!	set ::expectlite::user_namespace($var_name) $date_str
!}




# set the default value of the random number gen (rng) seed to "none"
$seed=none
# allow constant to override variable
# Normally constants will over-ride variables, but 
# 	because $seed is a user_namespace variable, and referenced that way in 
# 	the procedure set_random_seed, we use a trick, to set $seed to the value
# 	of the constant $seed.
$seed=$seed


; === initialize the rng
!set_random_seed seed




#pau
