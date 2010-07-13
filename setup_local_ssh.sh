#!/bin/bash
#
# Script to setup local ssh keys
# Allows ssh to localhost without password
#
# by Craig Miller	24 February 2010
#


function usage {
               echo "	$0 - Used to setup local SSH Key (e.g. ssh to  \
	       		localhost without a password challenge) "
	       echo "	e.g. $0"
	       echo "	"
	       echo " By Craig Miller - Version: $VERSION"
	       exit 1
           }

# Script Defaults	   
numopts=0
VERSION=0.95
SSH_HOME=$HOME/.ssh


while getopts "vV" options; do
  case $options in
    V ) show_version=TRUE
    	let numopts+=1;;
    v ) show_version=TRUE
    	let numopts+=1;;
    h ) usage;;
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

#======== Actual work performed by script ============

#check if ssh is installed
if [ ! -x /usr/bin/ssh-keygen ]; then
	echo "==================="
	echo "ACK! ssh-keygen NOT installed!"
	echo "Please install ssh package before running $0"
	echo "==================="
	exit 1
fi

#check if keys already exist
if [ ! -e $SSH_HOME/id_rsa.pub ]; then

	mkdir -p $HOME/.ssh

	echo "==================="
	echo "Generating ssh keys"
	echo "==================="
	ssh-keygen -t rsa -N "" -f $SSH_HOME/id_rsa
fi

#check authorized_keys2
RESULT=""
if [ -e $SSH_HOME/authorized_keys2 ]; then
	TEMP=`cat $SSH_HOME/id_rsa.pub`
	RESULT=`grep "$TEMP" $SSH_HOME/authorized_keys2`
fi

#create authorized key
if [ "$RESULT" == "" ]; then
	echo "======================="
	echo "Creating Authorized Key"
	echo "======================="
	cd $SSH_HOME
	cat id_rsa.pub >> authorized_keys2
	#return to previous directory
	cd -
fi


echo "===============" 
echo "Testing SSH Key"
echo "===============" 
echo "ssh localhost"
# this also adds localhost to known_hosts file
ssh -o StrictHostKeyChecking=no localhost 'hostname; exit'
ssh -o StrictHostKeyChecking=no $HOSTNAME 'hostname; exit'


# Pau!
echo "=======================================" 
echo "Setup of SSH Key on localhost Complete!"
echo "=======================================" 
