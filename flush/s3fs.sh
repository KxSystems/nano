# an example with a network file system which hold its own cache.
# You will need to change this script for your networked file system under test
export WORKDIR=/nano
export FS=kxs3fs-test
MOUNT="/usr/local/bin/s3fs -o noatime -o use_cache=/tmp/s3fs -o ensure_diskfree=400 -o parallel_count=16"
UMOUNT=umount
if [ `uname -s` = "Darwin" ]
then
        purge
else
	$UMOUNT $WORKDIR
	sync; echo 3 > /proc/sys/vm/drop_caches
	sudo -u centos $MOUNT $FS $WORKDIR
fi
