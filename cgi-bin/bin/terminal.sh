#!/bin/sh
PROCESS=something
while [[ "$PROCESS" != "" ]]
do
	ps -C "shellinaboxd" >> /var/www/cgi-bin/tmp/dothis
	PROCESS=$(ps -C "shellinaboxd"|grep -m1 "shellinaboxd"|grep -v "grep"| sed "s/p/?/g"|cut -d "?" -f1|tr -d " ")	
	echo "Process: $PROCESS" >> /var/www/cgi-bin/tmp/dothis
	[[ "$PROCESS" != "" ]] && kill -9 $PROCESS
done
shellinaboxd -t --css /usr/share/shellinabox/white-on-black.css --port 4202 -s ":docker:docker:/tmp:/bin/sh" &

