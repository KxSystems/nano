#!/usr/bin/env bash

set -euo pipefail

source common.sh

if [ $# -lt 1 ]; then
   readonly OUTPUT=./results/throughput_total.csv
   readonly LIMIT=$CORECOUNT
elif [ $# -lt 2 ]; then
   readonly OUTPUT=$1
   readonly LIMIT=$CORECOUNT
else
   readonly OUTPUT=$1
   readonly LIMIT=$2
fi

readonly HOST=$(uname -n)
DATES=()

NUMPROCESSES=1
while [ $NUMPROCESSES -le $LIMIT ]; do
   DATE=$(date +%m%d_%H%M%S)
   DATES+=($DATE)
   ./mthread.sh $NUMPROCESSES full delete ${DATE}
   NUMPROCESSES=$((NUMPROCESSES * 2))
done

head -n 1 results/${DATES[1]}/$HOST-throughput.psv > ${OUTPUT}
readonly TMP="$(mktemp)"
for DATE in ${DATES[@]}; do
   tail -n +2 results/${DATE}/$HOST-throughput.psv >> ${TMP}
done

sort ${TMP} -t '|' -k 3,3 >> ${OUTPUT}
rm ${TMP}
