# an example with a network file system which hold its own cache.
# You will need to change this script for your networked file system under test
export WORKDIR=/mnt/weka
export FS=default
MOUNT="mount -t wekafs $FS $WORKDIR"
UMOUNT="umount $WORKDIR"
if [ `uname -s` = "Darwin" ]
then
        purge
else
	# $UMOUNT
	sync; echo 3 > /proc/sys/vm/drop_caches
        # $MOUNT
fi
