#!/bin/bash

cat base/blankheader
source source/functions.sh 2>&1
source source/filelist.sh 2>&1
. tmp/globals
THISROOT=$SCRIPTSDIR
#echo "Thisroot $THISROOT,$SCRIPTSDIR"
case "${REQUEST_METHOD}" in
	"POST")
		read INSTRUCTION
		CURRENTPATH=$(echo $INSTRUCTION|cut -d "&" -f1)
		INFO=$(echo $INSTRUCTION|cut -d "&" -f2)
		TYPE=$(echo $INFO|cut -d "=" -f1)
		VALUE=$(echo $INFO|cut -d "=" -f2)
		SUBMITTEDPATH=$(echo $CURRENTPATH|cut -d "=" -f2|sed "s,%2F,/,g")
		#echo CP $CURRENTPATH,INF $INFO,TY $TYPE,VAL $VALUE,SUB $SUBMITTEDPATH
		if [[ "$TYPE" == "dir" ]]
			then
			if [[ "$VALUE" == ".." ]]
			then
				if [[ "$SUBMITTEDPATH" == "$THISROOT" ]]
				then
					NEWPATH=$(echo $SUBMITTEDPATH)
				else
					NEWPATH=$(echo $SUBMITTEDPATH|rev|cut -d "/" -f2-|rev)
				fi
			else
				NEWPATH=$SUBMITTEDPATH/$VALUE
			fi
			THISPATH=$NEWPATH
			[[ "$NEWPATH" == "" ]] && NEWPATH=$THISROOT
			echo "<p class=\"instruction\">Choose software</p>"
			echo "<form action=\"./image-cacherun.cgi\" method=\"POST\"><table>"
			echo "<input type=\"hidden\" name=\"path\" value=\"$NEWPATH\">"
			[[ "$NEWPATH" != "$THISROOT" ]] && echo "<tr><td><img src=\"/images/parent-folder.png\" alt=\"PARENT FOLDER\" class=\"filelistlogo\"><input type=\"submit\" name=\"dir\" value=\"..\" class=\"filelisting\"></td></tr>"
			list_all $NEWPATH
			echo "</table></form>"
		else
			echo "<table align=\"center\"><tr>"
			echo "<td class=\"filelisting black\">Installer:</td>"
			echo "<td class=\"filelisting yellow\">$VALUE</td></tr>"
			INSTALLERPATH=$SUBMITTEDPATH
			INSTALLER=$VALUE
			write_global INSTALLERPATH
			write_global INSTALLER
			echo "<td><form action=\"./image-cacherun.cgi\" method=\"GET\">"
			echo "<input type=\"submit\" value=\"Cancel\" class=\"button gray\"></form></td></tr></table>"
		fi
        ;;
	*)
		docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}" > tmp/containers
		echo "<p class=\"instruction\">Choose a file to run as installer.</p>"
		echo "<form action=\"./image-cacherun.cgi\" method=\"POST\"><table>"
		echo "<input type=\"hidden\" name=\"path\" value=\"$THISROOT\">"
		list_all $THISROOT
		echo "</table></form>"
esac
cat base/footer
