#!/usr/bin/env bash

set -euo pipefail

readonly USAGE="Usage: $0 [-p|--processnr NUMBER] [-s|--scope cpuonly|diskonly|readonly|full] [--noclean] [-d|--dbsubdir DIR] [-r|--resultdir DIR] [-h|--help]"

# Defaults of the command-line parameters
NUMPROCESSES=1
SCOPE="full"
NOCLEAN=false
readonly DATE=$(date +%m%d_%H%M%S)
DBSUBDIR=$DATE
readonly DEFAULTRESDIRPARENT="./results"

# Globals
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

RESDIR="${DEFAULTRESDIRPARENT}/$DATE"
readonly CONTROLLERPORT=5100
readonly WORKERBASEPORT=5500

#######################################
# Functions
#######################################

show_help() {
  cat <<EOF
$USAGE

Options:
  -h, --help              Show this help message
  -p, --processnr NUMBER  Number of kdb+ worker processes executing tests in parallel (default: $NUMPROCESSES)
  -s, --scope SCOPE       Scope of operation: cpuonly, diskonly, readonly (write and meta tests are skipped), or full (default: $SCOPE)
  -d, --dbsubdir DIR      Subdirectory to use for readonly operations
  -r, --resultdir DIR     Directory for the results (default: subdirectory in $DEFAULTRESDIRPARENT)
  --noclean               Skip cleanup and keep datafiles (default: $NOCLEAN - perform cleanup)

Examples:
  $0 --processnr 8
  $0 -p 16 -s cpuonly
EOF
  exit 0
}

check_kdb_binary() {
  if [[ -z "${QBIN:-}" ]]; then
    echo "The kdb+ binary path is not set by environment variable QBIN"
    error_exit "You need to set QBIN in config/kdbenv, then do 'source config/kdbenv'" 3
  fi

  local KDBVERSION=$("${QBIN}" -q <<< ".z.K" | tr -d 'f')

  if (( $(echo "$KDBVERSION < 4.1" | bc -l) )); then
    error_exit "kdb+ version 4.1 or later is required" 9
  fi
}

validate_input() {
  if [[ ! "$NUMPROCESSES" =~ ^[0-9]+$ ]] || [[ "$NUMPROCESSES" -le 0 ]]; then
  	echo $USAGE
    error_exit "The process number must be a positive integer" 2
  fi

  if [[ ! "$SCOPE" =~ ^(cpuonly|diskonly|readonly|full)$ ]]; then
    error_exit "Invalid scope: $SCOPE (must be 'cpuonly', 'diskonly', 'readonly' or 'full')" 2
  fi

  if [[ "$SCOPE" == "readonly" && -z "$DBSUBDIR" ]]; then
    error_exit "Passing a subdir parameter is mandatory in readonly mode to locate previously generated data files" 5
  fi
}

validate_environment() {
  local required_vars=("FLUSH" "LOGDIR" "THREADNR" "FILENRPERWORKER"
                       "NUMA" "TINYLENGTH" "SMALLLENGTH" "MEDIUMLENGTH" "LARGELENGTH" "HUGELENGTH" 
                       "RANDREADNUMBER" "RANDREADFILESIZE" "DBSIZE")

  for var in "${required_vars[@]}"; do
      if [[ -z "${!var:-}" ]]; then
          error_exit "Required environment variable $var is not set" 3
      fi
  done

  if [[ ! -f "${FLUSH}" ]]; then
      error_exit "Script ${FLUSH} is missing. Please set environment variable FLUSH to an existing flush script" 3
  fi
}

check_port() {
  local port=$1
  if nc -z 127.0.0.1 "$port" &>/dev/null; then
      error_exit "Port $port is in use. Maybe leftover kdb+ processes are running." 12
  fi
}

sync_across_hosts() {
	rm ${CURRENTLOGDIR}/sync-${HOST}
	while [ $(ls -l ./sync-* 2> /dev/null | wc -l) -ne 0 ]; do
	  sleep 0.5
  done
}

is_not_obj_store() {
  [[ $1 != s3://* && $1 != gs://* && $1 != ms://* ]]
}

cleanup() {
  if [[ "$NOCLEAN" == "false" && "$SCOPE" != "cpuonly" ]]; then
  	echo "cleaning up DB..."
  	j=0
  	for i in $(seq $NUMPROCESSES); do
      local datadir=${array[$j]}/${HOST}.${i}/${DBSUBDIR}
      if is_not_obj_store ${array[$j]}; then
        rm -rf ${datadir}
      else
        case "${array[$j]}" in
          s3://*)
              aws s3 rm "${datadir}" --recursive || echo "Warning: Failed to clean S3 path ${datadir}" >&2
              ;;
          gs://*)
              gsutil rm -r "${datadir}" || echo "Warning: Failed to clean GS path ${datadir}" >&2
              ;;
          ms://*)
              echo "Cleanup ${datadir} manually"
              echo "az storage fs directory delete -f YOURCONTAINER -n ${HOST}.${i}/${DBSUBDIR} --account-name YOURSTORAGEACCOUNT"
              ;;
          *)
              echo "Unknown object storage prefix ${array[$j]::2}" >&2
              ;;
        esac
      fi
  		j=$(( (j + 1) % $NUMSEGS ))
  	done
  fi
  rm -rf ./sync-*
}

persist_config() {
    echo "Persisting config to ${CONFIG}"

    # Create config file with basic information
    cat > "${CONFIG}" <<EOF
env:
  COMPRESS: "${COMPRESS}"
  THREADNR: ${THREADNR}
  FILENRPERWORKER: ${FILENRPERWORKER}
  PROCNR: ${NUMPROCESSES}
  FLUSH: "$(basename "${FLUSH}")"
  DBDIR: "$(for d in $(cat ${PARFILE}); do echo ${d} \($(df -T ${d} | awk 'NR==2 {print $2}')\); done)"
  NUMA: "${NUMA}"
nano:
  version: "$(cat version.txt)"
kdb:
  major: $("${QBIN}" -q <<< ".z.K" | tr -d 'f')
  minor: "$("${QBIN}" -q <<< ".z.k")"
  qbin: "${QBIN}"
dbize:
  TINYLENGTH: ${TINYLENGTH}
  SMALLLENGTH: ${SMALLLENGTH}
  MEDIUMLENGTH: ${MEDIUMLENGTH}
  LARGELENGTH: ${LARGELENGTH}
  HUGELENGTH: ${HUGELENGTH}
  RANDREADNUMBER: ${RANDREADNUMBER}
  RANDREADFILESIZE: ${RANDREADFILESIZE}
  DBSIZE: "${DBSIZE}"
system:
  os:
    name: "$(uname)"
    kernel: "$(uname -r)"
  cpu:
    arch: "$(arch)"
    model: "${CPUMOODEL}"
    socketnr: ${SOCKETNR}
    corepersocket: ${COREPERSOCKET}
    threadpercore: ${THREADPERCORE}
  memsizeGB: $("${QBIN}" -q <<< '.Q.w[][`mphy] div 1024 * 1024 * 1024')
EOF

    # Add Linux-specific information if available
    if [[ "$(uname)" == "Linux" ]]; then
        lscpu > "${RESDIR}/lscpu.out"
        if command -v dmidecode &>/dev/null; then
            $SUDO dmidecode -t memory > "${RESDIR}/dmidecode.out" || echo "Warning: Failed to run dmidecode" >&2
        fi

        if command -v numactl &>/dev/null; then
            numactl --hardware > "${RESDIR}/numactl.out" || echo "Warning: Failed to run numactl" >&2
            NUMANODES=$(lscpu | grep "NUMA node(s)" | cut -d":" -f 2 | xargs)
            export NUMANODES
        fi
    fi

    if command -v hwloc-ls &>/dev/null; then
      hwloc-ls > "${RESDIR}/hwloc-ls.out" || echo "Warning: Failed to run hwloc-ls" >&2
    fi
}

get_numa_config() {
    if [[ -z "${NUMANODES:-}" || "${NUMANODES}" -le 1 || "${NUMA}" != "roundrobin" ]]; then
        echo ""
        return
    fi

    local process_id=$1
    local numa_node=$(( (process_id - 1) % NUMANODES ))
    echo "numactl -N ${numa_node} -m ${numa_node}"
}

run_test() {
  TESTNAME=$1
  TESTER=$2

  echo
  echo "STARTING $TESTNAME TEST"

  touch ${CURRENTLOGDIR}/sync-$HOST

  ${QBIN} ./src/controller.q -iostatfile ${IOSTATFILE} -s $NUMPROCESSES -q -p ${CONTROLLERPORT} > ${CURRENTLOGDIR}/controller_${TESTER%.*}.log 2 >&1 &
  j=0
  for i in $(seq $NUMPROCESSES); do
    local datadir=${array[$j]}/${HOST}.${i}/${DBSUBDIR}
    local NUMAPREFIX=$(get_numa_config $i)
    ${NUMAPREFIX} ${QBIN} ./src/${TESTER} -processes $NUMPROCESSES -db ${datadir} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -s ${THREADNR} -p $((WORKERBASEPORT + i)) > ${LOGFILEPREFIX}${i}_${TESTER%.*}.log 2>&1 &
    j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait -n
  wait

  sync_across_hosts

  # air gap for any remote stats collection....
  sleep 3
}

run_random_read_test() {
  local listsize=$1
  local mmap=$2
  source ${FLUSH}
  echo "test${mmap} with block size ${listsize}"

  touch ${CURRENTLOGDIR}/sync-$HOST
  ${QBIN} ./src/controller.q -iostatfile ${IOSTATFILE} -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller_randomread_$listsize.log 2 >&1 &
  j=0
  sleep 5
  for i in $(seq $NUMPROCESSES); do
    local datadir=${array[$j]}/${HOST}.${i}/${DBSUBDIR}
  	${QBIN} ./src/randomread.q -testname randomread_${listsize}${mmap:1} -listsize ${listsize} ${mmap} -db ${datadir} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -testtype "read disk" -s ${THREADNR} -S ${SEED} -p $((WORKERBASEPORT + i)) >> ${LOGFILEPREFIX}${i}_randomread_$listsize.log 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait

  ${QBIN} ./src/controller.q -iostatfile ${IOSTATFILE} -s $NUMPROCESSES -q -p ${CONTROLLERPORT} >> ${CURRENTLOGDIR}/controller_randomreread_$listsize.log 2 >&1 &
  j=0
  for i in $(seq $NUMPROCESSES); do
    local datadir=${array[$j]}/${HOST}.${i}/${DBSUBDIR}
  	${QBIN} ./src/randomread.q -testname randomreread_${listsize}${mmap:1} -listsize ${listsize} ${mmap} -db ${datadir} -result ${RESFILEPREFIX}${i}.psv -controller ${CONTROLLERPORT} -testtype "read mem" -s ${THREADNR} -S ${SEED} -p $((WORKERBASEPORT + i)) >> ${LOGFILEPREFIX}${i}_randomreread_$listsize.log 2>&1  &
  	j=$(( ($j + 1) % $NUMSEGS ))
  done
  wait
  sync_across_hosts
}

#######################################
# Main Script Execution
#######################################

source "${SCRIPT_DIR}/common.sh"
check_kdb_binary
validate_input "$@"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -p|--processnr)
      NUMPROCESSES="$2"
      shift 2
      ;;
    -s|--scope)
      SCOPE="$2"
      shift 2
      ;;
    --noclean)
      NOCLEAN=true
      shift
      ;;
    -d|--dbsubdir)
      DBSUBDIR="$2"
      shift 2
      ;;
    -r|--resultdir)
      RESDIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      echo "$USAGE"
      exit 1
      ;;
  esac
done

if [[ -z "${DBSUBDIR:-}" && "$SCOPE" != "readonly" ]]; then
  DBSUBDIR=$(date +%m%d_%H%M%S)
fi

validate_environment

readonly export NUMPROCESSES
readonly export SCOPE
readonly export NOCLEAN
mkdir -p ${RESDIR} || error_exit "Failed to create results directory ${RESDIR}" 7
readonly CURRENTLOGDIR="${LOGDIR}/${DATE}"
mkdir -p ${CURRENTLOGDIR} || error_exit "Failed to create log directory ${CURRENTLOGDIR}" 8

echo "Running benchmark with:"
echo "  Processes: $NUMPROCESSES"
echo "  Scope: $SCOPE"
echo "  Result directory: $RESDIR"
echo "  Log directory: $CURRENTLOGDIR"
if [[ ${NOCLEAN} == "true" ]]; then
  echo "  Cleanup disabled"
fi

check_port $CONTROLLERPORT
for i in $(seq $NUMPROCESSES); do
  check_port "$((WORKERBASEPORT+i))"
done

readonly HOST=$(uname -n)
readonly PARFILE="./partitions"

if [[ ! -f "${PARFILE}" ]]; then
    error_exit "Partitions file ${PARFILE} does not exist" 4
fi

mapfile -t array < "${PARFILE}"
readonly NUMSEGS=${#array[@]}

if [[ $SCOPE == "readonly" ]]; then
  local j=0
  for i in $(seq $NUMPROCESSES); do
    local datadir=${array[$j]}/${HOST}.${i}/${DBSUBDIR}
    if ! [ -d ${datadir} ]; then
      error_exit "Data directory ${datadir} does not exits. Mode readonly assumes that data has been generated previously." 6
    fi
    j=$(( ($j + 1) % $NUMSEGS ))
  done
fi

readonly RESFILEPREFIX="${RESDIR}/detailed-${HOST}-"
readonly IOSTATFILE="${RESDIR}/iostat-${HOST}.psv"
readonly AGGRFILEPREFIX="${RESDIR}/${HOST}-"
readonly LOGFILEPREFIX="${CURRENTLOGDIR}/${HOST}-${NUMPROCESSES}t-"
readonly CONFIG="${RESDIR}/config.yaml"

trap cleanup EXIT

# important that this it outside this loop with "q prepare", as first time after a mount as the
# fs may take a long time to start (S3 sync) and we want the wrtte processes to run in parallel
j=0
for i in $(seq $NUMPROCESSES); do
  if is_not_obj_store ${array[$j]}; then
    DATADIR=${array[$j]}/${HOST}.${i}/${DBSUBDIR}
    if [[ $SCOPE == "full" &&  -d ${DATADIR} ]]; then
      error_exit "${DATADIR} directory already exists. Please remove it and rerun." 7
    fi
	  mkdir -p ${DATADIR}
  fi
  echo "threadnr|os|testtype|testid|test|qexpression|repeat|length|starttime|endtime|result|unit" > ${RESFILEPREFIX}${i}.psv
	j=$(( ($j + 1) % $NUMSEGS ))
done

persist_config

echo "testid|iostat_read_throughput|iostat_write_throughput|iostat_readwrite_throughput" > ${IOSTATFILE}

if [[ "$SCOPE" == "cpuonly" ]]; then
  source ${FLUSH}
  run_test "CPU CACHE" cpucache.q
  run_test CPU cpu.q
else
  if [[ "$SCOPE" == "full" ]]; then
    source ${FLUSH}
    run_test "CPU CACHE" cpucache.q
    run_test CPU cpu.q
    source ${FLUSH}
    run_test WRITE write.q
    source ${FLUSH}
    run_test "META DATA" meta.q
  elif [[ "$SCOPE" == "diskonly" ]]; then
    source ${FLUSH}
    run_test WRITE write.q
    source ${FLUSH}
    run_test "META DATA" meta.q
  fi

  source ${FLUSH}
  run_test "SEQUENTIAL READ" read.q
  run_test "SEQUENTIAL RE-READ" reread.q

  echo "STARTING RANDOM READ TEST"
  SEED=1
  for listsize in 1000000 64000 4000; do
  	run_random_read_test $listsize " "
    SEED=$((SEED+1))
  done
  for listsize in 1000000 64000 4000; do
  	run_random_read_test $listsize " -withmmap"
    SEED=$((SEED+1))
  done

  source ${FLUSH}
  run_test XASC xasc.q
fi

echo "Aggregating results"
${QBIN} ./src/postproc.q -inputs ${RESFILEPREFIX} -iostatfile ${IOSTATFILE} -processes ${NUMPROCESSES} -outputprefix ${AGGRFILEPREFIX} -q

#
# an air gap for any storage stats gathering before unlinks go out ...
#
sleep 3

sync ${RESDIR}
sync ${CURRENTLOGDIR}

echo "Benchmark completed successfully"
exit 0
