if [ `uname -s` = "Darwin" ]
then
	purge
else
	sync; echo 3 > /proc/sys/vm/drop_caches
fi
