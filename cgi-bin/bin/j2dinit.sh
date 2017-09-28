#!/bin/bash

# init script to configure environment
# if no first_run exists, create zfs  drive and directIO vol

# $MOUNTDRIVE exported from /opt/bootlocal.sh

if [[ ! -f ${MOUNTDRIVE}/first_run ]]
then
	clear
	echo "First run.  This will check and configure zfs volumes"
	echo
	echo "Stage 1. check disk available for ZFS.  This should be /dev/?db"
	echo
	DRIVEPREFIX=$(echo ${MOUNTDRIVE}|cut -d "/" -f3|cut -c 1)
	DEVICE=/dev/${DRIVEPREFIX}db
	echo "Checking for ${DEVICE}"
	echo
	if [[ "$(fdisk -l | grep ${DEVICE})" == "" ]]
	then
		echo "Storage disk not found."
		echo "To continue, shut down the machine, add a (recommended) 50G drive"
		echo "and start the machine"
		exit
	fi
	echo "${DEVICE} found."
	echo
	echo -n "Checking for any existing docker zfs volumes..."
	if [[ $(zfs list|grep -c docker) -eq 0 ]]
	then
		echo "not found."
		echo
		echo "Creating docker volume"
		echo
		zpool create -f docker -m /var/lib/docker ${DEVICE}
		if [[ $(zfs list|grep -c docker) -eq 0 ]]
		then
			echo "Could not create zfs docker."
			echo "Command attempted:"
			echo "zpool create -f docker -m /var/lib/docker ${DEVICE}"
			echo
			echo "Check dmesg."
			echo
			exit
		else
			echo "Created docker pool."
			zfs list
		fi
	else
		echo "found."
		echo
	fi
	echo -n "Checking for directIO volume..."                             
	if [[ $(zfs list|grep -c directIO) -eq 0 ]]
	then
		echo "not found."
		echo "Creating directIO volume and formatting as xfs."
		echo
		zfs create -V 10G docker/directIO
		mkfs.zfs /dev/zvol/docker/directIO
		echo "Created."
		echo
	else
		echo "found." 
	fi
	touch ${MOUNTDRIVE}/first_run 
fi
# mount cgroups and volumes
echo "Mounting cgroups and volumes"

# cgroups
bash cgroupfs-mount 

# Wait for IP address
HOSTIP=$(ifconfig eth0|grep "inet addr"|tr -s " "|cut -d ":" -f2|cut -d " " -f1)
while [[ "$HOSTIP" == "" ]]                                                     
do                                                                                                 
        sleep 1                                                                                    
        HOSTIP=$(ifconfig eth0|grep "inet addr"|tr -s " "|cut -d ":" -f2|cut -d " " -f1)        
done   
# www                                                                                   
[[ ! -d /var/www ]] && mkdir /var/www                                                   
mount --bind ${MOUNTDRIVE}/web/www /var/www                                             
                                                                                        
mount /dev/zvol/docker/directIO /var/lib/docker/volumes                                 
                                                                                        
vmhgfs-fuse -o allow_other /mnt/hgfs                                                    

source /var/www/cgi-bin/source/functions.sh
write_global HOSTIP
ln -s /usr/local/etc/ssl/certs /etc/ssl

#Start websocket, job listener, apache, zfs and docker 
echo "Starting interaction services"                             
nohup /var/www/cgi-bin/bin/init.sh >> /var/log/system.log & 

echo "try http://$(hostname)"
echo "or"
echo "http://${HOSTIP}/"

