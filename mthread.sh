#!/usr/bin/env bash

set -euo pipefail

USAGE="Usage: $0 processnr full|readonly keep|delete [date]"


if [ $# -lt 3 ]; then
  echo "At least three parameters are mandatory"
	echo $USAGE
	exit 1
fi
if [ $1 -le 0 ]; then
	echo $USAGE
	exit 2
fi
if [ $1 -gt 256 ]; then
	echo "This test does not qualify results above 256 processes"
	exit 3
fi

if [ ! -f ${FLUSH} ]; then
	echo "${FLUSH} is missing"
	echo "please set environment varibale FLUSH to an existing flush scripts"
	exit 4
fi

NUMPROCESSES=$1
SCOPE="$2"
if [ "$#" -eq "4" ]; then
  echo "Date is set to $4"
  DATE=$4
else
	DATE=$(date +%m%d_%H%M)
fi

REALDATE=$(date +%m%d_%H%M)
HOST=$(uname -n)

PARFILE="./partitions"
NUMSEGS=`wc -l $PARFILE | awk '{print $1}'`
declare -a array
array=(`cat $PARFILE`)

RESDIR="${RESULTDIR}/${REALDATE}-${DATE}"
mkdir -p ${RESDIR}
echo "Results will be persisted in ${RESDIR}"
CURRENTLOGDIR="${LOGDIR}/${REALDATE}-${DATE}"
mkdir -p ${CURRENTLOGDIR}

RESFILEPREFIX=${RESDIR}/detailed-${HOST}-
AGGRRESFILE=${RESDIR}/aggregate-${HOST}.psv

LOGFILEPREFIX="${CURRENTLOGDIR}/RES-${HOST}-${NUMPROCESSES}t-"

function syncAcrossHosts {
	rm ${CURRENTLOGDIR}/sync-$HOST
	while [ `ls -l ./sync-* 2> /dev/null | wc -l` -ne 0 ]; do
	  sleep 0.5
    done
}

function notObjStore {
  if [[ $1 != s3://* && $1 != gs://* && $1 != ms://* ]]; then return 0; else return 1; fi
}

CONFIG=${RESDIR}/config.yaml
touch $CONFIG
yq -i ".env.COMPRESS=\"$COMPRESS\"" $CONFIG
yq -i ".env.THREADNR=$THREADNR" $CONFIG
yq -i ".env.PROCNR=$NUMPROCESSES" $CONFIG
yq -i ".env.FLUSH=\"$(basename $FLUSH)\"" $CONFIG
yq -i ".env.DBDIR=\"$(cat $PARFILE)\"" $CONFIG
yq -i ".nano.VERSION=\"$(yq '.dev' version.yaml)\"" $CONFIG
yq -i ".kdb.MAJOR=$($QBIN -q  <<< ".z.K" | tr -d f)" $CONFIG
yq -i ".kdb.MINOR=\"$($QBIN -q  <<< ".z.k")\"" $CONFIG
yq -i ".dbize.MEMUSAGETYPE=\"$MEMUSAGETYPE\"" $CONFIG
yq -i ".dbize.MEMUSAGEVALUE=$MEMUSAGEVALUE" $CONFIG
yq -i ".dbize.RANDOMREADFILESIZETYPE=\"$RANDOMREADFILESIZETYPE\"" $CONFIG
yq -i ".dbize.RANDOMREADFILESIZEVALUE=$RANDOMREADFILESIZEVALUE" $CONFIG
yq -i ".dbize.DBSIZE=\"$DBSIZE\"" $CONFIG
yq -i ".dbize.RANDOMREADSIZE=\"$RANDOMREADSIZE\"" $CONFIG
yq -i ".system.cpunr=$(nproc)" ${CONFIG}
yq -i ".system.memsize=\"$(grep MemTotal /proc/meminfo |tr -s ' ' | cut -d ' ' -f 2,3)\"" ${CONFIG}

CONTROLLERPORT=7000

if [ "$SCOPE" = "full" ]; then
  ######### WRITE TEST #########
  ${FLUSH}

  #
  # simple semaphore for completion checking for all hosts ...
  #
  touch ${CURRENTLOGDIR}/sync-$HOST

  echo
  echo "STARTING WRITE TEST"

  # important that this it outside this loop with "q prepare", as first time after a mount as the
  # fs may take a long time to start (S3 sync) and we want the wrtte processes to run in parallel
  j=0
  for i in `seq $NUMPROCESSES`; do
    if notObjStore ${array[$j]}; then
  	  mkdir -p ${array[$j]}/${HOST}.${i}/${DATE}
    fi
    echo "testtype|test|qexpression|starttime|endtime|result|unit" > ${RESFILEPREFIX}${i}.psv
  	j=$(( ($j + 1) % $NUMSEGS ))
  done

  ${QBIN} ./src/controller.q -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller 2 >&1 &
  j=0
  for i in `seq $NUMPROCESSES`; do
  	${QBIN} ./src/prepare.q -processes $NUMPROCESSES -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -s ${THREADNR} -q >> ${LOGFILEPREFIX}${i} 2 >&1 &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done

  wait -n
  wait

  sleep 1
  syncAcrossHosts

  sleep 5
fi

######### READ TEST #########

echo
echo "STARTING SEQUENTIAL READ TEST"
${FLUSH}
touch ${CURRENTLOGDIR}/sync-$HOST

${QBIN} ./src/controller.q -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller 2 >&1 &
j=0
for i in `seq $NUMPROCESSES`; do
	${QBIN} ./src/read.q -processes $NUMPROCESSES -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -s ${THREADNR} >> ${LOGFILEPREFIX}${i} 2>&1 &
  j=$(( ($j + 1) % $NUMSEGS ))
done
wait -n
wait

syncAcrossHosts

# air gap for any remote stats collection....
sleep 5

######### RE-READ TEST #########
# without flush, cached in kernel buffer, re-mapped...

echo
echo "STARTING SEQUENTIAL RE-READ (CACHE) TEST"

touch ${CURRENTLOGDIR}/sync-$HOST
${QBIN} ./src/controller.q -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller 2 >&1 &
j=0
for i in `seq $NUMPROCESSES`; do
	${QBIN} ./src/reread.q -processes $NUMPROCESSES -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -s ${THREADNR} >> ${LOGFILEPREFIX}${i} 2>&1  &
  j=$(( ($j + 1) % $NUMSEGS ))
done
wait

syncAcrossHosts

# air gap for any remote stats collection....
sleep 5

if [ "$SCOPE" = "full" ]; then
  ######### META DATA TEST #########
  echo
  echo "STARTING META DATA TEST"
  ${FLUSH}

  touch ${CURRENTLOGDIR}/sync-$HOST
  ${QBIN} ./src/controller.q -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller 2 >&1 &
  j=0
  for i in `seq $NUMPROCESSES`; do
  	${QBIN} ./src/meta.q -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -s ${THREADNR} >> ${LOGFILEPREFIX}${i} 2>&1  &
    j=$(( ($j + 1) % $NUMSEGS ))
  done

  wait
  syncAcrossHosts
fi

######### RANDOM READ TEST #########

function runrandomread {
  local listsize=$1
  local mmap=$2
  ${FLUSH}
  echo "test${mmap} with block size ${listsize}"

  touch ${CURRENTLOGDIR}/sync-$HOST
  ${QBIN} ./src/controller.q -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller 2 >&1 &
  j=0
  sleep 5
  for i in `seq $NUMPROCESSES`; do
  	${QBIN} ./src/randomread.q -listsize ${listsize} ${mmap} -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -testtype "read disk" -s ${THREADNR} -S ${SEED} >> ${LOGFILEPREFIX}${i} 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait

  ${QBIN} ./src/controller.q -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller 2 >&1 &
  j=0
  for i in `seq $NUMPROCESSES`; do
  	${QBIN} ./src/randomread.q -listsize ${listsize} ${mmap} -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -testtype "read mem" -s ${THREADNR} -S ${SEED} >> ${LOGFILEPREFIX}${i} 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait
  syncAcrossHosts
}

echo
echo "STARTING RANDOM READ TEST"
SEED=1
for listsize in 1000000 64000; do
	runrandomread $listsize " "
  SEED=$((SEED+1))
done
for listsize in 1000000 64000; do
	runrandomread $listsize " -withmmap"
  SEED=$((SEED+1))
done


echo "Aggregating results"
${QBIN} ./src/postproc.q -inputs ${RESFILEPREFIX} -processes ${NUMPROCESSES} -output ${AGGRRESFILE} -q

#
# an air gap for any storage stats gathering before unlinks go out ...
#
sleep 5
if [ "$3" = "delete" ]; then
	echo "cleaning up DB..."
	j=0
	for i in `seq $NUMPROCESSES`; do
    if notObjStore ${array[$j]}; then
		  rm -rf ${array[$j]}/${HOST}.${i}/${DATE}
    else
      if [[ ${array[$j]} == s3://* ]]; then
        aws s3 rm ${array[$j]}/${HOST}.${i}/${DATE} --recursive
      elif [[ ${array[$j]} == gs://* ]]; then
        gsutil rm -r ${array[$j]}/${HOST}.${i}/${DATE}
      elif [[ ${array[$j]} == ms://* ]]; then
        echo "Cleanup ${array[$j]}/${HOST}.${i}/${DATE} manually"
        echo "az storage fs directory delete -f YOURCONTAINER -n ${HOST}.${i}/${DATE} --account-name YOURSTORAGEACCOUNT"
      else
        echo "Unknown object storage prefix ${array[$j]::2}"
      fi
    fi
		j=$(( ($j + 1) % $NUMSEGS ))
	done
fi
rm -rf ./sync-*

sync ${RESDIR}
sync ${CURRENTLOGDIR}