#!/bin/sh
#
#while read TYPE RULE;do iptables -D $RULE;done < <(iptables -S|grep $PORT)
#
source /var/www/cgi-bin/source/functions.sh
unset PORTS
. /var/www/cgi-bin/tmp/globals
if [[ "$DEFAULTPORTS" == "" ]]
then
        for THISPORT in 22 23 80 1972 3389 4201 4202 8080 57772
        do
                append_global DEFAULTPORTS $THISPORT
        done
	. /var/www/cgi-bin/tmp/globals
fi

unset THISPORT
if [[ "$PORTS" == "" ]]
then
	. /var/www/cgi-bin/tmp/globals
        for THISPORT in $DEFAULTPORTS
        do
                append_global PORTS $THISPORT
        done
	. /var/www/cgi-bin/tmp/globals
fi

for CHAIN in IN_public_allow DOCKER
do
	for PORT in $PORTS
	do
		if [[ $(iptables -n -L $CHAIN|grep -c $PORT) -eq 0 ]]
		then
			iptables -A $CHAIN -p tcp --dport $PORT -j ACCEPT
		fi
	done
done

for PORT in $(iptables -n -L DOCKER|grep "dpt:"|cut -d":" -f2)
do 
	MATCH=false
	for THISPORT in $PORTS
	do
		if [[ "$THISPORT" == "$PORT" ]]
		then
			MATCH=true
			break
		fi
	done
	if [[ "$MATCH" == "false" ]]
	then
		iptables -D IN_public_allow -p tcp --dport $PORT -j ACCEPT
		iptables -D DOCKER -p tcp --dport $PORT -j ACCEPT
	fi
done



