#!/usr/bin/env bash

# the location where this is placed must be shareable between all nodes in the cluster
# output files will be stored and cannot be the same directory under test as we will unmount that
#

set -euo pipefail

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
DATE=$(date +%m%d_%H%M%S)

readonly RESDIR="./results/${DATE}"
for HOST in $(cat hostlist); do
	echo $HOST
	ssh $HOST "cd ${SCRIPT_DIR}; source ./config/kdbenv;source ./config/env;./mthread.sh $@ -d ${DATE}" &
done
wait

${QBIN} ${SCRIPT_DIR}/src/postprocmulti.q -inputs "${RESDIR}/throughput-" -output ${RESDIR}/total.psv -q