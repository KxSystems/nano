#!/usr/bin/env bash

set -euo pipefail

DIRPREFIX="results/$(date +%m%d:)"
echo "cleaning ${DIRPREFIX}*"
rm -rf ${DIRPREFIX}*

for i in {1,2,4,8,16,32,64,96}; do
   ./mthread.sh $i delete
done

for i in ${DIRPREFIX}*; do
	./postprocaggr.sh $i/aggregates-$(hostname) > $i/aggr.csv;
done

cat ${DIRPREFIX}*/aggr.csv | sort -n| uniq > aggr_total.csv