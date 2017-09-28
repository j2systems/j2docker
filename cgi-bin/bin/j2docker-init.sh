#!/bin/sh

# reduce selinux
setenforce 0

# wait for docker service to be up before opening firewall ports

SERVICECHK=$(systemctl is-active docker)
while [[ "${SERVICECHK}" != "active" ]]
do
	sleep 1
	SERVICECHK=$(systemctl is-active docker)
done
unset SERVICECHK
[[ ! -f /var/www/cgi-bin/tmp ]] && mkdir /var/www/cgi-bin/tmp && chmod 777 /var/www/cgi-bin/tmp
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

. ${BINPATH}/config.sh
. ${BINPATH}/networking.sh
. ${BINPATH}/dockerhub.sh
. ${BINPATH}/zfs-status.sh
. ${TMPPATH}/globals
[[ "$SCRIPTSDIR" == "" ]] && SCRIPTSDIR=/mnt/hgfs && write_global SCRIPTSDIR
[[ "$OUTDIR" == "" ]] && OUTDIR=$(ls -al /mnt/hgfs|grep -e "^d"|grep -v -e "\.$"|head -1|rev|cut -d " " -f1|rev) && write_global OUTDIR
# get username and pass
if [[ -f /tmp/creds.sh ]]
then
        . /tmp/creds.sh
	write_global J2USER
	write_global J2PASS
fi
cd /var/www
#git pull j2docker master > /dev/null

