error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

if [[ $(uname) == "Linux" ]]; then
    SOCKETNR=$(lscpu | grep "Socket(s)" | cut -d":" -f 2 |xargs)
    COREPERSOCKET=$(lscpu | grep "Core(s) per socket" | cut -d":" -f 2 |xargs)
    THREADPERCORE=$(lscpu | grep "Thread(s) per core" | cut -d":" -f 2 |xargs)
    CPUMOODEL=$(lscpu | grep "Model name" | cut -d":" -f 2 |xargs)
else
    SOCKETNR=1
    COREPERSOCKET=$(sysctl -n hw.ncpu)
    THREADPERCORE=1
    CPUMOODEL=$(sysctl -n machdep.cpu.brand_string)
fi
COMPUTECOUNT=$((COREPERSOCKET * SOCKETNR * THREADPERCORE))
