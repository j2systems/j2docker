#!/bin/sh
#
# All-in-one script to update management clients.
# Called at boot and when summary and system pages are opened

SCRIPTBASE=/var/www/cgi-bin
SOMETHINGTODO=false
source $SCRIPTBASE/source/functions.sh

docker ps -a --format "{{.Names}} ({{.Image}}) {{.Status}}" > $SCRIPTBASE/tmp/containers

delete_global THESECONTAINERS
while read NAME IMAGE STATUS
do
	if [[ $(echo $STATUS|grep -c -e "^Up") -eq 1 ]]
	then
		SOMETHINGTODO=true
		append_global THESECONTAINERS $NAME
	fi
done < $SCRIPTBASE/tmp/containers


if [[ "$SOMETHINGTODO" == "true" ]]
then
	. $SCRIPTBASE/tmp/globals
	while read HOST USERNAME TYPE INTEGRATE STUDIO ATELIER
	do
		if [[ "$INTEGRATE" == "true" ]]
		then
			if [[ "$(client_status $HOST)" == "online" ]]
			then
				configure_routing $USERNAME $HOST $TYPE
				case $TYPE in

					"WINDOWS")
						[[ -f $SCRIPTBASE/tmp/windowshost ]] && rm -rf $SCRIPTBASE/tmp/windowshost
						#purge hosts
						purge_hosts $USERNAME $HOST
						#purge registry/atelier
						[[ "$STUDIO" == "true" ]] && purge_registry $USERNAME $HOST
						purge_rdp $USERNAME $HOST
						#add hosts/studio/atelier
						for THISCONTAINER in $THESECONTAINERS
						do		
							add_container $USERNAME $HOST $THISCONTAINER
							[[ "$STUDIO" == "true" && "$(isHS $THISCONTAINER)" == "true" ]] && add_registry $USERNAME $HOST $THISCONTAINER
							[[ "$(isRDP $THISCONTAINER)" == "true" ]] && add_rdp $USERNAME $HOST $THISCONTAINER
						done
						hosts_add_nginx $TYPE
						cat $SCRIPTBASE/tmp/windowshost|ssh $USERNAME@$HOST "cmd -c copy con"
						rm -rf $SCRIPTBASE/tmp/windowshost
						;;

					"LINUX")
						#purge hosts
						purge_hosts_linux $USERNAME $HOST
						#purge atelier
						#add hosts/studio/atelier
						get_hosts_linux $USERNAME $HOST
						for THISCONTAINER in $THESECONTAINERS
						do
							add_container_linux $THISCONTAINER
							#[[ "$ATELIER" == "true" ]] && add_registry $HST $UNAME $THISCONTAINER
						done		
						put_hosts_linux $USERNAME $HOST
						;;
				esac
			fi
		fi
	done < $SCRIPTBASE/tmp/management_clients
else
	#nothing is up so puge hosts
	while read HOST USERNAME TYPE INTEGRATE STUDIO ATELIER
	do
		if [[ "$INTEGRATE" == "true" ]]
		then
			if [[ "$(client_status $HOST)" == "online" ]]
			then
				case $TYPE in

					"WINDOWS")
						[[ -f $SCRIPTBASE/tmp/windowshost ]] && rm -rf $SCRIPTBASE/tmp/windowshost
						#purge hosts
						purge_hosts $USERNAME $HOST
						#purge registry/atelier
						[[ "$STUDIO" == "true" ]] && purge_registry $USERNAME $HOST  && purge_rdp $USERNAME $HOST
						cat $SCRIPTBASE/tmp/windowshost|ssh $USERNAME@$HOST "cmd -c copy con"
						;;

					"LINUX")
						#purge hosts
						purge_hosts_linux $USERNAME $HOST
						#purge atelier
						#add hosts/studio/atelier
					;;
				esac
			fi
		fi
	done < $SCRIPTBASE/tmp/management_clients
fi
				
