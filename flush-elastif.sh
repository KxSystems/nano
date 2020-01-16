# an example with a network file system which hold its own cache.
# You will need to change this script for your networked file system under test

export WORKDIR=/mnt/test
# define a list of targets here, if you use multiple mounts on same FS
parts=(zero 10.128.0.61:/nano-testing/root 10.128.0.62:/nano-testing/root 10.128.0.63:/nano-testing/root 10.128.15.192:/nano-testing/root 10.128.15.193:/nano-testing/root 10.128.15.194:/nano-testing/root)
# mount 10.229.255.1:/nano-testing/root /mnt/test
SERVERNODES=6
MOUNT=mount
UMOUNT=umount
if [ `uname -s` = "Darwin" ]
then
        purge
else
	for i in $(seq $SERVERNODES)
	do
		$UMOUNT $WORKDIR${i}
	done
	sync; echo 3 > /proc/sys/vm/drop_caches
	for i in $(seq $SERVERNODES)
	do
		$MOUNT ${parts[i]} $WORKDIR${i}
	done
fi
