echo "Flushing page cache"

if [ $(id -u) -eq 0 ]; then
  SUDO=""
else
  SUDO=sudo
fi

if [ `uname -s` = "Darwin" ]
then
	purge
else
	sync; echo 3 | $SUDO tee /proc/sys/vm/drop_caches > /dev/null
fi
