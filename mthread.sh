#!/bin/bash
VERS=v2.0

USAGE="Usage: mthread #numberthreads full|readonly keep|delete [date]"

if [ $# -lt 3 ]; then
  echo "At least three parameters are mandatory"
	echo $USAGE
	exit
fi
if [ $1 -le 0 ]; then
	echo $USAGE
	exit
fi
if [ $1 -gt 256 ]; then
	echo "This test does not qualify results above 256 processes"
	exit
fi

if [ ! -f ./flush.sh ]; then
	echo "flush.sh is missing"
	echo "please copy and edit one of the supplied flush-* prototype scripts into the file flush.sh, edit it for your configuration, and try again"
	exit
fi

NUMTHREADS=$1
SCOPE="$2"
if [ "$#" -eq "4" ]; then
  echo "Date is set to $4"
  DATE=$4
else
	DATE=$(date +%m%d:%H%M)
fi

HERE=$(pwd)
source ./env
HOST=$(uname -n)
PARLIST="${HERE}/partitions"
MYID=$(id -u)
declare -a array

NUMSEGS=`wc -l $PARLIST | awk '{print $1}'`
array=(`cat $PARLIST`)

RESDIR=${HERE}/results/${DATE}
mkdir -p ${RESDIR}

RESFILEPREFIX="${RESDIR}/RES-${HOST}-${NUMTHREADS}t-"
AGGRFILE="${RESDIR}/aggregates-${HOST}"


function flush() {
	echo "flushing buffer cache....."
	if [ $MYID -eq 0 ]; then
		${HERE}/flush.sh
	else
		sudo ${HERE}/flush.sh
	fi
}

function syncAcrossHosts {
	rm ${HERE}/sync-$HOST
	while [ `ls -l ${HERE}/sync-* 2> /dev/null | wc -l` -ne 0 ]; do
	  sleep 0.5
    done
}


if [ "$SCOPE" = "full" ]; then
  ######### WRITE TEST #########
  flush

  #
  # simple semaphore for completion checking for all hosts ...
  #
  touch ${HERE}/sync-$HOST

  echo
  echo "STARTING WRITE TEST"
  echo "version $VERS" >> ${AGGRFILE}
  echo "numprocs $NUMTHREADS" >> ${AGGRFILE}
  echo "disk partitions $NUMSEGS" >> ${AGGRFILE}
  if [ ! -z "$COMPRESS"]; then
  	echo "Compressed data" >> ${AGGRFILE}
  fi

  # important that this it outside this loop with "q prepare",  as first time after a mount as the
  # fs may take a long time to start (S3 sync) and we want the wrtte processes to run in parallel
  j=0
  for i in `seq $NUMTHREADS`; do
  	mkdir -p ${array[$j]}/${HOST}.${i}/${DATE}
  	j=$(( ($j + 1) % $NUMSEGS ))
  done


  j=0
  for i in `seq $NUMTHREADS`; do
  	cd ${array[$j]}/${HOST}.${i}/${DATE}
  	${QBIN} ${HERE}/src/prepare.q -threads $NUMTHREADS | tee ${RESFILEPREFIX}${i} &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done

  wait
  echo "Files created"

  sleep 1
  syncAcrossHosts

  # air gap for any remote stats collection....
  THRU=$(grep 'sync write' ${RESFILEPREFIX}* | awk '{print $8}' | awk '{printf "%.0f\n",$1}' | sort -n | head -1)
  THRU=$(echo $THRU | awk '{printf "%.0f",$1}')
  THRU=$(expr $THRU \* $NUMTHREADS)
  echo "Total Write Rate(sync): " $THRU  " MiB/sec" 2>&1 | tee -a ${AGGRFILE}

  THRU=$(grep 'create list' ${RESFILEPREFIX}* | awk '{print $4}' | awk '{printf "%.0f\n",$1}' | sort -n | head -1)
  THRU=$(echo $THRU | awk '{printf "%.0f",$1}')
  THRU=$(expr $THRU \* $NUMTHREADS)
  echo  "Total create list rate:  " $THRU " MiB/sec" 2>&1 | tee -a ${AGGRFILE}

  sleep 5
fi

######### READ TEST #########

echo
echo "STARTING READ TEST"
flush
touch ${HERE}/sync-$HOST

j=0
for i in `seq $NUMTHREADS`; do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	${QBIN} ${HERE}/src/read.q >> ${RESFILEPREFIX}${i} 2>&1  &
  j=$(( ($j + 1) % $NUMSEGS ))
done
wait

ELAPSED=$(grep 'End thread -23! mapped read' ${RESFILEPREFIX}* | awk '{print $9}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
WALKIES=$(grep 'End thread walklist' ${RESFILEPREFIX}* | awk '{print $4}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
# Use filesize which is direct from real filesize from q, e.g compressed data
SIZE=$(grep '^filesize' ${RESFILEPREFIX}1 | awk '{print $2}')
SIZE=$(echo $SIZE | awk '{printf "%.0f",$1}')
# this is where we catch the process aggregation...
SIZE=$(expr $SIZE \* $NUMTHREADS )

echo $SIZE " " $ELAPSED " " $WALKIES | tee -a ${AGGRFILE}
echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/$2);print "Streaming Read(mapped) Rate: ", $1," MiB/sec"}' | tee -a ${AGGRFILE}
echo $SIZE $WALKIES | awk '{$1=sprintf("%5.2f",$1/$2);print "Walking List Rate: ", $1," MiB/sec"}' | tee -a ${AGGRFILE}

syncAcrossHosts

# air gap for any remote stats collection....
sleep 5

######### RE-READ TEST #########
# without flush, cached in kernel buffer, re-mapped...

echo
echo "STARTING RE-READ (CACHE) TEST"

touch ${HERE}/sync-$HOST
j=0
for i in `seq $NUMTHREADS`; do
	cd ${array[$j]}/${HOST}.${i}/${DATE}
	${QBIN} ${HERE}/src/reread.q -threads $NUMTHREADS >> ${RESFILEPREFIX}${i} 2>&1  &
  j=$(( ($j + 1) % $NUMSEGS ))
done
wait

#
ELAPSED=$(grep 'End thread -23! mapped reread' ${RESFILEPREFIX}* | awk '{print $6}'| awk '{printf "%.3f\n",$1/1000}' | sort -nr | head -1)
# Use filesize which is direct from real filesize from q, e.g compressed data
SIZE=$(grep '^filesize' ${RESFILEPREFIX}1 | awk '{print $2}')
SIZE=$(echo $SIZE | awk '{printf "%.0f",$1}')
# this is where we catch the process aggregation...
SIZE=$(expr $SIZE \* $NUMTHREADS )
echo $SIZE $ELAPSED
echo $SIZE $ELAPSED | awk '{$1=sprintf("%5.2f",$1/$2);print "Streaming ReRead(mapped) Rate: ", $1," MiB/sec"}' | tee -a ${AGGRFILE}

syncAcrossHosts

# air gap for any remote stats collection....
sleep 5

if [ "$SCOPE" = "full" ]; then
  ######### META DATA TEST #########
  echo
  echo "STARTING META DATE TEST"
  flush

  touch ${HERE}/sync-$HOST
  j=0
  for i in `seq $NUMTHREADS`; do
  	cd ${array[$j]}/${HOST}.${i}/${DATE}
  	${QBIN} ${HERE}/src/meta.q -threads $NUMTHREADS >> ${RESFILEPREFIX}${i} 2>&1  &
    j=$(( ($j + 1) % $NUMSEGS ))
  done

  wait
  syncAcrossHosts
fi

######### RANDOM READ TEST #########

function runrandomread {
  local listsize=$1
  local mmap=$2
  local mmapstring=$3
  local residx=$4
  declare -A sizeMap=( [1000000]=1M [64000]=64k )
  flush

  touch ${HERE}/sync-$HOST
  j=0
  sleep 5
  for i in `seq $NUMTHREADS`; do
  	cd ${array[$j]}/${HOST}.${i}/${DATE}
  	${QBIN} ${HERE}/src/randomread.q -listsize ${listsize} ${mmap} -threads $NUMTHREADS >> ${RESFILEPREFIX}${i} 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait
  THRU=$(grep "End random reads${mmapstring} ${listsize}" ${RESFILEPREFIX}* | cut -d" " -f ${residx} | awk '{printf "%.0f\n",$1}' | sort -n | head -1)
  THRU=$(echo $THRU | awk '{printf "%.0f",$1}')
  THRU=$(expr $THRU \* $NUMTHREADS)
  echo "Random ${sizeMap[${listsize}]}${mmapstring}: " $THRU  " MiB/sec" 2>&1 | tee -a ${AGGRFILE}
  syncAcrossHosts
}

echo
echo "STARTING RANDOM READ TEST"

for listsize in 1000000 64000; do
	runrandomread $listsize " " "" 6
done
for listsize in 1000000 64000; do
	runrandomread $listsize " -withmmap" " with mmaps" 8
done


#
# an air gap for any storage stats gathering before unlinks go out ...
#
sleep 5
if [ "$3" = "delete" ]; then
	echo "cleaning up DB..."
	j=0
	for i in `seq $NUMTHREADS`; do
		rm -rf ${array[$j]}/${HOST}.${i}/${DATE}
		j=$(( ($j + 1) % $NUMSEGS ))
	done
fi
rm -rf ${HERE}/sync-*
