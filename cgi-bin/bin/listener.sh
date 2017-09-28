#!/bin/bash
#
ROOTPATH=/var/www/cgi-bin
TRIGGER=$ROOTPATH/tmp/nag
JOBTRIGGER=$ROOTPATH/tmp/trigger
SCRIPTPATH=$ROOTPATH/bin
while :
do
	unset COMMAND
	unset DOTHIS
	while [[ "$COMMAND" == "" ]]
	do
		read -t 1 DOTHIS
 		[[ "$DOTHIS" != "" ]] && COMMAND=RUN
		[[ -f $TRIGGER ]] && COMMAND=SCRIPT
	done
	case $COMMAND in

		"RUN")
			source $ROOTPATH/source/functions.sh
			source $ROOTPATH/source/functions.sh
			. $ROOTPATH/tmp/globals
			#echo "RUN $DOTHIS"
			ACTION=$(echo $DOTHIS|cut -d "=" -f1)
			CONTAINER=$(echo $DOTHIS|cut -d "=" -f2)		
			#echo "docker $ACTION $CONTAINER"
			echo $DOTHIS >> $ROOTPATH/tmp/dothis
			case $ACTION in

				"console")
					kill -9 $(pgrep -o shellinaboxd)
					if [[ "$CONTAINER" != "J2DOCKERROOT" ]]
					then
						docker exec $CONTAINER bash -c "for PS in $(pgrep -t pts/0); do kill -9 ${PS};done"
						shellinaboxd -t --port 4202 -s ":tc::/tmp:bash -c \"/sbin/docker exec -it $CONTAINER /bin/sh\"" &
					fi
					echo ""
					echo "http://${HOSTIP}:4202"
					;;

				"noconsole")
					kill -9 $(pgrep -o shellinaboxd)
					docker exec $CONTAINER bash -c "for PS in $(pgrep -t pts/0); do kill -9 ${PS};done"
					echo ""
					echo "TERMHUP"
					;;

				"export")

					EXPORTCONTAINER=$CONTAINER
					write_global EXPORTCONTAINER
					echo "dockerexport.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
					;;

				"save")
					SAVECONTAINER=$CONTAINER
					write_global SAVECONTAINER
					echo "dockersave.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
					;;

				"commit")
					COMMITCONTAINER=$CONTAINER
					write_global COMMITCONTAINER
					echo "dockercommit.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
					;;

				"status")
					unset JOBSTATUS
					. $ROOTPATH/tmp/globals
					if [[ "$JOBSTATUS" != "" ]]
					then
						echo $JOBSTATUS|tr [a-z] [A-Z]
						delete_global JOBSTATUS
					fi
					;;

				"start")

					echo "docker $ACTION $CONTAINER"
					docker $ACTION $CONTAINER 2>&1
					unset THISIP
					while [[ "$THISIP" == "" ]]
					do
						THISIP=$(get_container_ip $CONTAINER)
						[[ "$THISIP" == "" ]] && sleep 0.5
					done
					echo "START=$THISIP" 
					echo "REFRESH"
					. $SCRIPTPATH/mclientupdate.sh
				;;
	
				"stop")

					STOPCONTAINER=$CONTAINER
					write_global STOPCONTAINER
					echo "dockerstop.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
				;;

				"delete")
					RMCONTAINER=$CONTAINER
					write_global RMCONTAINER
					echo "dockerrm.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
				;;

				"importroutine")
					CACHECONTAINER=$CONTAINER
					write_global CACHECONTAINER
					echo "dockercacheimport.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
                                        ;;

				"cachertn")
					INSTALLCONTAINER=$CONTAINER
					write_global INSTALLCONTAINER
					echo "cacheinstaller.sh" > $JOBTRIGGER
					echo ""
					echo "JOBBED"
					;;
				
				
				"post")
					RTNCONTAINER=$CONTAINER
					write_global RTNCONTAINER
					;;

				"checkclient")
					bash ${SCRIPTPATH}/mclientcheck.sh ${CONTAINER}
					;;
				"rejectclient")
					echo ${CONTAINER} >> ${ROOTPATH}/system/management_clients_declined
					echo "true"
					;;
				"acceptclient")
					echo
					;; 
				*)
					echo "RESEND $DOTHIS"
					#:: Received $DOTHIS.  No handler"
					#docker volume prune -f
					;;
			esac
			;;	

		"SCRIPT")
			DOTHIS=$(cat $TRIGGER)
			echo $DOTHIS>>$ROOTPATH/log
			. $SCRIPTPATH/$DOTHIS 
			chown root:root $TRIGGER
			rm -f $TRIGGER 
			#$(cat /var/www/cgi-bin/tmp/nag)
		;;


	esac

done

