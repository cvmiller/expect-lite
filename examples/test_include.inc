# How to use this expect-lite file, Lines that begin with:
#	'>' send to remote host, implies "wait for prompt"
#	'<' _MUST_ be received from the remote host, or this config script will fail
#	# are comment lines, and have no effect
#	; are printable (in stdout) comments, and have no other effect
#	@ change the expect timeout value
#	! Embedded Expect commands
# For more info see: expect-lite.html

#
# This is a test include file
#

; ==== Connect to the cosim and check for kernel errors & fail if found

>dmesg | tail -10
>dmesg -c | egrep  "Oops|BUG" | wc -l
<[ ]*0

#Wait for test to end (return of prompt)
>
#Pau!
