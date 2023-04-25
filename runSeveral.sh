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
   DATE=$(date +%m%d:%H%M)
   DATES+=($DATE)
   ./mthread.sh $i full delete ${DATE}
   ./postprocaggr.sh results/${DATE}/aggregates-${HOST} > results/${DATE}/aggr.csv;
done

TMP="$(mktemp)"
for DATE in ${DATES[@]}; do
   cat results/${DATE}/aggr.csv >> ${TMP}
done

sort -n ${TMP} | uniq > ${OUTPUT}
rm ${TMP}
