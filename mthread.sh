#!/bin/bash
VERS=v1.16
# usage mthread.sh numthreads keep|delete [compress]
HERE=`pwd`
echo please set PATH and QHOME at top of this script, to include q dirs, then comment out these two lines and re-run mthread.sh
exit
export QHOME=/home/kx/
export PATH=$PATH:$QHOME/l64
export QBIN="$QHOME/l64/q"
#
DATE=`date +%m%d:%H%M`
HOST=`uname -n`
PARLIST=${HERE}/partitions
MYID=`id -u`
declare -a array
if [ $# -lt 2 ]
then
	echo "Usage: mthread #numberthreads keep|delete [compress]"
	exit
fi
if [ $1 -le 0 ]
then
	echo "Usage: mthread #numberthreads keep|delete [compress]"
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

echo "flushing buffer cache before file creations" 
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
j=0
CW=$(expr 800 / $NUMTHREADS)

mkdir -p ${HERE}/${DATE} 


# WRITE TEST .......................
cd $HERE

echo Starting write...
echo "version $VERS" >> ${HERE}/${DATE}/aggregates-${HOST}
echo "numprocs $NUMTHREADS" >> ${HERE}/${DATE}/aggregates-${HOST}
echo "disk partitions $NUMSEGS" >> ${HERE}/${DATE}/aggregates-${HOST}
if [ "$3" = "compress" ]
then
	echo "Compressed data" >> ${HERE}/${DATE}/aggregates-${HOST}
fi
START=$(date +%s%3N)
# important that this it outside this loop with "q prepare",  as first time after a mount as the 
# fs may take a long time to start (S3 sync) and we want the wrtte processes to run in parallel
for i in `seq $NUMTHREADS`
do
	mkdir -p ${array[$j]}/${HOST}.${i}/${DATE} 
	j=`expr $j + 1`	
	if [ $j -ge $NUMSEGS ]
	then
		j=0
	fi 
done
j=0
for i in `seq $NUMTHREADS`
do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	if [ "$3" = "compress" ]
	then
		${QBIN} ${HERE}/io.q -prepare -compress -threads $NUMTHREADS | tee ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-${i}  &
	else

		${QBIN} ${HERE}/io.q -prepare -threads $NUMTHREADS | tee ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-${i} &
	fi
	cd -
	j=`expr $j + 1`	
	if [ $j -ge $NUMSEGS ]
	then
		j=0
	fi 
		
done
wait
echo "flushing buffer cache....."
if [ $MYID -eq 0 ]
then
	./flush.sh
else
	sudo ./flush.sh
fi
sleep 1
rm ${HERE}/sync-$HOST

#
# sync up across multiple host testing...
#
while [ `ls -l ${HERE}/sync-* 2> /dev/null | wc -l` -ne 0 ]
do
	sleep 0.5
done


# air gap for any remote stats collection....
cd ${HERE}
THRU=$(grep 'async write' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $5}' | awk '{printf "%.0f\n",$1}' | sort -n | head -1)
THRU=$(echo $THRU | awk '{printf "%.0f",$1}')
THRU=$(expr $THRU \* $NUMTHREADS)
echo "Total Write Rate(async): " $THRU  " MiB/sec" 2>&1 | tee -a ${HERE}/${DATE}/aggregates-${HOST}

THRU=$(grep 'create list' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $4}' | awk '{printf "%.0f\n",$1}' | sort -n | head -1)
THRU=$(echo $THRU | awk '{printf "%.0f",$1}')
THRU=$(expr $THRU \* $NUMTHREADS)
echo  "Total create list rate:  " $THRU " MiB/sec" 2>&1 | tee -a ${HERE}/${DATE}/aggregates-${HOST}

sleep 5
#
# READ test................................................
#
echo Starting read tests...
#
# simple semaphore for completion checking for all hosts ... 
#
touch ${HERE}/sync2-$HOST
j=0
cd $HERE
for i in `seq $NUMTHREADS`
do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	${QBIN} ${HERE}/io.q -read -threads $NUMTHREADS >> ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
	j=`expr $j + 1`
        if [ $j -ge $NUMSEGS ]
        then
                j=0
	fi
done
wait

#
j=0
ELAPSED=$(grep 'End thread -23! mapped read' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $6}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
WALKIES=$(grep 'End thread walklist' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $4}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
# Use filesize which is direct from real filesize from q, e.g compressed data
SIZE=$(grep '^filesize' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-1 | awk '{print $2}')
SIZE=$(echo $SIZE | awk '{printf "%.0f",$1}')
# this is where we catch the process aggregation...
SIZE=$(expr $SIZE \* $NUMTHREADS )

echo $SIZE " " $ELAPSED " " $WALKIES | tee -a ${HERE}/${DATE}/aggregates-${HOST}
echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/$2);print "Streaming Read(mapped) Rate: ", $1," MiB/sec"}' | tee -a ${HERE}/${DATE}/aggregates-${HOST}
echo $SIZE $WALKIES | awk '{$1=sprintf("%5.2f",$1/$2);print "Walking List Rate: ", $1," MiB/sec"}' | tee -a ${HERE}/${DATE}/aggregates-${HOST}
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
# REREAD test for fresh kdb+ session, without flush, cached in kernel buffer, re-mapped...
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
	${QBIN} ${HERE}/io.q -reread -threads $NUMTHREADS >> ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
	j=`expr $j + 1`
        if [ $j -ge $NUMSEGS ]
        then
                j=0
	fi
done
wait

#
j=0
ELAPSED=$(grep 'End thread -23! mapped reread' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-* | awk '{print $6}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
# Use filesize which is direct from real filesize from q, e.g compressed data
SIZE=$(grep '^filesize' ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-1 | awk '{print $2}')
SIZE=$(echo $SIZE | awk '{printf "%.0f",$1}')
# this is where we catch the process aggregation...
SIZE=$(expr $SIZE \* $NUMTHREADS )
echo $SIZE $ELAPSED
echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/$2);print "Streaming ReRead(mapped) Rate: ", $1," MiB/sec"}' | tee -a ${HERE}/${DATE}/aggregates-${HOST}
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
#  META DATA tests.......................................................
#
echo Starting metadata tests...
#
# simple semaphore for completion checking for all hosts ... 
#
touch ${HERE}/sync2-$HOST
j=0
cd $HERE
for i in `seq $NUMTHREADS`
do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	${QBIN} ${HERE}/io.q -meta -threads $NUMTHREADS >> ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
	j=`expr $j + 1`
        if [ $j -ge $NUMSEGS ]
        then
                j=0
	fi
done
wait
#
rm -f ${HERE}/sync2-$HOST
while [ `ls -l ${HERE}/sync2-* 2> /dev/null | wc -l` -ne 0 ]
do
	sleep 0.5
done

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
	echo -n "$FUNC ..." | tee -a ${HERE}/${DATE}/aggregates-${HOST}
	sleep 5
	for i in `seq $NUMTHREADS`
	do
		cd ${array[$j]}/${HOST}.${i}/${DATE}
		${QBIN} ${HERE}/io.q -${FUNC} -threads $NUMTHREADS >> ${HERE}/${DATE}/RES-${HOST}-${NUMTHREADS}t-${i} 2>&1  &
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
	echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/($2/1000));print ":  ", $1," MiB/sec"}' | tee -a ${HERE}/${DATE}/aggregates-${HOST}
	
	rm ${HERE}/sync2-$HOST
	while [ `ls -l ${HERE}/sync2-* 2> /dev/null | wc -l` -ne 0 ]
	do
		sleep 0.5
	done
	#
	#
	sleep 3
	echo "flushing buffer cache after running test ${FUNC} ....."
	cd $HERE
	if [ $MYID -eq 0 ]
	then
		./flush.sh
	else
		sudo ./flush.sh
	fi
done


#
# an air gap for any storage stats gathering before unlinks go out ...
#
sleep 5
if [ "$2" = "delete" ]
then
	echo "cleaning up DB..."
	j=0
	for i in `seq $NUMTHREADS`
	do
		rm -rf ${array[$j]}/${HOST}.${i}/${DATE}
		j=`expr $j + 1`
	        if [ $j -ge $NUMSEGS ]
	        then
	                j=0
		fi
	done
fi
rm -rf ${HERE}/sync-*
