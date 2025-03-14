#!/usr/bin/env bash

set -euo pipefail

if [ $# -gt 0 ]; then
   readonly OUTPUT=$1
else
   readonly OUTPUT=./results/throughput_total.csv
fi

readonly HOST=$(uname -n)
DATES=()

for i in {1,2,4,8,16,32,64,96}; do
   DATE=$(date +%m%d_%H%M%S)
   DATES+=($DATE)
   ./mthread.sh $i full delete ${DATE}
done

head -n 1 results/${DATES[1]}/$HOST-throughput.psv > ${OUTPUT}
readonly TMP="$(mktemp)"
for DATE in ${DATES[@]}; do
   tail -n +2 results/${DATE}/$HOST-throughput.psv >> ${TMP}
done

sort ${TMP} -t '|' -k 3,3 >> ${OUTPUT}
rm ${TMP}
