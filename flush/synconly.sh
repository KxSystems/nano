#!/usr/bin/env bash

echo "Skipping flush, executing sync only"


if [[ ! "$SCOPE" = "cpuonly" ]]; then
    sync $(cat ./partitions)
fi
