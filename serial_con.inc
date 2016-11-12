# How to use this expect-lite file, Lines that begin with:
#   '>' send to remote host, implies "wait for prompt"
#   '<' _MUST_ be received from the remote host, or this config script will fail
#   # are comment lines, and have no effect
#   ; are printable (in stdout) comments, and have no other effect
#   @ change the expect timeout value
#   ! Embedded Expect commands
#   ? If statement, use format ?cond?action::else_action
# For more info see: http://expect-lite.sf.net/

#
#   expect-lite script
#	Serial login include script
#


; === check sudo password
# hide sudo password
*NOINFO
? $EL_SUDO_PASS == $blank? [
	;red NO Sudo Password set, set Env Var EL_SUDO_PASS
	*TERM
]

*INFO
# hide sudo password
>stty -echo
>echo "$EL_SUDO_PASS" | sudo -S pwd
>stty echo

; === start screen
>sudo screen $serial $SPEED


# set user prompt
*/.*: /
# detect prompt
>>^M
>
+$prompt1=\n.*(\$ |login:|word:)

?if $prompt1 == word: ? [
	>>^M
	<Login incorrect
	# allow to continue to login
	$prompt1=login:
]


?if $prompt1 == login: ? [
	>>^M
	<login|username|$USER
	>>$USER
	<assword
	>>$PASS
	>
]

# detect prompt again
>>^M
>
+$prompt1=\n.*(\$|#)

#
# Arch only way of going to root user :^P
#
?if $prompt1 == $ ? [
	>su
	<assword
	>>$ROOTPASS
	>
]

; === logged in, identify build
>uname -a
>
# remove custom prompt
*//


