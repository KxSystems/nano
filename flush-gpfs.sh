# an example for GPFS network file system for which client may hold its own cache/state.
# change this...
GPFSNAME=nanotest
echo "unmounting gpfs file systems..."
# note - do not do -a flag as we probably are running this on all distributed nodes stated in hostlist file
mmumount $WORKDIR
sync; echo 3 > /proc/sys/vm/drop_caches
echo "Mounting GPFS file systems..."
mmmount $GPFSNAME 

