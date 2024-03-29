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

source ./env

NUMPROCESSES=$1
HERE=$(pwd)
DATE=$(date +%m%dD%H%M)

RESDIR="./results/${DATE}-${DATE}"
RESFILEPREFIX=""
for HOST in $(cat $HOSTLIST); do
	echo $HOST
	RESFILEPREFIX+="${RESDIR}/detailed-${HOST}-,"
	ssh $HOST "cd ${HERE};./mthread.sh ${NUMPROCESSES} $2 $3 ${DATE}" &
done
wait

${QBIN} ${HERE}/src/postproc.q ${RESFILEPREFIX::-1} ${NUMPROCESSES} ${RESDIR}/total.psv -q