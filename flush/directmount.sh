echo "Flushing page cache"


if [ $(uname -s) = "Darwin" ];then
	if [[ ! "$SCOPE" = "cpuonly" ]]; then
		sync $(cat ./partitions)
	fi
	${SUDO} purge
else
	if [[ ! "$SCOPE" = "cpuonly" ]]; then
		sync $(cat ./partitions)
	fi
	echo 3 | ${SUDO} tee /proc/sys/vm/drop_caches > /dev/null
fi
