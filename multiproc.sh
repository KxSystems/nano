#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

source "${SCRIPT_DIR}/common.sh"

OUTPUT=./results/throughput_total.psv
SCOPE=full
LIMIT=$COMPUTECOUNT

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -o, --output FILE   Output file path (default: $OUTPUT)
  -s, --scope SCOPE   Scope of operation: cpuonly, readonly (write and meta tests are skipped), or full (default: $SCOPE)
  -l, --limit NUM     Maximum number of worker processes (default: $LIMIT)
  -h, --help          Show this help message and exit

Examples:
  $0 --output ./myresults.psv --scope cpuonly --limit 8
  $0 -o ./results.psv -s full -l 4
EOF
}

while [[ $# -gt 0 ]]; do
   case "$1" in
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -s|--scope)
            SCOPE="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

readonly HOST=$(uname -n)
RESULTDIRS=()

NUMPROCESSES=1
while [ $NUMPROCESSES -le $LIMIT ]; do
   RESULTDIR="$SCRIPT_DIR/results/$(date +%m%d_%H%M%S)"
   RESULTDIRS+=($RESULTDIR)
   ${SCRIPT_DIR}/nano.sh --processnr $NUMPROCESSES --scope $SCOPE --resultdir ${RESULTDIR}
   NUMPROCESSES=$((NUMPROCESSES * 2))
done

head -n 1 ${RESULTDIRS[1]}/$HOST-throughput.psv > ${OUTPUT}
readonly TMP="$(mktemp)"
for RESULTDIR in ${RESULTDIRS[@]}; do
   tail -n +2 ${RESULTDIR}/$HOST-throughput.psv >> ${TMP}
done

sort ${TMP} -t '|' -k 3,3 >> ${OUTPUT}
rm ${TMP}
