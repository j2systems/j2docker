#!/bin/sh
#
# Builds an images 

BASEDIR=/var/www/cgi-bin
TEMPLATEDIR=$BASEDIR/source/build
BUILDDIR=$BASEDIR/build
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Load
	echo -e "\n"|bin/terminalecho.sh

	echo "Starting load of $LOADFILE"|bin/terminalecho.sh
	echo "docker load -i $LOADPATH/$LOADFILE" |bin/terminalecho.sh
	docker load -i $LOADPATH/$LOADFILE 2>&1 |bin/terminalecho.sh
	echo "SCRIPT END"
        status "Ready"
	delete_global TERMTARGET
	delete_global LOADFILE
	delete_global LOADPATH


