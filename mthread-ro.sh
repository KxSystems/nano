#!/bin/bash
VERS=v1.16
HERE=`pwd`
# echo please set PATH and QHOME at top of this script, to include q dirs, then comment out these two lines and re-run mthread-ro.sh
# exit
export QHOME=/home/kx/
export PATH=$PATH:$QHOME/l64
export QBIN="$QHOME/l64/q"
#
REALDATE=`date +%m%d:%H%M`
HOST=`uname -n`
PARLIST=${HERE}/partitions
MYID=`id -u`
declare -a array
if [ $# -lt 2 ]
then
	echo "Usage: mthread-ro #numberthreads date-to-read"
	exit
fi
if [ $1 -le 0 ]
then
	echo "Usage: mthread-ro #numberthreads date-to-read"
	exit
fi
if [ $1 -gt 64 ]
then
	echo "This test does not qualify results above 64 processes"
	exit
fi

if [ -f ./flush.sh ]
then
	:
else
	echo "flush.sh is missing"
	echo "please copy and edit one of the supplied flush-* prototype scripts into the file flush.sh, edit it for your configuration,  and try again"
	exit
fi

echo "flushing buffer cache" 
if [ $MYID -eq 0 ]
then
	echo umount and flush.sh
	./flush.sh
else
	echo umount and flush via sudo ./flush.sh
	sudo ./flush.sh
fi
touch ${HERE}/sync-$HOST
NUMSEGS=`wc -l $PARLIST | awk '{print $1}'`
array=(`cat $PARLIST`)
TARGETROOT=`dirname ${array[0]}`
NUMTHREADS=$1
DATE=$2
j=0

mkdir -p ${HERE}/RO-${REALDATE} 


echo "version $VERS" >> ${HERE}/RO-${REALDATE}/aggregates-${HOST}
echo "numprocs $NUMTHREADS" >> ${HERE}/RO-${REALDATE}/aggregates-${HOST}
echo "disk partitions $NUMSEGS" >> ${HERE}/RO-${REALDATE}/aggregates-${HOST}
tail -1 $PARLIST >> ${HERE}/RO-${REALDATE}/aggregates-${HOST}

#
# READ test................................................
#
echo Starting read tests...
#
# simple semaphore for completion checking for all hosts ... 
#
# for this exercise, a hard coded date for RO is "something we prepared earlier"

touch ${HERE}/sync2-$HOST
j=0
cd $HERE
for i in `seq $NUMTHREADS`
do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	q ${HERE}/io.q -read -threads $NUMTHREADS >> ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
	j=`expr $j + 1`
        if [ $j -ge $NUMSEGS ]
        then
                j=0
	fi
done
wait

j=0
ELAPSED=$(grep 'End thread -23! mapped read' ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $6}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
# Use filesize which is direct from real ilesize from q, v.useful for compressed data
WALKIES=$(grep 'End thread walklist' ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $4}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
SIZE=$(grep '^filesize' ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-1 | awk '{print $2}')
SIZE=$(echo $SIZE | awk '{printf "%.0f",$1}')
# this is where we catch the process aggregation...
SIZE=$(expr $SIZE \* $NUMTHREADS)

echo $SIZE " " $ELAPSED " " $WALKIES | tee -a ${HERE}/RO-${REALDATE}/aggregates-${HOST}
echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/$2);print "Streaming Read(mapped) Rate: ", $1," MiB/sec"}' | tee -a ${HERE}/RO-${REALDATE}/aggregates-${HOST}
echo $SIZE $WALKIES | awk '{$1=sprintf("%5.2f",$1/$2);print "Walking List Rate: ", $1," MiB/sec"}' | tee -a ${HERE}/RO-${REALDATE}/aggregates-${HOST}
rm -f ${HERE}/sync-$HOST
#
# sync up across multiple host testing...
#
while [ `ls -l ${HERE}/sync-* 2> /dev/null | wc -l` -ne 0 ]
do
	sleep 0.5
done
# air gap for any remote stats collection....

sleep 5
#
# REREAD test for fresh kdb+ session, without flush, cached in kernel buffer, re-mapped
#
echo "Starting Re-Read (Cache) tests..."
#
# simple semaphore for completion checking for all hosts ... 
#
touch ${HERE}/sync2-$HOST
j=0
cd $HERE
for i in `seq $NUMTHREADS`
do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	q ${HERE}/io.q -reread -threads $NUMTHREADS >> ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
	j=`expr $j + 1`
        if [ $j -ge $NUMSEGS ]
        then
                j=0
	fi
done
wait

j=0
ELAPSED=$(grep 'End thread -23! mapped reread' ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $6}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
# Use filesize which is direct from real ilesize from q, v.useful for compressed data
SIZE=$(grep '^filesize' ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-1 | awk '{print $2}')
SIZE=$(echo $SIZE | awk '{printf "%.0f",$1}')
# this is where we catch the process aggregation...
SIZE=$(expr $SIZE \* $NUMTHREADS)
echo $SIZE $ELAPSED
echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/$2);print "Streaming ReRead(mapped) Rate: ", $1," MiB/sec"}' | tee -a ${HERE}/RO-${REALDATE}/aggregates-${HOST}

rm -f ${HERE}/sync-$HOST
#
# sync up across multiple host testing...
#
while [ `ls -l ${HERE}/sync-* 2> /dev/null | wc -l` -ne 0 ]
do
	sleep 0.5
done

# air gap for any remote stats collection....
sleep 5

echo "flushing buffer cache....."
cd $HERE
if [ $MYID -eq 0 ]
then
	./flush.sh
else
	sudo ./flush.sh
fi

for FUNC in random1m random64k random1mu random64ku
do
#
#
	touch ${HERE}/sync2-$HOST
	j=0
	cd $HERE
	echo -n "$FUNC ..." | tee -a ${HERE}/RO-${REALDATE}/aggregates-${HOST}
	sleep 5
	for i in `seq $NUMTHREADS`
	do
		cd ${array[$j]}/${HOST}.${i}/${DATE}
		q ${HERE}/io.q -${FUNC} -threads $NUMTHREADS >> ${HERE}/RO-${REALDATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
		j=`expr $j + 1`
	        if [ $j -ge $NUMSEGS ]
	        then
	                j=0
		fi
	done
	START=$(date +%s%3N)
	wait

#	100 M longs x 8 bytes... 

	FINISH=$(date +%s%3N)
	ELAPSED=$(expr $FINISH - $START)
	SIZE=$(( 800 * $NUMTHREADS ))
	echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/($2/1000));print ":  ", $1," MiB/sec"}' | tee -a ${HERE}/RO-${REALDATE}/aggregates-${HOST}
	
	rm ${HERE}/sync2-$HOST
	while [ `ls -l ${HERE}/sync2-* 2> /dev/null | wc -l` -ne 0 ]
	do
		sleep 0.5
	done
	#
	#
	sleep 1
	echo "flushing buffer cache after running test ${FUNC} ....."
	cd $HERE
	if [ $MYID -eq 0 ]
	then
		./flush.sh
	else
		sudo ./flush.sh
	fi
done


rm -rf ${HERE}/sync-*
