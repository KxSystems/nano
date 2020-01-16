# v1.18
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
	echo "Usage: multihost #numberthreads delete|keep [compress]"
	exit
fi
if [ $1 -le 0 ]
then
	echo "Usage: multihost #numberthreads delete|keep [compress]"
	exit
fi
for i in `cat $HOSTLIST`
do
	echo $i	
	ssh $i "cd ${HERE};./mthread.sh $1 $2 $3" &
done
wait

# summarise each of the aggregate scores into x host aggregate score
grep '^Streaming Read' ${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total Streaming Read Rate over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'ReRead' ${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total Re-Read from cache, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'Walking List Rate' ${DATE}/aggregates-* | awk '{print $4}' | awk '{sum+=$1} END {print "Total walking list rate, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'create list rate' ${DATE}/aggregates-* | awk '{print $5}' | awk '{sum+=$1} END {print "Total create list rate, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'random1m ' ${DATE}/aggregates-* | awk '{print $3}' | awk '{sum+=$1} END {print "Total random1m, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'random1mu' ${DATE}/aggregates-* | awk '{print $3}' | awk '{sum+=$1} END {print "Total random1mu, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'random64k ' ${DATE}/aggregates-* | awk '{print $3}' | awk '{sum+=$1} END {print "Total random64k, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
grep 'random64ku' ${DATE}/aggregates-* | awk '{print $3}' | awk '{sum+=$1} END {print "Total random64ku, over all hosts: ", sum, "MiB/sec"}' | tee -a ${HERE}/${DATE}/TOTAL
