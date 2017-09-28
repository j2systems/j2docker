#!/bin/bash

ROOTPATH=/var/www/cgi-bin
GLOBALS=/var/www/cgi-bin/tmp/globals
[[ ! -f $GLOBALS ]] && touch $GLOBALS && chmod 777 $GLOBALS
	
################################################################################
#
# Functions:
# 	to manage:
# 		hosts, routing, studio, atelier
#
#	informational:
#		Container IP address, 
# Note.  
#
# An "mc" is a management client, i.e. a host that is using the web portal 
# and has been configured for interaction by transfer of an rsa pub key.
#
################################################################################                                 

################################################################################
#
# 1. mc management
#
# function called as mcmanage <mcname> <what> <do> <details....>
#
# e.g.
# mcmanage my-machine hosts add my_container 192.168.5.6 
# will add a hosts entry of 
# 192.168.5.6 my_container #thisserver#
# to 
# my-machine
#
# 1.1 hosts management
#
# *nix derivatives use standard /etc/hosts.  
# Windows has been provided a script as the \ paths become very confusing due
# to the way these are parsed.
#
# A hosts entry will be:
# "<ipaddress> {tab} <name> {tab} #<this server hostname>#"
#
# The #<this server hostname># is used to purge entries.
# 
# A hosts entry of 
# "<server ip> {tab} <server hostname> {tab} #<server hostname>-admin#"
# will also be added so that the mc can communicate to this server by name.
# This is due to potential lack of DNS services as well as problems with 
# Windows DNS resolution.
# (Windows does not append a . by default, so any lightweight DNS solution will fail).
#
# 1.2 studio management
#
# Studio only runs on windows.
#
# 1.3 atelier management
#
# in progress
#
# 1.4 rdp management
#
# Only for Windows.  MAC and GNU Linux in progress. 
#
# 1.5 route management
#
# A route is added to the mc for the docker subnet.
#
################################################################################


mcmanage(){
	# $1=mc,$2=context, $3=command,$4.... detail
	local MCHOST=$1
	local COMMAND=$2
	local ACTION=$3
	local MCDETAIL=$(grep -e "^${MCHOST} " /var/www/cgi-bin/system/management_clients)
	[[ "${MCDETAIL}" == "" ]] && log "mcmanage failed to get ${MCHOST} details." && return 1
	local USERNAME=$(echo ${MCDETAIL}|cut -d " " -f 2)
	local MCTYPE=$(echo ${MCDETAIL}|cut -d " " -f 3)
	log "${MCHOST} ${COMMAND} ${ACTION}, (${MCTYPE}), $4 $5 $6 $7"
	case ${COMMAND} in
	"hosts")
		case ${ACTION} in
		"add")
			#Adds single host entry
			HOSTNAME=$(hostname)
			[[ "${HOSTNAME}" == "$4" ]] && HOSTNAME=${HOSTNAME}-admin 
			case ${MCTYPE} in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 HOSTS ADD $4 $5 ${HOSTNAME}"		
				;;
			"MAC"|"LINUX")
				if [[ $(ssh ${USERNAME}@${MCHOST} "cat /etc/hosts|grep -c -e \"\t$4\t\"") -ne 0 ]]
				then
					# Cannot sed -i so copy hosts, amend, copy back
					scp ${USERNAME}@${MCHOST}:/etc/hosts /tmp >/dev/null
					sed -i "/\t$7\t/d" /tmp/hosts
					scp /tmp/hosts ${USERNAME}@${MCHOST}:/etc/hosts >/dev/null
					rm /tmp/hosts
				fi
				ssh ${USERNAME}@${MCHOST} "echo \"$5\t$4\t#${HOSTNAME}#\" >> /etc/hosts"
				;;
			*)
				log "mcmange unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			esac
			;;
		"remove")
			case ${MCTYPE} in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 HOSTS REMOVE $4"			
				;;
			"MAC"|"LINUX")
				scp ${USERNAME}@${MCHOST}:/etc/hosts /tmp >/dev/null
			        sed -i "/\t$6\t/d" /tmp/hosts
				scp /tmp/hosts ${USERNAME}@${MCHOST}:/etc/hosts >/dev/null
				rm /tmp/hosts
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac		
			;;
		"purge")
			case ${MCTYPE} in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 HOSTS PURGE ${HOSTNAME}"
				;;
			"MAC"|"LINUX")
				scp ${USERNAME}@${MCHOST}:/etc/hosts /tmp >/dev/null
				sed -i "/\t#${HOSTNAME}#$/d" /tmp/hosts
				scp /tmp/hosts ${USERNAME}@${MCHOST}:/etc/hosts >/dev/null
				rm /tmp/hosts
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		*)
			log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
			;;
		esac
		;;
		
	"studio")
		case ${ACTION} in
		"add")
			case ${MCTYPE} in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 STUDIO ADD $4 ${HOSTNAME}" 
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		"remove")
			case $3 in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 STUDIO REMOVE $4"	
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;		
		"purge")
			case $3 in 
			"WINDOWS")
				${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 STUDIO PURGE ${HOSTNAME}"
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		esac
		;;
	"atelier")
		case ${ACTION} in
		"add")
			case ${MCTYPE} in 
			"WINDOWS")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"			
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		"remove")
			case ${MCTYPE} in 
			"WINDOWS")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"			
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;		
		"purge")
			case ${MCTYPE} in 
			"WINDOWS")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		esac
		;;
	"rdp")
		case ${ACTION} in
		"add")
			case ${MCTYPE} in 
			"WINDOWS")
				IPADDRESS=$(get_container_ip $4)
				if [[ "${IPADDRESS}" != "" ]]
				then
					ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 RDP ADD $4 ${HOSTNAME}"
				fi			
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		"remove")
			case ${MCTYPE} in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 RDP REMOVE $4 ${HOSTNAME}"			
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;		
		"purge")
			case ${MCTYPE} in 
			"WINDOWS")
				ssh ${USERNAME}@${MCHOST} powershell /c "./j2dconfig.ps1 RDP PURGE ${HOSTNAME}"
				;;
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
				;;
			esac
			;;
		*)
			log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8" 
			;;
		esac
		;;

	"route")
		DOCKERSUBNET=$(docker network inspect j2docker|grep Subnet|cut -d ":" -f2|cut -d "/" -f1|tr -d " \"")
		HOSTNIC=$(netstat -r|grep default|tr -s " "|cut -d " " -f8)
		HOSTIP=$(ifconfig ${HOSTNIC}|grep "inet "|tr -s " "|cut -d " " -f3|cut -d ":" -f2)
		case ${ACTION} in
		"add")
			case ${MCTYPE} in 
			"WINDOWS")
				if [[ $(ssh ${USERNAME}@${MCHOST} route print|grep -c ${DOCKERSUBNET}) -eq 0 ]]
				then		
					ssh ${USERNAME}@${MCHOST} route add ${DOCKERSUBNET} mask 255.255.255.0 $HOSTIP > /dev/null
				fi

				;;
			"MAC")
				if [[ $(ssh ${USERNAME}@${MCHOST} netstat -nr -f inet|grep -c ${DOCKERSUBNET}) -eq 0 ]]
				then
					log "route add ${DOCKERSUBNET}/24 ${HOSTIP}"
					ssh ${USERNAME}@${MCHOST} "route add ${DOCKERSUBNET}/24 ${HOSTIP}" 2>&1
				fi
				;;

			*)
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"                                                                   
				;;
			esac
			;;
		"remove")
			case ${MCTYPE} in 
			"WINDOWS")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"                                                                   
				;;			
			"MAC"|"LINUX")
				log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
				;;
			esac
			;;		
		*)
			log "mcmanage unhandled - $1,$2,$3,$4,$5,$6,$7,$8"
			;;
		esac
	esac
}

################################################################################                 
#
# 2. Miscellaneous environment management
#
################################################################################

# 2.1 Add to local hosts.  Let host communicate with other hosts by name 

add_host(){

	# Adds mc details to hosts
	# $1=IP $2=mc hostname
	sed -i "/$2/d" /etc/hosts
	echo $1 $2 >> /etc/hosts
}


################################################################################                                 
#
# 3. Informational
#
################################################################################

# 3.1 returns online\offline

client_status() {
	# $1 =mc
	unset PINGCOUNT
	if [[ "$(get_dns_entry $1)" != "" ]]
	then
		# Give 2 pings in case first ping invokes ARP request
		PINGCOUNT=$(ping -c 2 -w 1 $1 |grep -c "ttl")
		if [[ $PINGCOUNT -eq 0 ]]
		then
			echo "offline"
		else
			echo "online"
		fi
	else
		echo "offline"
	fi
}

# 3.2 IMAGE information

# 3.2.1 Container IP

get_container_ip(){
	# Get container IP address
	#$1=container name
	echo $(docker inspect $1|grep -A100 "Networks"|grep IPAddress|grep 172|cut -d ":" -f2|tr -d '," ')
}

# 3.2.2 ENTRYPOINT information

# 3.2.2.1 Is it Healthshare?

isHS(){
	# Using entrypoint set as /sbin/pseud-init to determine
	# $1=container name

	local ENTRYPOINT=$(docker inspect --format='{{json .Config.Entrypoint}}' $1|tr -d "[]\"")
	if [[ "$ENTRYPOINT" == "/sbin/pseudo-init" ]] 
	then
		echo "true"
	else
		echo "false"
	fi
}

# 3.2.2.1 Is it RDP?

isRDP(){
	# Using entrypoint set as /sbin/rdp to determine
	# $1=container name

	local ENTRYPOINT=$(docker inspect --format='{{json .Config.Entrypoint}}' $1|tr -d "[]\"")
	if [[ "$ENTRYPOINT" == "/sbin/rdp" ]]
	then
        	echo "true"
	else
        	echo "false"
	fi
}

################################################################################
#
# 4. Globals
# 
# Variables that are required in all components, i.e. web and scripts
# Most scripts (.sh and .cgi) run ". /var/www/cgi-bin/tmp/globals" to get
# up-to-date environment settings.
#
# These functions allow quick setting and modification within scripts.
#
################################################################################

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
                        if [[ $(echo +$(grep -e "^$1=" $GLOBALS|cut -d "=" -f2)+|tr " " "+"|grep -c "+$2+") -eq 0 ]]                              
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
                REMOVE=$(echo "+$(grep -e "^$1=" $GLOBALS|cut -d "=" -f2)+"|tr -d "\""|tr " " "+"|sed "s/+$2+/+/"|tr "+" " "|sed "s/^\ //"|sed "s/\ $//")
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




get_dns_entry(){
	#$1 = lookup value
	#returns <IP> <hostname> is found
	nslookup $1 2>&1|grep -A1 -e "^Name:\ *$1$"|grep "Address 1"|cut -d " " -f3-
}
################################################################################                                 
#



################################################################################


status() {
#writes a status message for system page
	echo $1 > tmp/status

}
######## NGINX

remove_nginx_entry() {
	local NGINXCONF=/var/www/cgi-bin/tmp/j2nginx.conf
        # $1=container
        local CONTAINER=$1
        local THISHOST=$(hostname)
        CONTAINERLINE=$(grep -n "${CONTAINER}.${THISHOST}.lan" $NGINXCONF|cut -d ":" -f1)
        STARTDELETE=$((${CONTAINERLINE}-2))
        ENDDELETE=$((${CONTAINERLINE}+4))
        sed -i "${STARTDELETE},${ENDDELETE}d" $NGINXCONF
}
add_nginx_entry() {
        # $1=container, $2=url $3=listenport $4=destination port
        local NGINXCONF=/var/www/cgi-bin/tmp/j2nginx.conf
        local THISHOST=$(hostname)
        local CONTAINER=$1
        [[ -f $NGINXCONF ]] && [[ $(grep -c "${CONTAINER}.${THISHOST}.lan" $NGINXCONF) -ne 0 ]] && remove_nginx_entry $1
        echo "server {" >> $NGINXCONF
        echo -e "\tlisten  $3;" >> $NGINXCONF
        echo -e "\tserver_name  $2;" >> $NGINXCONF
        echo -e "\tlocation  / {"  >> $NGINXCONF
        echo -e "\tproxy_pass\thttp://$1:$4/;"  >> $NGINXCONF
        echo -e "\t}" >> $NGINXCONF
        echo "}" >> $NGINXCONF
}
hosts_add_nginx() {
	# $1=type (Windows, Linux....)
	[[ "$1" == "" ]] && return 1
	TMPPATH=/var/www/cgi-bin/tmp
	THISIP=$(get_container_ip nginx)
	HOSTNAME=$(hostname)
	#echo $TMPPATH,$THISIP,$HOSTNAME
	if [[ -f $TMPPATH/j2nginx.conf ]]
	then
		for ADDHOST in $(grep "$(hostname).lan" $TMPPATH/j2nginx.conf|tr -s " "|cut -d " " -f2|tr -d ";")
		do
			#echo $TMPPATH/j2nginx.conf,$1,$THISIP,$ADDHOST
			if [[ "$1" == "WINDOWS" && "$THISIP" != "" ]]
			then
				echo "..\..\bin\amend_hosts.cmd ADD $THISIP $ADDHOST $HOSTNAME" >> $ROOTPATH/tmp/windowshost
			fi
		done
	fi
	if [[ -f $TMPPATH/nginxlb ]]
	then
		while read THISHOST other
		do
			ADDHOST=$(echo $THISHOST|cut -d ":" -f1)
			#echo $TMPPATH/j2nginx.conf,$1,$THISIP,$ADDHOST
			if [[ "$1" == "WINDOWS" && "$THISIP" != "" ]]
			then
				echo "..\..\bin\amend_hosts.cmd ADD $THISIP $ADDHOST $HOSTNAME" >> $ROOTPATH/tmp/windowshost
			fi
		done < $TMPPATH/nginxlb
	fi
	unset TMPPATH

}
dockerlogin() {
	. /var/www/cgi-bin/tmp/globals
	docker login -u $J2USER -p $J2PASS
}
dockerlogout() {
	docker logout > /dev/null
}

imagelocation() {
	#$1=full image name, eg j2systems/docker:test
	echo $(grep "$(echo $1|tr ":" " ")" /var/www/cgi-bin/tmp/images|cut -d " " -f3)
}

log(){
	echo $(date +"%Y-%m-%d %H:%M") "$1" >> /var/log/system.log
}
