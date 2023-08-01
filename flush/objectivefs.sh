# an example with a network file system which hold its own cache.
# You will need to change this script for your networked file system under test
export WORKDIR=/nano
export FS=kdbfs
export CACHESIZE=80%
export OBJECTIVEFS_PASSPHRASE=kdbfs
MOUNT="mount.objectivefs -o mt"
UMOUNT=umount
if [ `uname -s` = "Darwin" ]
then
        purge
else
	$UMOUNT $WORKDIR
	sync; echo 3 > /proc/sys/vm/drop_caches
	$MOUNT $FS $WORKDIR
	sleep 60
	echo "Mount of ObjectiveFS finished..."
fi
