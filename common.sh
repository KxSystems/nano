if [[ $(uname) == "Linux" ]]; then
    COREPERSOCKET=$(lscpu | grep "Core(s) per socket" | cut -d":" -f 2 |xargs)
    SOCKETNR=$(lscpu | grep "Socket(s)" | cut -d":" -f 2 |xargs)
    CPUMOODEL=$(lscpu | grep "Model name" | cut -d":" -f 2 |xargs)
else
    COREPERSOCKET=$(sysctl -n hw.ncpu)
    SOCKETNR=1
    CPUMOODEL=$(sysctl -n machdep.cpu.brand_string)
fi
CORECOUNT=$((COREPERSOCKET * SOCKETNR))
