echo "Flushing page cache"

if [[ ! "$SCOPE" = "cpuonly" ]]; then
	sync $(cat ./partitions)
fi

if [ $(uname -s) = "Darwin" ]; then
	${SUDO} purge
else
	echo 3 | ${SUDO} tee /proc/sys/vm/drop_caches > /dev/null
fi
