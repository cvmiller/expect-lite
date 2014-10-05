# How to use this expect-lite file, Lines that begin with:
#	'>' send to remote host, implies "wait for prompt"
#	'<' _MUST_ be received from the remote host, or this config script will fail
#	# are comment lines, and have no effect
#	; are printable (in stdout) comments, and have no other effect
#	@ change the expect timeout value
#	! Embedded Expect commands
# For more info see: expect-lite.html

#
# Jump to interact
#

#; Press '+++' to end interactive session
>
#!interact +++ return
*INTERACT
>
# allow script to continue
!set _el(continue) 1
>
; === Continuing Script
>
