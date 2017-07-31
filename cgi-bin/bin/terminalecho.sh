#!/bin/sh
. tmp/globals
OLDIFS=$IFS

while IFS= read TEXT
do
	echo "$TEXT"
	echo $TEXT > tmp/status
	[[ "$TERMTARGET" != "" ]] && [[ -e /dev/$TERMTARGET ]] && echo $TEXT > /dev/$TERMTARGET
done

