#!/bin/sh
#
# Creates table from zfs list

OUTPUTDIR=/var/www/cgi-bin/tmp
for ZFSOUT in zfsstats zfspools dockervols
do 
	[[ ! -f $OUTPUTDIR/$ZFSOUT ]] && touch $OUTPUTDIR/$ZFSOUT && chown :apache $OUTPUTDIR/$ZFSOUT
done
zfs list > $OUTPUTDIR/zfsstats
zpool list > $OUTPUTDIR/zfspools
docker inspect --format='{{json .GraphDriver.Data.Dataset}} {{.RepoTags}}' $(docker images -qa)|tr -d "\"[]" > $OUTPUTDIR/dockervols
docker inspect --format='{{json .GraphDriver.Data.Dataset}} {{.Name}}' $(docker ps -qa)|tr -d "\"[]"|sed "s, /, ,g" >> $OUTPUTDIR/dockervols

