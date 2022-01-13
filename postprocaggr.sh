#!/usr/bin/env bash

set -euo pipefail

AGGRFILE=$1

if [ ! -f $AGGRFILE ]; then
    echo "$AGGRFILE not found! Quiting."
    exit 1
fi


echo 'numproc,Write Rate,Streaming Read,random64k,random64ku,random1m,random1mu'
NUNMPROC=$(grep numprocs ${AGGRFILE} | cut -d " " -f 2)
WRITERATE=$(grep 'Total Write Rate(sync)' ${AGGRFILE} | cut -d " " -f 5)
STREAMINGRATE=$(grep 'Streaming Read(mapped) Rate' ${AGGRFILE} | cut -d " " -f 5)
RAND64K=$(grep "random64k " ${AGGRFILE} | cut -d " " -f 5)
RAND64KU=$(grep "random64ku " ${AGGRFILE} | cut -d " " -f 5)
RAND1M=$(grep "random1m " ${AGGRFILE} | cut -d " " -f 5)
RAND1MU=$(grep "random1mu " ${AGGRFILE} | cut -d " " -f 5)

echo ${NUNMPROC},${WRITERATE},${STREAMINGRATE%.*},${RAND64K%.*},${RAND64KU%.*},${RAND1M%.*},${RAND1MU%.*}