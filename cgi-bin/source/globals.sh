#!/bin/sh

# Globals - for functions, etc, for docker environment
# /tmp/globals - run before script to get current variables

ROOTPATH=/var/www/cgi-bin
GLOBALS=/var/www/cgi-bin/tmp/globals
[[ ! -f $GLOBALS ]] && touch $GLOBALS && chmod 777 $GLOBALS
	
write_global(){
#writes fresh global
	if [[ $(grep -c -e "^$1=" $GLOBALS) -eq 0 ]]
	then
		echo "$1=$(eval echo \$$1)" >> $GLOBALS
	else
		if [[ "$(grep -e "^$1=$(eval echo \$$1)" $GLOBALS)" != "$1=$(eval echo \$$1)" ]]
		then
			sed -i "s,$1=.*,$1=$(eval echo \$$1),g" $GLOBALS
		fi
	fi
}

delete_global(){
#deletes whole global
	[[ "$1" != "" ]] && sed -i "/^$1=/d" $GLOBALS
}

append_global(){
#appends to global
	local new
	if [[ "$1" != "" ]] && [[ "$2" != "" ]]
	then
		if  [[ $(grep -c -e "^$1=" $GLOBALS) -eq 0 ]] 
		then
			echo "$1=$2" >> $GLOBALS
		else
			
			if [[ $(grep $1 $GLOBALS|cut -d "=" -f2|grep -c $2) -eq 0 ]]
			then
				. /var/www/cgi-bin/tmp/globals
				new="$(eval echo \$$1) $2"
				delete_global $1
				echo -e "$1=\"$new\"" >> $GLOBALS
			fi
		fi
	fi
}

remove_entry_global(){
#removes entry from global
	if [[ "$1" != "" ]] && [[ "$2" != "" ]]
	then
		local REMOVE
		REMOVE=$(grep "$1=" /tmp/globals|cut -d "=" -f2|sed "s/$2//"|tr -s " "|sed "s/\ \"$/\"/"|sed "s/\"\ //"|sed "s/\"//g")
		delete_global $1
		if [[ "$REMOVE" != "" ]]
		then
			if [[ $(echo $REMOVE|grep -c " ") -eq 0 ]]
			then
				echo "$1=$REMOVE">>$GLOBALS
			else 
				echo -e "$1=\"$REMOVE\"" >>$GLOBALS
			fi
		fi
	fi
}
status() {
#writes a status message for system page
	echo $1 > tmp/status

}

open_terminal(){
	TERMPS=""
#waits for terminal
	while [[ "$TERMPS" == "" ]]
	do
		sleep 0.5
		TERMPS=$(ps -ef|grep -e "^docker"|grep -e "\ sh$"|tr -s " "|tail -1)
	done
	TERMPID=$(echo $TERMPS|cut -d " " -f2)
	TERMTARGET=$(echo $TERMPS|cut -d " " -f6)
	write_global TERMTARGET
	write_global TERMPID
}
close_terminal(){
#terminates terminal
	. $GLOBALS
	echo "Closing terminal session."|bin/terminalecho.sh
	echo "(Process $TERMPID)"|bin/terminalecho.sh
	. $GLOBALS
	kill -9 $TERMPID
        delete_global TERMTARGET
        delete_global TERMPID
	echo "Ready." > tmp/status
}
