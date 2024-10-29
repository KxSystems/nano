#!/usr/bin/env bash

# the location where this is placed must be shareable between all nodes in the cluster
# output files will be stored and cannot be the same directory under test as we will unmount that
#

set -euo pipefail

USAGE="Usage: $0 processnr full|readonly delete|keep"

if [ $# -lt 3 ]
then
	echo $USAGE
	exit 1
fi

NUMPROCESSES=$1
HERE=$(pwd)
DATE=$(date +%m%d_%H%M%S)

RESDIR="./results/${DATE}"
for HOST in $(cat hostlist); do
	echo $HOST
	ssh $HOST "cd ${HERE}; source ./config/kdbenv;source ./config/env;./mthread.sh ${NUMPROCESSES} $2 $3 ${DATE}" &
done
wait

${QBIN} ${HERE}/src/postprocmulti.q -inputs "${RESDIR}/throughput-" -output ${RESDIR}/total.psv -q