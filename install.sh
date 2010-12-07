#!/bin/bash
#
# Script to install expect-lite from tar file
# 
#
# by Craig Miller	5 December 2010
#


function usage {
	echo "	$0 - Used install expect-lite and configure ssh, and bashrc "
	echo "	e.g. $0 "
	echo "	"
	echo " By Craig Miller - Installer Version: $VERSION"
	exit 1
}


# Script Defaults	   
numopts=0
VERSION=0.92
SSH_HOME=$HOME/.ssh

BIN_DIR=/usr/bin
DOC_DIR=/usr/share/doc/expect-lite
MAN_DIR=/usr/share/man/man1
TOOLS_DIR=Tools
BASHRC=$HOME/.bashrc

OPTS=$*

# Get options off of command line
while getopts "vVhR" options; do
  case $options in
    V ) show_version=TRUE
    	let numopts+=1;;
    v ) show_version=TRUE
    	let numopts+=1;;
    h ) usage;;
    R ) remove=TRUE
     let numopts+=1;;
    \? ) usage	# show usage with flag and no value
         exit 1;;
    * ) usage		# show usage with unknown flag
    	 exit 1;;
  esac
done
# remove the options as cli arguments
shift $numopts

# check that there are no arguments left to process
if [ $# -ne 0 ]; then
	usage
	exit 1
fi

if [ $show_version ]; then
	usage
	exit 1
fi

# OS detection Linux|Darwin|CYGWIN
OS=$(uname -s | grep CYGWIN)

# do the following for non-CYGWIN OSs
if [ "$OS" == "" ]; then
	MYUID=$(id -u)
	if [  $MYUID -ne 0 ]; then
		echo "==================="
		echo "Please use: sudo $0 $OPTS"
		echo "==================="
		usage
		exit 1
	fi
fi


function installit {
	# pass in file to be installed, location and step number
	echo "$3)	==================="
	echo "	Installing $1 in $2"
	mkdir -p $2
	cp -R $1 $2
	chmod 755 $2/$1
}

function removeall {
	# blindly removes installation
	echo "==================="
	echo "Removing Expect-lite"
	rm -rf $BIN_DIR/expect-lite
	rm -rf $DOC_DIR
	rm -rf $MAN_DIR/expect-lite.1.gz
	# restore old version of expect-lite (if present)
	if [ -e $BIN_DIR/expect-lite.old ]; then
		mv -f $BIN_DIR/expect-lite.old $BIN_DIR/expect-lite
	fi
	# restore bashrc
	if [ -e ${BASHRC}.org ]; then
		mv -f ${BASHRC}.org $BASHRC
	fi
	echo "Done."
	echo "==================="
}



#======== Actual work performed by script ============

# un-install if '-R' is used
if [ $remove ]; then
	removeall
	exit 
fi

new_ver=$(grep "set version" ./expect-lite | cut -d " " -f 3)

echo "=======================================" 
echo "Installing expect-lite version $new_ver"



#check if expect is installed
if [ ! -e /usr/bin/expect ]; then
	echo "0)	==================="
	echo "	ACK! expect is NOT installed"
	echo "	Please install expect first:"
	echo "	  sudo yum install expect"
	echo "	  sudo apt-get install expect"
	echo "	  or use cygwin setup to install expect"
	echo "Exiting...."
	exit 1
fi

#check if expect-lite is installed
if [ -e /usr/bin/expect-lite ]; then
	existing_ver=$(grep "set version" /usr/bin/expect-lite | cut -d " " -f 3)
	echo "0)	==================="
	echo "	ACK! expect-lite already installed"
	echo "	Preservering older version $existing_ver to expect-lite.old"
	# back up older version
	mv /usr/bin/expect-lite /usr/bin/expect-lite.old
fi


# start actual install - Steps 1,2,3
installit expect-lite $BIN_DIR "1"
installit Examples $DOC_DIR "2"
cd man
installit expect-lite.1.gz $MAN_DIR "3"
cd - > /dev/null

# test if bashrc needs mod
mod_bash=$(grep EL_CMD $BASHRC)
if [ "$mod_bash" == "" ]; then
	echo "4)	==================="
	echo "	Updating $HOME/.bashrc file with expect-lite defaults"
	# back up bashrc
	cp $BASHRC ${BASHRC}.org
	# append to bashrc
	cat bashrc >> $BASHRC	
	#check if sshd is running - if so, then configure expect-lite to use ssh keys
	sshd_running=$(ps -e | grep sshd | wc -l)
	if [ $sshd_running -gt 0 ]; then
		echo "5)	==================="
		echo "	Configuring .bashrc for SSH keys"
		# enable remote_host and connect_method
		/bin/sed -i  's;#export EL_REMOTE_HOST;export EL_REMOTE_HOST;' $BASHRC
		/bin/sed -i  's;export EL_CONNECT_METHOD=none;export EL_CONNECT_METHOD=ssh_key;' $BASHRC
		echo "	==================="
		echo "	be sure to 'source ~/.bashrc' to have changes take effect"
	fi
fi

# do the following for non-CYGWIN OSs
if [ "$OS" == "" ]; then
	#check if ssh keys already exist
	if [ ! -e $SSH_HOME/id_rsa.pub ]; then
		echo "==================="
		echo "Creating ssh keys as user: $SUDO_USER"
		su $SUDO_USER -c $TOOLS_DIR/setup_local_ssh.sh
	fi
fi


# Pau!
echo "=======================================" 
echo "Installation Complete!"
echo "=======================================" 
