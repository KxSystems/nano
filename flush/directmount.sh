#!/usr/bin/env bash

echo "Flushing caches"

declare -A zfs_pools
while IFS= read -r partition; do
	if [[ $(findmnt -n -o FSTYPE -T ${partition}) == "zfs" ]]; then
		pool=$(findmnt -n -o SOURCE -T ${partition})
		echo "${partition} is on zfs pool ${pool}"
		zfs_pools[$pool]=1
	else
		echo "syncing ${partition}"
		sync ${partition}
	fi
done < ./partitions

unique_pools=("${!zfs_pools[@]}")

if [ $(uname -s) = "Darwin" ]; then
	${SUDO} purge
else
	if [[ ${#unique_pools[@]} -gt 0 ]]; then
		for pool in "${unique_pools[@]}"; do
    		echo "Exporting ZFS pool: $pool"
			if ! ${SUDO} zpool export $pool; then
				echo "Error: Failed to export ZFS pool '$pool'. Aborting."
      			exit 1
    		fi
		done
	fi

	echo "Flushing page cache"
	echo 3 | ${SUDO} tee /proc/sys/vm/drop_caches > /dev/null
	echo "sleeping a bit"
	sleep 0.2

	if [[ ${#unique_pools[@]} -gt 0 ]]; then
		for pool in "${unique_pools[@]}"; do
    		echo "Importing ZFS pool: $pool"
			if ! ${SUDO} zpool import $pool; then
				echo "Error: Failed to import ZFS pool '$pool'. Aborting."
      			exit 1
    		fi
		done
	fi
fi

echo "Flush process complete."