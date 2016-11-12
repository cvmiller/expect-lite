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
#	Serial logout include script
#

# set user prompt
*/.*: /

>>^M
>>
+$prompt1=\n.*(#|\$)
>>
?if $prompt1 == # ? [
	# must be root, issue extra exit
	>>exit
]

>exit
<logout
; === exit screen
# must use send, as >> adds LF at end
!send "\001"
!send ":"
>>quit
<screen is term
