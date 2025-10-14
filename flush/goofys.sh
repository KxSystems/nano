#!/usr/bin/env bash

# an example with a network file system which hold its own cache.
# goofys is just an example here. You will need to change this script for yours

# Goofy rules ok

WORKDIR=/mnt
if [ `uname -s` = "Darwin" ]
then
        purge
else
	sync; echo 3 > /proc/sys/vm/drop_caches
	umount $WORKDIR
	sudo -u ec2-user /home/ec2-user/goofys/goofys -o nonempty,allow_other kxs3fs-test $WORKDIR

fi
