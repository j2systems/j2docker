#!/bin/sh
#
# Imports an image 

BASEDIR=/var/www/cgi-bin
source $BASEDIR/source/functions.sh

cd $BASEDIR
. tmp/globals
#	Import
	# open_terminal
	[[ "$IMPORTNAME" == "" ]] && IMPORTNAME="new"
	echo "Starting import of $IMPORTFILE as $IMPORTNAME"|bin/terminalecho.sh
	echo "docker import $IMPORTPATH/$IMPORTFILE j2docker:$IMPORTNAME" |bin/terminalecho.sh
	docker import $IMPORTPATH/$IMPORTFILE j2docker:$IMPORTNAME 2>&1 |bin/terminalecho.sh
	echo "SCRIPT END"
	echo "SCRIPT END"
	delete_global TERMTARGET
	delete_global IMPORTFILE
	delete_global IMPORTPATH
	delete_global IMPORTNAME

