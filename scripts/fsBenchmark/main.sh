#!/usr/bin/env bash

# ==============================================================================
# Filesystem Performance Benchmark Script
#
# Iterates through a list of filesystems, formats a block device,
# mounts it, runs a performance test, and cleans up.
#
# WARNING: This script is DESTRUCTIVE and will IRREVERSIBLY WIPE ALL DATA
#          on the target device specified by the $DEVICE variable.
# ==============================================================================

set -euo pipefail

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
readonly ZPOOL_NAME="kxnanotestpool"
readonly FILESYSTEMS=("ext4" "xfs" "btrfs" "f2fs" "zfs")
OUTPUT_DIR="${SCRIPT_DIR}" # Might be overwritten from command-line argument in main()

# Log messages with a prefix.
# Usage: log "INFO" "Message here"
log() {
    local type="$1"
    local msg="$2"
    printf '%s: %s\n' "$type" "$msg"
}

# Exit with an error message.
# Usage: error_exit "Something went wrong" 1
error_exit() {
    log "ERROR" "$1" >&2
    exit "${2:-1}"
}

# --- Pre-flight Checks ---

validate_environment() {
  local required_vars=("DEVICE" "MOUNT_POINT")

  for var in "${required_vars[@]}"; do
      if [[ -z "${!var:-}" ]]; then
          error_exit "Required environment variable $var is not set" 3
      fi
  done

  if [[ ! -b "$DEVICE" ]]; then
    error_exit "Device '$DEVICE' is not a valid block device." 4
  fi
}

# Check if required command-line tools are available.
check_dependencies() {
    local dependencies=("wipefs" "dd")
    for fs in "${FILESYSTEMS[@]}"; do
        if [[ "$fs" == "zfs" ]]; then
          dependencies+=("zpool" "zfs")
        else
          dependencies+=("mkfs.${fs}")
        fi
    done

    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            error_exit "Required command '$cmd' is not installed or not in PATH." 5
        fi
    done
}

# --- Filesystem & Device Operations ---

# Ensure the target device is unmounted.
ensure_unmounted() {
    if mountpoint -q "$MOUNT_POINT"; then
        log "INFO" "Unmounting '$MOUNT_POINT'..."
        if [[ $(findmnt -n -o FSTYPE -T $MOUNT_POINT) == "zfs" ]]; then
            sudo zfs unmount "$MOUNT_POINT"
        else
            sudo umount "$MOUNT_POINT"
        fi

    fi
}

# Completely wipe filesystem signatures and data from the device.
wipe_device() {

    if sudo zpool list "$ZPOOL_NAME" &>/dev/null; then
        log "INFO" "Destroying ZFS pool '$ZPOOL_NAME'..."
        sudo zpool destroy "$ZPOOL_NAME"
    fi

    log "INFO" "Wiping all data and signatures from '$DEVICE'..."
    sudo wipefs -a "$DEVICE" &>/dev/null || true
    # Overwrite the start of the disk to remove any lingering metadata (e.g., ZFS labels).
    sudo dd if=/dev/zero of="$DEVICE" bs=1M count=100 status=none &>/dev/null || true
    sync
}

# Create a filesystem on the target device.
create_fs() {
    local fs="$1"
    log "INFO" "Creating '$fs' filesystem on '$DEVICE'."

    case "$fs" in
        "xfs"|"btrfs"|"f2fs")
            # The -f flag forces creation even if a filesystem already exists.
            sudo "mkfs.${fs}" -f "$DEVICE"
            ;;
        "ext4")
            #  mkfs.ext4 needs capital F to force file system creation
            sudo mkfs.ext4 -F "$DEVICE"
            ;;
        "zfs")
            sudo zpool create -O compression=off -f "$ZPOOL_NAME" "$DEVICE"
            ;;
        *)
            error_exit "Unknown filesystem type: '$fs'." 10
            ;;
    esac
}

# Function to mount filesystem
mount_fs() {
    local fs=$1
    log "INFO" "Mounting '$fs' filesystem to '$MOUNT_POINT'."

    # Mount with appropriate options
    case $fs in
        "ext4"|"xfs"|"f2fs")
            sudo mount "$DEVICE" "$MOUNT_POINT"
            ;;
        "btrfs")
            sudo mount -o ssd "$DEVICE" "$MOUNT_POINT"  # SSD optimization for btrfs
            ;;
        "zfs")
            # ZFS is already mounted by zpool create, but we can set mountpoint
            sudo zfs set mountpoint="$MOUNT_POINT" "$ZPOOL_NAME"
            ;;
    esac

    sudo mkdir $MOUNT_POINT/kxnano
    sudo chown $USER $MOUNT_POINT/kxnano
}

# Run the actual performance test.
run_performance_test() {
    local fs="$1"
    log "INFO" "Running performance test for '$fs'."

    # Change to mount point
    pushd "${SCRIPT_DIR}/../.." >/dev/null

    source ./config/kdbenv
    source ./config/env

    tempfile=$(mktemp)
    mv partitions $tempfile
    echo "$MOUNT_POINT/kxnano/fstest" > partitions

    local output_file="${OUTPUT_DIR}/${fs}.psv"
    log "INFO" "Test output will be saved to '$output_file'."

    THREADNR=8 NUMA="roundrobin" ./multiproc.sh -p "1 64" -o "$output_file" -s diskonly

    mv $tempfile partitions

    popd >/dev/null
}

# Clean up after a test run.
cleanup_fs() {
    ensure_unmounted
    wipe_device
}

# --- Main Execution ---
main() {
    if [[ $# -eq 1 ]]; then
        OUTPUT_DIR="$1"
        mkdir -p ${OUTPUT_DIR} || error_exit "Could not create output directory '$OUTPUT_DIR'."
    fi

    validate_environment
    check_dependencies

    for fs in "${FILESYSTEMS[@]}"; do
        log "INFO" "#################### Starting Test for: ${fs^^} ####################"

        cleanup_fs # Start with a clean slate
        create_fs "$fs"
        mount_fs "$fs"
        run_performance_test "$fs"

        log "INFO" "#################### Finished Test for: ${fs^^} ####################"
        echo # Add a blank line for readability
        sleep 2
    done

    # Final cleanup
    log "INFO" "All filesystem tests completed. Performing final cleanup..."
    cleanup_fs
    log "INFO" "Script finished."
}


main "$@"