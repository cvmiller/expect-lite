#!/bin/bash
#
# Script to install expect-lite from tar file
# 
#
# by Craig Miller	5 December 2010
#
#	6 May 2011 - fixed install non-privileged user
#
#	21 Aug 2011 - added configure only option, just configures user
#
#	11 Aug 2012 - added configure as non-privilaged user
#
#	5 Jan 2013 - fixed NFS mounted home install issues
#


function usage {
	echo "usage:  $0 [-p install_location_prefix] [-R] [-c]"
	echo "	$0 - Used install expect-lite and configure ssh, and bashrc "
	echo "	e.g. $0 "
	echo "	"
	echo "	-p installation prefix"
	echo "	-c configure only, configures ssh, and bashrc"
	echo "	-R Remove installation"
	echo "	"
	echo " By Craig Miller - Installer Version: $VERSION"
	exit 1
}


# Script Defaults	   
numopts=0
VERSION=1.1
SSH_HOME=$HOME/.ssh

PREFIX=""
# Dirs are defined as relative, fixed later if absolute
BIN_DIR=/bin
DOC_DIR=/doc/expect-lite
MAN_DIR=/man/man1
TOOLS_DIR=Tools
BASHRC=$HOME/.bashrc
ELRC=$HOME/.expect-literc
START_PWD=$PWD

OPTS=$*

# Get options off of command line
while getopts "vVhRp:c" options; do
  case $options in
    V ) show_version=TRUE
    	let numopts+=1;;
    v ) show_version=TRUE
    	let numopts+=1;;
    p ) PREFIX=$OPTARG
    	let numopts+=2;;
    h ) usage;;
    R ) remove=TRUE
     let numopts+=1;;
    c ) configure_only=TRUE
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
if [ "$OS" == "" ] && [ "$PREFIX" == "" ] && [ ! $configure_only ]; then
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
	mkdir -p $2 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "Ack! No write permissions to:$2!"
		echo "Sheepishly giving up and Quiting..."
		exit 1
	fi
	cp -R $1 $2
	chmod 755 $2/$1
}

function removeall {
	# blindly removes installation
	echo "==================="
	echo "Removing Expect-lite"
	rm -rf $PREFIX$BIN_DIR/expect-lite
	rm -rf $PREFIX$DOC_DIR
	rm -rf $PREFIX$MAN_DIR/expect-lite.1.gz
	# restore old version of expect-lite (if present)
	if [ -e $PREFIX/$BIN_DIR/expect-lite.old ]; then
		mv -f $PREFIX$BIN_DIR/expect-lite.old $PREFIX$BIN_DIR/expect-lite
	fi
	# restore bashrc
	if [ "$USER" == "root" ]; then
		BASHRC=/home/$SUDO_USER/.bashrc
		ELRC=/home/$SUDO_USER/.expect-literc
	fi
	mod_bash=$(grep expect-literc $BASHRC)
	if [ "$mod_bash" != "" ]; then
		# remove source line in bashrc
		echo "updating bashrc"
		if [ "$USER" == "root" ]; then
			sudo -u $SUDO_USER sed -i -e "s;source $ELRC;;" $BASHRC
		else
			sed -i -e "s;source $ELRC;;" $BASHRC
		fi
	fi
	echo "Done."
	echo "==================="
}



#======== Actual work performed by script ============

# fix up prefixes if no prefix defined
if [ "$PREFIX" == "" ]; then
	# set up "standard" paths
	BIN_DIR=/usr$BIN_DIR
	DOC_DIR=/usr/share$DOC_DIR
	MAN_DIR=/usr/share$MAN_DIR
fi

# un-install if '-R' is used
if [ $remove ]; then
	removeall
	exit 
fi

new_ver=$(grep "variable version" ./expect-lite | cut -d " " -f 3)

echo "=======================================" 
echo "Installing expect-lite version $new_ver"


#check if expect is installed in standard location
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


# don't move old version expect-lite if just configure only
if [ $configure_only ]; then
	#check if expect-lite is installed
	if [ -e $PREFIX/usr/bin/expect-lite ]; then
		existing_ver=$(grep "set version" $PREFIX$BIN_DIR/expect-lite | cut -d " " -f 3)
		echo "0)	==================="
		echo "	expect-lite already installed, good."
	else
		echo "0)	==================="
		echo "	expect-lite NOT installed"
		echo "	Please run installer with install option. Exiting..."
		exit 1
	fi
else
	#check if expect-lite is installed
	if [ -e $PREFIX/usr/bin/expect-lite ]; then
		existing_ver=$(grep "set version" $PREFIX$BIN_DIR/expect-lite | cut -d " " -f 3)
		echo "0)	==================="
		echo "	ACK! expect-lite already installed"
		echo "	Preservering older version $existing_ver to expect-lite.old"
		# back up older version
		mv $PREFIX/usr/bin/expect-lite $PREFIX/usr/bin/expect-lite.old
	fi
fi



# Actual Install. skip if configure only
if [ $configure_only ]; then
	echo "1,2,3)	==================="
	echo "	Configuration Only selected, skipping install steps 1,2,3 "

else
	# start actual install - Steps 1,2,3
	installit expect-lite $PREFIX$BIN_DIR "1"
	installit examples $PREFIX$DOC_DIR "2"
	cd man
	installit expect-lite.1.gz $PREFIX$MAN_DIR "3"
	cd - > /dev/null
	cd $START_PWD
fi



# run configure section as non-privilaged user
if [ "$USER" == "root" ]; then
	echo "SU)	==================="
	echo "	Calling install script as non-privilaged user $SUDO_USER for configuration"
	sudo -u $SUDO_USER $SUDO_COMMAND -c
	echo "=======================================" 
	echo "SU) Installation Complete!"
	echo "=======================================" 
	exit
fi

# test if bashrc needs mod: Step 4
mod_bash=$(grep expect-literc $BASHRC)
if [ "$mod_bash" == "" ]; then
	echo "4)	==================="
	echo "	Creating $HOME/.expect-literc with expect-lite defaults and "
	echo "	Updating $HOME/.bashrc file "
	# create expect-literc
	cp bashrc  $ELRC
	echo "source $ELRC" >> $BASHRC
	
	# Step 5
	#check if sshd is running - if so, then configure expect-lite to use ssh keys
	sshd_running=$(ps -e | grep sshd | wc -l)
	if [ $sshd_running -gt 0 ]; then
		echo "5)	==================="
		echo "	Configuring .expect-literc for SSH keys"
		# enable remote_host and connect_method
		sed -i -e 's;#export EL_REMOTE_HOST;export EL_REMOTE_HOST;' $ELRC
		sed -i -e 's;export EL_CONNECT_METHOD=none;export EL_CONNECT_METHOD=ssh_key;' $ELRC
		echo "	==================="
		echo "	be sure to 'source ~/.bashrc' to have changes take effect"
	fi
fi


# do the following for non-CYGWIN OSs
if [ "$OS" == "" ]; then
	#check if ssh keys already exist
	if [ ! -e $SSH_HOME/id_rsa.pub ]; then
		echo "==================="
		echo "Creating ssh keys as user: $USER"
		#su $SUDO_USER -c $TOOLS_DIR/setup_local_ssh.sh
		$TOOLS_DIR/setup_local_ssh.sh
	fi
fi


# Pau!
if [ "$SUDO_USER" != "root" ]; then
echo "=======================================" 
echo "Installation Complete!"
echo "=======================================" 
fi
