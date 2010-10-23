# bashrc

# append this sample bashrc to your .bashrc to set customize expect-lite

# remote host to connect, default=none
# 	expect-lite was designed to automate server farm environments
#	However, it can also be run from the local machine or PC by setting
#	this value to 'none'. The CLI option -r <rhost> will overide this value
#export EL_REMOTE_HOST=localhost

# name of expect-lite script
#	Good for testing one script over and over
#export EL_CMD_FILE=

# change to this dir upon login
#export EL_USER_DIR=

# Login method to remote host
#	expect-lite includes a utilty (setup_local_ssh.sh) to automatically setup ssh 
#	keys for the user to use with the localhost. This is the fastest method 
#	of script execution, much faster than 'none'.
#	Choose one login method: telnet|ssh|ssh_key|none
#export EL_CONNECT_METHOD=ssh_key
export EL_CONNECT_METHOD=none

# username for telnet|ssh|ssh_key access methods
# User is also used by ssh_key method as well. If user is blank then the default
#	user will be used (the user running the script). However if $user is defined
#	then ssh_key will use the following command: ssh $user@$host
#export EL_CONNECT_USER=

# password for telnet|ssh access methods
#export EL_CONNECT_PASS=

# Delay (in ms) to wait for host in Not Expect, and Dynamic Var Capture
# 100 ms is a good value for a local LAN, 200 ms if running across high speed internet
#export EL_DELAY_WAIT_FOR_HOST=

# User defined constants
#EL_*                         
