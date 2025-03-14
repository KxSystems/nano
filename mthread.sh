#!/usr/bin/env bash

set -euo pipefail

readonly USAGE="Usage: $0 processnr full|readonly keep|delete [date]"


if [ $# -lt 3 ]; then
  echo "At least three parameters are mandatory"
	echo $USAGE
	exit 1
fi
if [ "$1" -le 0 ]; then
	echo $USAGE
	exit 2
fi
if [ "$1" -gt 256 ]; then
	echo "This test does not qualify results above 256 processes"
	exit 3
fi

if [ ! -f ${FLUSH} ]; then
	echo "${FLUSH} is missing"
	echo "please set environment varibale FLUSH to an existing flush scripts"
	exit 4
fi

readonly NUMPROCESSES=$1
readonly SCOPE="$2"
readonly KEEPDELETE=$3

if [ "$#" -eq "4" ]; then
  echo "Date is set to $4"
  DATE="$4"
else
	DATE=$(date +%m%d_%H%M%S)
fi

readonly CONTROLLERPORT=5100
if nc -z 127.0.0.1 $CONTROLLERPORT 2>&1 > /dev/null; then
  echo "Port $CONTROLLERPORT is used. Maybe leftover kdb+ processes are running. Cannot start the controller. Exiting."
  exit 12
fi

readonly WORKERBASEPORT=5500
for i in $(seq $NUMPROCESSES); do
  if nc -z  127.0.0.1 $((WORKERBASEPORT+i)); then
    echo "Port $((WORKERBASEPORT+i)) is used. Maybe leftover kdb+ processes are running. Exiting."
    exit 13
  fi
done


readonly HOST=$(uname -n)

readonly PARFILE="./partitions"

declare -a array
array=(`cat $PARFILE`)
readonly NUMSEGS=${#array[@]}

readonly RESDIR="${RESULTDIR}/${DATE}"
mkdir -p ${RESDIR}
echo "Results will be persisted in ${RESDIR}"
readonly CURRENTLOGDIR="${LOGDIR}/${DATE}"
mkdir -p ${CURRENTLOGDIR}

readonly RESFILEPREFIX=${RESDIR}/detailed-${HOST}-
readonly IOSTATFILE=${RESDIR}/iostat-${HOST}.psv
readonly AGGRFILEPREFIX=${RESDIR}/${HOST}-

readonly LOGFILEPREFIX="${CURRENTLOGDIR}/${HOST}-${NUMPROCESSES}t-"

function syncAcrossHosts {
	rm ${CURRENTLOGDIR}/sync-$HOST
	while [ `ls -l ./sync-* 2> /dev/null | wc -l` -ne 0 ]; do
	  sleep 0.5
    done
}

function notObjStore {
  if [[ $1 != s3://* && $1 != gs://* && $1 != ms://* ]]; then return 0; else return 1; fi
}

if [[ $(uname) == "Linux" ]]; then
    COREPERSOCKET=$(lscpu | grep "Core(s) per socket" | cut -d":" -f 2 |xargs)
    SOCKETNR=$(lscpu | grep "Socket(s)" | cut -d":" -f 2 |xargs)
    CPUMOODEL=$(lscpu | grep "Model name" | cut -d":" -f 2 |xargs)

    lscpu > ${RESDIR}/lscpu.out
    ${SUDO} dmidecode -t memory > ${RESDIR}/dmidecode.out
    if command -v numactl 2>&1 >/dev/null; then
      numactl --hardware > ${RESDIR}/numactl.out
    fi
else
    COREPERSOCKET=$(sysctl -n hw.ncpu)
    SOCKETNR=1
    CPUMOODEL=$(sysctl -n machdep.cpu.brand_string)
fi
CORECOUNT=$((COREPERSOCKET * SOCKETNR))

echo "Persisting config"
readonly CONFIG=${RESDIR}/config.yaml
echo "Persisting config to $CONFIG"
touch $CONFIG
yq -i ".env.COMPRESS=\"$COMPRESS\"" $CONFIG
yq -i ".env.THREADNR=$THREADNR" $CONFIG
yq -i ".env.PROCNR=$NUMPROCESSES" $CONFIG
yq -i ".env.FLUSH=\"$(basename $FLUSH)\"" $CONFIG
yq -i ".env.DBDIR=\"$(cat $PARFILE)\"" $CONFIG
yq -i ".nano.VERSION=\"$(yq '.dev' version.yaml)\"" $CONFIG
yq -i ".kdb.MAJOR=$($QBIN -q  <<< ".z.K" | tr -d f)" $CONFIG
yq -i ".kdb.MINOR=\"$($QBIN -q  <<< ".z.k")\"" $CONFIG
yq -i ".kdb.QBIN=\"$QBIN\"" $CONFIG
yq -i ".dbize.SEQWRITETESTLIMIT=$SEQWRITETESTLIMIT" $CONFIG
yq -i ".dbize.RANDREADNUMBER=$RANDREADNUMBER" $CONFIG
yq -i ".dbize.RANDREADFILESIZE=$RANDREADFILESIZE" $CONFIG
yq -i ".dbize.DBSIZE=\"$DBSIZE\"" $CONFIG
yq -i ".system.os.name=\"$(uname)\"" $CONFIG
yq -i ".system.os.kernel=\"$(uname -r)\"" $CONFIG
yq -i ".system.cpu.arch=\"$(uname -p)\"" $CONFIG
yq -i ".system.cpu.model=\"$CPUMOODEL\"" $CONFIG
yq -i ".system.cpu.corepersocket=$COREPERSOCKET" $CONFIG
yq -i ".system.cpu.socketnr=$SOCKETNR" $CONFIG
yq -i ".system.memsizeGB=$($QBIN -q <<<'.Q.w[][`mphy] div 1024 * 1024 * 1024')" $CONFIG


function cleanup {
  if [ "$KEEPDELETE" = "delete" ]; then
  	echo "cleaning up DB..."
  	j=0
  	for i in $(seq $NUMPROCESSES); do
      if notObjStore ${array[$j]}; then
  		  rm -rf ${array[$j]}/${HOST}.${i}/${DATE}
        rmdir ${array[$j]}/${HOST}.${i}
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
}

trap cleanup EXIT

# important that this it outside this loop with "q prepare", as first time after a mount as the
# fs may take a long time to start (S3 sync) and we want the wrtte processes to run in parallel
j=0
for i in $(seq $NUMPROCESSES); do
  if notObjStore ${array[$j]}; then
    if [ -d ${array[$j]}/${HOST}.${i} ]; then
      echo "${array[$j]}/${HOST}.${i} directory already exists. Please remove it and rerun."
      exit 7
    fi
	  mkdir -p ${array[$j]}/${HOST}.${i}/${DATE}
  fi
  echo "threadnr|testtype|testid|test|qexpression|repeat|length|starttime|endtime|result|unit" > ${RESFILEPREFIX}${i}.psv
	j=$(( ($j + 1) % $NUMSEGS ))
done

echo "testid|iostat_read_throughput|iostat_write_throughput|iostat_readwrite_throughput" > ${IOSTATFILE}

function runTest {
  TESTNAME=$1
  TESTER=$2

  echo
  echo "STARTING $TESTNAME TEST"
  
  touch ${CURRENTLOGDIR}/sync-$HOST

  ${QBIN} ./src/controller.q -iostatfile ${IOSTATFILE} -s $NUMPROCESSES -q -p ${CONTROLLERPORT} > ${CURRENTLOGDIR}/controller_${TESTER%.*}.log 2 >&1 &
  j=0
  for i in $(seq $NUMPROCESSES); do
  	${QBIN} ./src/${TESTER} -processes $NUMPROCESSES -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -s ${THREADNR} -p $((WORKERBASEPORT + i)) > ${LOGFILEPREFIX}${i}_${TESTER%.*}.log 2>&1 &
    j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait -n
  wait

  syncAcrossHosts

  # air gap for any remote stats collection....
  sleep 5
}

if [ "$SCOPE" = "full" ]; then
  ${FLUSH}
  runTest CPU cpu.q
  ${FLUSH}
  runTest WRITE prepare.q
fi

${FLUSH}
runTest "SEQUENTIAL READ" read.q

######### RE-READ TEST #########
# without flush, cached in kernel buffer, re-mapped...
runTest "SEQUENTIAL RE-READ" reread.q

if [ "$SCOPE" = "full" ]; then
  ${FLUSH}
  runTest "META DATA" meta.q
fi

######### RANDOM READ TEST #########

function runrandomread {
  local listsize=$1
  local mmap=$2
  ${FLUSH}
  echo "test${mmap} with block size ${listsize}"

  touch ${CURRENTLOGDIR}/sync-$HOST
  ${QBIN} ./src/controller.q -iostatfile ${IOSTATFILE} -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller_randomread_$listsize.log 2 >&1 &
  j=0
  sleep 5
  for i in $(seq $NUMPROCESSES); do
  	${QBIN} ./src/randomread.q -testname randomread -listsize ${listsize} ${mmap} -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -testtype "read disk" -s ${THREADNR} -S ${SEED} -p $((WORKERBASEPORT + i)) >> ${LOGFILEPREFIX}${i}_randomread_$listsize.log 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait

  ${QBIN} ./src/controller.q -iostatfile ${IOSTATFILE} -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller_randomreread_$listsize.log 2 >&1 &
  j=0
  for i in $(seq $NUMPROCESSES); do
  	${QBIN} ./src/randomread.q -testname randomreread -listsize ${listsize} ${mmap} -db ${array[$j]}/${HOST}.${i}/${DATE} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -testtype "read mem" -s ${THREADNR} -S ${SEED} -p $((WORKERBASEPORT + i)) >> ${LOGFILEPREFIX}${i}_randomreread_$listsize.log 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait
  syncAcrossHosts
}

echo
echo "STARTING RANDOM READ TEST"
SEED=1
for listsize in 1000000 64000 4000; do
	runrandomread $listsize " "
  SEED=$((SEED+1))
done
for listsize in 1000000 64000 4000; do
	runrandomread $listsize " -withmmap"
  SEED=$((SEED+1))
done

${FLUSH}
runTest XASC xasc.q


echo "Aggregating results"
${QBIN} ./src/postproc.q -inputs ${RESFILEPREFIX} -iostatfile ${IOSTATFILE} -processes ${NUMPROCESSES} -outputprefix ${AGGRFILEPREFIX} -q

#
# an air gap for any storage stats gathering before unlinks go out ...
#
sleep 5

sync ${RESDIR}
sync ${CURRENTLOGDIR}