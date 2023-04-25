#!/usr/bin/env bash

set -euo pipefail

AGGRFILE=$1

if [ ! -f $AGGRFILE ]; then
    echo "$AGGRFILE not found! Quiting."
    exit 1
fi


echo 'numproc,Write Rate,Streaming Read,Random 64k,Random 64k with mmaps,Random 1M,Random 1M with mmaps'
NUNMPROC=$(grep numprocs ${AGGRFILE} | cut -d " " -f 2)
WRITERATE=$(grep 'Total Write Rate(sync)' ${AGGRFILE} | cut -d " " -f 5)
STREAMINGRATE=$(grep 'Streaming Read(mapped) Rate' ${AGGRFILE} | cut -d " " -f 5)
RAND64K=$(grep "Random 64k:" ${AGGRFILE} | cut -d " " -f 4)
RAND64KMMAP=$(grep "Random 64k with mmaps:" ${AGGRFILE} | cut -d " " -f 6)
RAND1M=$(grep "Random 1M:" ${AGGRFILE} | cut -d " " -f 4)
RAND1MMMAP=$(grep "Random 1M with mmaps:" ${AGGRFILE} | cut -d " " -f 6)

echo ${NUNMPROC},${WRITERATE},${STREAMINGRATE%.*},${RAND64K%.*},${RAND64KMMAP%.*},${RAND1M%.*},${RAND1MMMAP%.*}