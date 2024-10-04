#!/usr/bin/env bash

set -euo pipefail

if [ $# -gt 0 ]; then
   OUTPUT=$1
else
   OUTPUT=./results/aggr_total.csv
fi

HOST=$(uname -n)
DATES=()

for i in {1,2,4,8,16,32,64,96}; do
   DATE=$(date +%m%d_%H%M)
   DATES+=($DATE)
   ./mthread.sh $i full delete ${DATE}
done

head -n 1 results/${DATES[1]}-${DATES[1]}/throughput-$HOST.psv > ${OUTPUT}
TMP="$(mktemp)"
for DATE in ${DATES[@]}; do
   tail -n +2 results/${DATE}-${DATE}/throughput-$HOST.psv >> ${TMP}
done

sort ${TMP} -t '|' -k 3,3 >> ${OUTPUT}
rm ${TMP}
