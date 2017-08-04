#!/bin/sh
#
# Creates table from zfs list

OUTPUTDIR=/var/www/cgi-bin/tmp

#Clear current info

for ZFSOUT in zfsstats zfspools dockervols zfsusage
do 
	[[ -f $OUTPUTDIR/$ZFSOUT ]] && rm -rf $OUTPUTDIR/$ZFSOUT
	touch $OUTPUTDIR/$ZFSOUT && chown :apache $OUTPUTDIR/$ZFSOUT
done

zfs list > $OUTPUTDIR/zfsstats
zpool list > $OUTPUTDIR/zfspools
docker inspect --format='{{json .GraphDriver.Data.Dataset}} {{.RepoTags}}' $(docker images -qa)|tr -d "\"[]" > $OUTPUTDIR/dockervols
docker inspect --format='{{json .GraphDriver.Data.Dataset}} {{.Name}}' $(docker ps -qa)|tr -d "\"[]"|sed "s, /, ,g" >> $OUTPUTDIR/dockervols

while read NAME USED AVAIL REFER MOUNT
do
        unset CROSSREF
	unset STATUS
        CROSSREF=$(grep "$NAME " $OUTPUTDIR/dockervols|cut -d " " -f2)
        if [[ "$CROSSREF" != "" ]]
        then
                NAME=$CROSSREF
        else
                if [[ $(echo $NAME|grep -c "\-init") -ne 0 ]]
                then
                        unset THISREF
                        THISREF=$(echo $NAME|cut -d "-" -f1)
                        CROSSREF=$(grep "$THISREF" $OUTPUTDIR/dockervols|cut -d " " -f2)
                        [[ "$CROSSREF" != "" ]] && NAME="(${CROSSREF}-root)"
                fi
        fi
	if [[ "$CROSSREF" == "" && $(echo $NAME|grep -c "rpool/ROOT/") -ne 0 ]] 
	then
		echo "dockervol $AVAIL $REFER $MOUNT" >> $OUTPUTDIR/zfsusage
        fi
done < $OUTPUTDIR/zfsstats

