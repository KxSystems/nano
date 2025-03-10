echo "Flushing page cache"


if [ $(uname -s) = "Darwin" ];then
	sync $(cat ./partitions); ${SUDO} purge
else
	sync $(cat ./partitions); echo 3 | ${SUDO} tee /proc/sys/vm/drop_caches > /dev/null
fi
