# Nano Benchmark

© KX 2025

"Nano" is a benchmark utility that measures the raw CPU, memory, and I/O performance of a system from the perspective of a kdb+ process. It performs a series of tests including sequential/random reads and writes, data aggregation (e.g., `sum`, `sort`), and filesystem metadata operations (e.g., opening a file).

The benchmark can measure performance using a single kdb+ process or aggregate results from multiple worker processes. These processes can run against local storage or a distributed/shared file system. Throughput and latency are measured directly within kdb+/q and cover operations like data creation, ingestion, memory mapping (mmap), and reads. An option to test with compressed data is also included.

It's designed to validate the performance of a system's CPU and storage before proceeding with more comprehensive testing.

While Nano does not simulate a multi-column tick database, it effectively demonstrates the maximum I/O capabilities of kdb+ on the system at a lower level. It is also a valuable tool for examining OS settings, file systems, testing scalability, and identifying I/O-related bottlenecks via stress testing.

Multi-node client testing can be used to test read/write rates for multiple hosts targeting a shared storage device.

_Throughout this document, "kdb+ process" and "q process" are used interchangeably._

## Prerequisites

   * **kdb+ 4.1 or later must be installed**. You can find installation instructions [install kdb+ 4.1](https://code.kx.com/q/learn/install/). If your kdb+ installation is not in `$HOME/q`, you must set the `QHOME` environment variable in `config/kdbenv`.
   * **Required command-line utilities**: The scripts require the following tools to be available in your `PATH`. See the `Dockerfile` for a complete list of dependencies.
      * [iostat](https://github.com/sysstat/sysstat) (from the sysstat package)
      * [nc](https://nc110.sourceforge.io/) (netcat)
   * **Network Ports**: The scripts launch several kdb+ processes that listen for IPC messages. By default, the controller listens on port 5100, and workers use ports 5500, 5501, 5502, and so on. These can be configured by editing the `CONTROLLERPORT` and `WORKERBASEPORT` variables in `nano.sh`.

## Installation and Configuration

Clone or copy all scripts into a single working directory.

**Important**: Do not place the scripts in the directory you intend to use for I/O testing, as this directory may be unmounted by certain test routines. If running across multiple nodes, this directory should be on a shared file system (e.g., NFS).

For best results, run the scripts as the root user or with a high process priority (e.g., using **nice**).

### Parameters

The benchmark is configured using both environment variables and command-line arguments. Environment variables are set in `config/env`.

One key environment variable is `FLUSH`, which must point to a script that flushes the system's storage cache. Sample scripts are provided in the `flush/` directory. The default script, `directmount.sh`, assumes locally attached block storage and uses `echo 3 | ${SUDO} tee /proc/sys/vm/drop_caches` to clear caches. If you are not running as root (i.e. `SUDO=sudo` in `config/env`), your system administrator will need to grant passwordless `sudo` permissions for this script.

### Storage disks

   1. Create a dedicated test directory on each storage device or partition you wish to benchmark.
   1. Add the absolute paths of these directories to the `partitions` file, one per line.

Using a single entry in the `partitions` file is a simple way to test a shared/parallel file system, allowing it to manage data distribution across its storage targets.

## Running the Benchmark

Before running, it is recommended to close all cpu, storage and memory-intensive applications. The benchmark does not use more then third of the available free memory and sizes its test files accordingly.

The scripts rely on environment variables defined in the configuration files. Source them before execution:

```bash
$ source ./config/kdbenv
$ source ./config/env
```

### `nano.sh`

This script starts the benchmark on a single host with multiple worker processes. Use the `-h` flag for a full list of options.

Example Usages:

```bash
# Run with worker processes number equal to the thread count of the system
$ ./nano.sh -p $(nproc)

# Run with 8 workers and skip cleaning up the data directories afterward
$ ./nano.sh -p 8 --noclean

# Rerun a read-only test on an existing dataset from a previous run
$ ./nano.sh -p 8 -s readonly --noclean -d 0408_152349
```

Typical worker counts for scalability testing are 1, 2, 4, 8, 16, 32, 64, ... see `multiproc.sh`.

### `multiproc.sh`

To analyze how storage and CPU performance scales with an increasing number of parallel requests, use `multiproc.sh`. This script repeatedly calls `nano.sh` with different worker counts and aggregates the results into a single summary file. Use `--help` to see all options.

Example Usages:

```bash
# Run tests for 1, 2, 4, 8, 16, and 32 workers, saving the summary to a custom file
$ ./multiproc.sh -o nano_results.psv -l 32

# Run only the CPU tests for 1, 16, and 128 workers
$ ./multiproc.sh -s cpuonly -p "1 16 128"
```

### `multihost.sh`

For multi-node tests, list the hostnames or IP addresses of the other nodes in the `hostlist` file. The script will use `ssh` to start the benchmark on each remote node. Each server will run the same number of worker processes, and no data is shared between processes.

Prerequisites for multi-host testing:
   * All nodes must be time-synchronized (e.g., using NTP).
   * Passwordless `ssh` access must be configured from the control node to all hosts in hostlist. You may need to configure `~/.ssh/config`.
   * If running as a non-root user, then you need `sudo` permissions on remote hosts.

Example Usage:

```bash
$ source ./config/kdbenv
$ source ./config/env
$ ./multihost.sh -p 32
```

### Results and Logs

#### Results

Results are saved in PSV (pipe-separated values) format in the directory specified by the `--resultdir` argument. If omitted, results are saved to `results/mmdd_HHMMSS`.
   * `HOSTNAME-throughput.psv`: This file summarizes the throughput metrics from all workers. More details of some columns:
      * `throughput`: The total throughput measured from within the kdb+ processes.
      * The read/write throughput reported by `iostat` is also included for comparison.
      * `accuracy`: An estimate of the test synchronization error. It is calculated as the maximum start time difference across all workers, divided by the average test duration.

The results are saved as PSV files set by the command line parameter `resultdir`. If `resultdir` is not set then `results/mmdd_HHMMSS` is used.


#### Log Files

Progress is reported to standard output. Detailed logs for each kdb+ process are available in the `logs/mmdd_HHMMSS` directory.

### Advanced Usage

### Object Storage Support

Nano v2.1+ supports benchmarking object storage (S3, GCS, Azure Blob Storage). Simply add the object storage path to your partitions file. Refer to the [KX documentation on object storage](https://code.kx.com/insights/1.4/core/objstor/main.html) for setup and required environment variables.

Example partitions entries:
   * `s3://kxnanotest/firsttest`
   * `gs://kxnanotest/firsttest`
   * `ms://kxnanotest.blob.core.windows.net/firsttest`

The execution environment must be configured with the appropriate cloud vendor's CLI tools and credentials, as if you were manually accessing object storage.

#### Testing Object Storage Cache

You can also measure the performance impact of the local cache. The recommended procedure is:
   1. Provide an object storage path in the partitions file.
   1. Set a unique subdirectory for the test data: `export DBDIR=$(date +%m%d_%H%M%S)`.
   1. Run a full test to populate the object store: `./nano.sh -p $(nproc) --noclean --dbsubdir $DBDIR`.
   1. Enable the local cache by setting `KX_OBJSTR_CACHE_PATH` in `./config/env` to an empty directory on a fast local disk.
   1. Run a read-only test to populate the cache: `./nano.sh -p $(nproc) -s readonly --dbsubdir $DBDIR --noclean`.
   1. Run the read-only test again to measure performance with a warm cache: `./nano.sh -p $(nproc) -s readonly --dbsubdir $DBDIR`.
   1. Clean up the local cache directory when finished: `source ./config/env; rm -rf ${KX_OBJSTR_CACHE_PATH:?}/objects`.

You can also test the [cache](https://code.kx.com/insights/1.4/core/objstor/kxreaper.html) impact of the object storage library. The recommended way is to
   * Provide an object storage path in `partitions`
   * `DBDIR=$(date +%m%d_%H%M%S)`
   * Run a full test to populate data: `./nano.sh --processnr $(nproc) --noclean --dbsubdir $DBDIR`.
   * Assign an empty directory on a fast local disk to the environment variable `KX_OBJSTR_CACHE_PATH` in file `./config/env`
   * Run the test to populate cache: `./nano.sh --processnr $(nproc) --scope readonly --dbsubdir $DBDIR --noclean`
   * Run the test again to use cache: `./nano.sh --processnr $(nproc) --scope readonly --dbsubdir $DBDIR`
   * Delete cache files in object storage cache: `source ./config/env; rm -rf ${KX_OBJSTR_CACHE_PATH}/objects`

The random read test is deterministic; it uses a fixed seed to ensure it reads the same data blocks in the same order on consecutive runs, which is crucial for cache testing.

The `THREADNR` environment variable can significantly impact random read performance from object storage. See the [documentation on secondary threads](https://code.kx.com/insights/1.6/core/objstor/main.html#secondary-threads) for details.


### Docker Image

A pre-built Docker image is available from GitLab and Nexus.

```bash
# Pull from GitLab
$ docker pull registry.gitlab.com/kxdev/benchmarking/nano/nano:latest

# Pull from KX Nexus
$ docker pull ext-dev-registry.kxi-dev.kx.com/benchmarking/nano:latest
```

The nano scripts are located at `/opt/kx/app` inside the container. To run the benchmark, you must mount several host directories into the container:
   * **License**: Mount your kdb+ license directory to `/tmp/qlic`.
   * **Results**: Mount a host directory to `/appdir` where the results and logs subdirectories will be created.
   * **Test Data**: Mount the storage you wish to test to a directory like `/data`.

To run the script by docker, you need to mount there directories to target directories
   1. `/tmp/qlic`: contains your kdb+ license file
   1. `/appdir`: results and logs are saved here into subdirectories `results` and `logs` respectively
   1. `/data`: that is on the storage you would like to test. For multi-partition test, you need to overwrite `/opt/kx/app/partitions` with your partition file.

You can override default environment variables from config/env using Docker's `-e` flag.

By default, the container uses the `flush/directmount.sh` script, which requires the `--privileged` flag. To run without privileged mode, you can select a different flush script, such as `noflush.sh`, by setting the `FLUSH` environment variable.

Example Usages:

```bash
# Single storage mount, privileged mode
docker run --rm -it \
  -v $QHOME:/tmp/qlic:ro \
  -v /mnt/$USER/nano:/appdir \
  -v /mnt/$USER/nanodata:/data \
  --privileged \
  ext-dev-registry.kxi-dev.kx.com/benchmarking/nano:latest -p 4

# Multi-storage mount, non-privileged mode, overriding THREADNR
docker run --rm -it \
  -v $QHOME:/tmp/qlic:ro \
  -v /mnt/$USER/nano:/appdir \
  -v /mnt/storage1/nanodata:/data1 \
  -v /mnt/storage2/nanodata:/data2 \
  -v ${PWD}/partitions_2disks:/opt/kx/app/partitions:ro \
  -e FLUSH=/opt/kx/app/flush/noflush.sh \
  -e THREADNR=5 \
  ext-dev-registry.kxi-dev.kx.com/benchmarking/nano:latest -p 4
```

### Running as a Kubernetes Job

To run Nano as a Kubernetes Job, the pod requires elevated permissions to access system-level information (e.g., using `lsblk` to get device types). You must configure the pod's `securityContext` to run in privileged mode as the root user.

```yaml
   containers:
   ...
      securityContext:
         privileged: true
         runAsUser: 0
```

⚠️ **Security Warning**: Running containers in privileged mode or as root significantly increases security risks. Please consult the [Kubernetes Security Documentation](https://kubernetes.io/docs/concepts/security/) for best practices.

## Troubleshooting

### 'Too many open files'

If you encounter a 'Too many open files' error, the limit on open file descriptors is too low. The controller opens a TCP connection to each worker, so this is common with a high worker count (e.g., 512).

Increase the limit for the current session with:

```bash
$ ulimit -n 2048
```

To make this change permanent, you must edit `/etc/security/limits.conf` or a similar system configuration file.

### Out of memory

Memory usage for some CPU tests is proportional to the number of secondary threads (`THREADNR`) and increases with the number of worker processes (parameter `-p`).

If a test run fails with an OutOfMemory (OOM) error, you can exclude the most memory-intensive tests by setting the `EXCLUDETESTS` environment variable:

```bash
EXCLUDETESTS=".cpu.groupIntLarge .cpu.groupFloatLarge"
```

### 'Port in use'
If the benchmark fails with an error like `ERROR: Port 5501 is in use`, another process is occupying a required port. This is often due to a kdb+ process from a previously failed test run.

You can terminate leftover `q` processes using:

```bash
$ killall q
# or
$ kill -9 $(pidof q)
```

**Caution**: These commands will terminate all running q processes for your user, not just those started by the benchmark.

Alternatively, you can identify the specific process using `lsof -i :5501` and terminate it, or modify the `WORKERBASEPORT` and `CONTROLLERPORT` variables in `nano.sh` to use different ports.

## Technical Details

The benchmark executes up to 7 major test suites. The cache is flushed before each suite, except for "reread" tests. If the scope is set to readonly, the Write and Meta tests are skipped.

   1. CPU (`cpucache.q` and `cpu.q`)
   1. Write (`write.q`)
   1. Sequential read (`read.q`)
   1. Sequential reread (`reread.q`)
   1. Meta (`meta.q`)
   1. Random read and reread (`randomread.q`)
   1. xasc (``xasc.q`)

All tests start multiple kdb+ processes (set by the parameter `-p` of `./nano.sh`) each having its own working space on the disk.

### CPU (`cpu.q`)

This suite stresses CPU speed, cache performance, and main memory bandwidth using in-memory arrays of various sizes designed to fit within L1, L2, L3 caches, and main memory. Tests include:
   * Random permutation generation and sorting
   * Vector arithmetic (deltas, moving/weighted averages)
   * Serialization, deserialization, and compression

### Write (`write.q`)
These tests measure raw write performance using several methods common in kdb+ applications.
   `set`: Writes data using the kdb+ set (:) operator.
   `Append`: Appends data to a file using a file handle or file symbol.
   `Replace`: Overwrites and existing vector.
   `sync`: Executes system sync call to flush OS file caches to persistent storage, ensuring data durability (making sure that recent data is not lost in case of hardware outage). It is executed after write/append. The Linux `sync` command synchronizes cached data to permanent storage. This data includes modified superblocks, modified inodes, delayed reads and writes, and others

### Sequential read (`read.q`)
This test simulates a full vector scan.
   1. A test file is memory-mapped into the process using `get`.
   1. The OS is advised that this memory region will be needed soon via `madvise` (`-23!`).
   1. A `max` operation is performed on the mapped vector, forcing a sequential read of all its data pages.
   1. A binary read is performed using `read1`.

### Sequential reread (`reread.q`)
This test is identical to the Sequential Read test, but it is run **without flushing the cache**. This measures the performance of accessing data that is already resident in the OS page cache. The `mmap` and `madvise` operations should be significantly faster as no disk I/O is required.

### Meta (`meta.q`)
This suite measures the performance of filesystem metadata operations by executing them thousands of times and averaging the latency.
   * **Open/Close**: `hclose hopen x`
   * **File Size**: `hcount x`
   * **Read & Parse**: `get` on a small kdb+ data file.
   * **File Lock**: Uses [enum extend](https://code.kx.com/q/ref/enum-extend/)(.Q.en) to acquire a lock on a file.

### Random read (`randomread.q`)
This test simulates indexed reads from a large on-disk vector, a common operation in `select` queries with where clauses. Each subtest reads a total of 800 MiB of data using different block sizes (1 MiB, 64 KiB, or 4 KiB).
   * **Random Read**: Indexes into an on-disk vector.
   * **MMaps Random Read**: First memory-maps the file, then performs the indexed reads.

If a kdb+ database is loaded with [.Q.MAP](https://code.kx.com/q/ref/dotq/#map-maps-partitions), partitions are memory-mapped on startup, and subsequent `select` queries perform only the random read portion. The throughput is calculated based on the _useful_ data read (e.g., 8 bytes for a long integer), not the total data read from disk by the OS, which may be larger due to prefetching (`read_ahead_kb`).

This test consists of four subtests. Each subtest random reads 800 MiB of data by indexing a list stored on disk. Consecutive integers are used for indexing. Each random read uses a different random offset ([deal](https://code.kx.com/q/ref/deal/#roll-and-deal)). 800 MB is achieved either by reading blocks of sizes 1M, 64k or 4k. Each random read can also perform a `mmap`. This test is denoted by a `mmaps` postfix, e.g. `mmaps,random read 64k` stands for random reading integer list of size 64k after a memory map.

### xasc (`xasc.q`)

This test performs two operations: an on-disk sort by the `sym` column using `xasc`, followed by applying the parted attribute (`p#`) to the same column. Given that these operations write data to storage, `sync` performance tests were also added to the suite.