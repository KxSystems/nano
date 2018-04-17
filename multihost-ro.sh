# v1.14
# the location where this is placed must be shareable between all nodes in the cluster
# output files will be stored and cannot be the same directory under test as we will unmount that
#
HERE=`pwd`
DATE=`date +%m%d:%H%M`
HOST=`uname -n`
HOSTLIST=`pwd`/hostlist
j=0
if [ $# -lt 2 ]
then
	echo "Usage: multihost-ro.sh #numberthreads premade-date"
	exit
fi
if [ $1 -le 0 ]
then
	echo "Usage: multihost-ro.sh #numberthreads premade-date"
	exit
fi
for i in `cat $HOSTLIST`
do
	echo $i	
	ssh $i "cd ${HERE};./mthread-ro.sh $1 $2" &
done
wait

# summarise each of the aggregate scores into x host aggregate score
grep '^Streaming Read' RO-${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total Streaming Read Rate over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/RO-${DATE}/TOTAL
grep '^Re-Read Cached' RO-${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total Re-Read from cache, over all hosts: ", sum, "MiB/sec"}' | tee -a RO-${HERE}/${DATE}/TOTAL
grep 'random1m ' RO-${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total random1m, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/RO-${DATE}/TOTAL
grep 'random1mu' RO-${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total random1mu, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/RO-${DATE}/TOTAL
grep 'random64k ' RO-${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total random64k, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/RO-${DATE}/TOTAL
grep 'random64ku' RO-${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total random64ku, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/RO-${DATE}/TOTAL
