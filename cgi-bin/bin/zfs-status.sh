#!/bin/sh
#
# Creates table from zfs list

OUTPUTDIR=/var/www/cgi-bin/tmp
for ZFSOUT in zfsstats zfspools
do 
	[[ ! -f $OUTPUTDIR/$ZFSOUT ]] && touch $OUTPUTDIR/$ZFSOUT && $OUTPUTDIR/$ZFSOUT
done
zfs list > $OUTPUTDIR/zfsstats
zpool list > $OUTPUTDIR/zfspools
