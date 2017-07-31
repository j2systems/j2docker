#!/bin/sh
#
# Pulls an image 

BASEDIR=/var/www/cgi-bin
TEMPLATEDIR=$BASEDIR/source/build
BUILDDIR=$BASEDIR/build
source $BASEDIR/source/functions.sh
cd $BASEDIR
. tmp/globals
#	Pull Image
	# open_terminal
	status "Pulling $PULLIMAGE"
	echo "Starting pull of $PULLIMAGE"|bin/terminalecho.sh
	echo "docker pull $PULLIMAGE"|bin/terminalecho.sh
	docker pull $PULLIMAGE 2>&1|bin/terminalecho.sh
	echo "SCRIPT END"
	delete_global TERMTARGET
	delete_global PULLIMAGE
	echo "SCRIPT END"
	status "ready"
