#!/usr/bin/env bash

# an example with a network file system which hold its own cache.
# You will need to change this script for your networked file system under test
export WORKDIR=/mnt/kdb
export FS=nfs:/targetdir
MOUNT=mount.PLACEYOURNETWORKEDFS-HERE
UMOUNT=mount.PLACEYOURNETWORKEDFS-HERE
if [ `uname -s` = "Darwin" ]
then
        purge
else
	$UMOUNT $WORKDIR
	sync; echo 3 > /proc/sys/vm/drop_caches
	$MOUNT $FS $WORKDIR
fi
