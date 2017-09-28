#!/bin/bash

# sytem directories
WWWROOT=/var/www/cgi-bin
SOURCEPATH=${WWWROOT}/source
source ${SOURCEPATH}/functions.sh
BINPATH=${WWWROOT}/bin
SYSTEMPATH=${WWWROOT}/system
TMPPATH=${WWWROOT}/tmp

write_global WWWROOT
write_global BINPATH
write_global SYSTEMPATH
write_global TMPPATH

# Make sure config files in place 

for REFERENCE in management_clients known_ips
do
        if [[ ! -f ${CONFIGPATH}/${REFERENCE} ]]
	then
        	touch ${CONFIGPATH}/${REFERENCE}
        	chmod 666 ${CONFIGPATH}/${REFERENCE}
	fi
done


#Websocket
websocketd --port 4201 ${BINPATH}/listener.sh &

#Task runner
bash ${BINPATH}/listen.sh &

#DNS

# Sync time
ntpd -q -p 0.uk.pool.ntp.org

#Start apache                                                                              
                                                                                           
apachectl -k start 

# Start Docker
echo -n "Starting docker"                                                                     
export DOCKER_RAMDISK=true                                                                 
dockerd &
DOCKERSTATUS=$(docker info 2>&1|grep -c CPU)
while [[ ${DOCKERSTATUS} -eq 0 ]]
do
	echo -n "."
	sleep 1
	DOCKERSTATUS=$(docker info 2>&1|grep -c CPU)
done
echo
#configure networking and iptables
bash ${BINPATH}/networking.sh
bash ${BINPATH}/config.sh
