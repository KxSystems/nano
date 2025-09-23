# Filesystem Performance Benchmark Script

This repository contains a Bash script designed to automate KX Nano-based performance testing across various Linux filesystems, including `ext4`, `xfs`, `btrfs`, `f2fs`, and `zfs`.

<br>

> 🚨 **EXTREME CAUTION ADVISED** 🚨
>
> This script is **DESTRUCTIVE**. It will **IRREVERSIBLY WIPE ALL DATA** on the specified target block device. Double-check the `DEVICE` variable before execution. We are not responsible for any data loss.



## Description

The script performs the following actions in a loop for each specified filesystem:
1.  **Wipes** any existing filesystem signatures from the target device.
2.  **Creates** a new filesystem.
3.  **Mounts** the filesystem to a specified mount point.
4.  **Executes** KX Nano performance test (`multiproc.sh`).
5.  **Unmounts** the filesystem and cleans up the device to prepare for the next run.

This automated workflow makes it easy to gather comparative performance data across different filesystems on the same hardware.

## Prerequisites

Before running the script, ensure the following requirements are met:

### 1. System Privileges
The script runs a few Linux command (e.g. `mount`, `umount`, `wipefs`) via **sudo** so the user must be granted sudo privileges.

### 2. Required Packages
You must install the necessary userspace tools for all filesystems you intend to test. You can install them on a Debian/Ubuntu system with:
```bash
sudo apt-get update
sudo apt-get install -y f2fs-tools xfsprogs btrfs-progs zfsutils-linux
```
*(`e2fsprogs` for ext4 is typically installed by default)*


## Configuration

The script is configured using **environment variables**. You must set these before running the script.

| Variable | Description | Example |
| :--- | :--- | :--- |
| `DEVICE` | **(Required)** The target block device to format. **BE EXTREMELY CAREFUL.** | `export DEVICE=/dev/nvme0n1` |
| `MOUNT_POINT` | **(Required)** The directory where the filesystems will be mounted. | `export MOUNT_POINT=/mnt/fsbenchmark` |


## Usage

1.  **Navigate** to the directory containing the `main.sh` script.
    ```bash
    cd ./scripts/fsBenchmark
    ```

2.  **Set** the required environment variables
    ```bash
    export DEVICE=/dev/sdX # <-- Change this to your actual device!
    export MOUNT_POINT=/mnt/fsbenchmark
    ```

    Alternatively, you can edit `.env` and
    ```bash
    source .env
    ```

3.  **Execute** the script, providing the path to your desired output directory as the **only argument**.

    ```bash
    ./main.sh ./results/fsbenchmark
    ```
## Output

The script will generate one output file for each filesystem tested. The files will be saved in the directory you provided as a command-line argument.

-   `ext4.psv`
-   `xfs.psv`
-   etc.

The files are in Pipe-Separated Values (`.psv`) format, which can be easily imported into data analysis tools or spreadsheets.

## Customization

To change the list of filesystems to be tested, simply edit the `FILESYSTEMS` array at the top of the `main.sh` script:

```bash
# Edit this line to add or remove filesystems
readonly FILESYSTEMS=("ext4" "xfs")
```