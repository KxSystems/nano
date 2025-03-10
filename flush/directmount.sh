echo "Flushing page cache"


SUDO=""  # or "sudo" if sudo is required for the page cache flush command


if [ $(uname -s) = "Darwin" ];then
	sync $(cat ./partitions); $SUDO purge
else
	sync $(cat ./partitions); echo 3 | $SUDO tee /proc/sys/vm/drop_caches > /dev/null
fi
