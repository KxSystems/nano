# nano benchmark

© KX 2025

"nano" calculates basic raw CPU and I/O capabilities of non-volatile storage, as measured from the perspective of kdb+. It is considered a storage, memory and CPU benchmark that performs sequential/random read and write together with aggregation (e.g. sum and sort) and meta operations (like opening a file).

Nano measures results from running on one kdb+ processes or aggregated across several worker processes. The kdb+ processes can be attached either directly to storage, or connected to a
distributed/shared storage system.

The throughput and latency measurements are taken directly from kdb+/q,
results include read/mmap allocation, creation and ingest of data.
There is an option to test compressed data.

This utility is used to confirm the basic expectations for the CPU and storage subsystem
prior to a more detailed testing regime.

"nano" does not simulate parallel IO rates via the creation of multi-column tick databases,
but instead shows both a maximum I/O capability for kdb+ on the system under test, and is a
useful utility to examine OS settings, scalability, and identify any pinch points related
to the kdb+ I/O models.

Multi-node client testing can be used to either test a single namespace solution, or to test read/write rates for multiple hosts using multiple different storage targets on a shared storage device.

In this document, we use `kdb+ process` and `q process` interchangeably.

## Prerequisite

Please [install kdb+ 4.1](https://code.kx.com/q/learn/install/). If the q home differs from `$HOME/q` then you need to set `QHOME` in `config/kdbenv`.

The script assumes that the following commands are available - see `Dockerfile` for more information
   * [iostat](https://github.com/sysstat/sysstat)
   * [nc](https://nc110.sourceforge.io/)

The scripts starts several kdb+ processes that open a port for incoming messages. By default, the controller opens port 5100 and the workers open 5500, 5501, 5502, etc. You can change these ports by editing variables CONTROLLERPORT and WORKERBASEPORT in `nano.sh`.

## Installing and configuring

Place these scripts in a single working directory.
**Do not** place these scripts directly in the destination location being used for the IO testing, as that directory may be unmounted during the tests. If the scripts are to be executed across multiple nodes, place the directory containing them in a shared (e.g NFS) directory.

The scripts can best be run as root user or started with high priority.

### parameters
The benchmark can run with many parameters. Some parameters are set as environment variables (e.g. the number of secondary threads of the kdb+ processes) and some are set by command line parameters (e.g. number of worker kdb+ processes). Environment variables are placed in `config/env`.

One key environment variable is `FLUSH` that points to a storage cache flush script. Some sample scripts are provided and the default assumes locally attached block storage for which `echo 3 > /proc/sys/vm/drop_caches` does the job. If the root user is not available to you, the flush script will have to be placed in the sudo list by your systems administrator.

### storage disks
Create a directory on each storage medium where data will be written to during the test. List these data directories in file `partitions`. Use absolute path names.

Using a single-line entry is a simple way of testing
a single shared/parallel file-system. This would allow the shared FS to control the
distribution of the data across a number of storage targets (objects, et al)
automatically.

#### Object storage support
nano version 2.1+ supports object storage. You simply need to put the object storage path into file partitions. See [object storage kx page](https://code.kx.com/insights/1.4/core/objstor/main.html) for information about setup and required environment variables. Example lines:
   * `s3://kxnanotest/firsttest`
   * `gs://kxnanotest/firsttest`
   * `ms://kxnanotest.blob.core.windows.net/firsttest`

The environment executing this test must have the associated cloud vendor CLI set up and configured as if they were manually uploading files to object storage.

You can also test the [cache](https://code.kx.com/insights/1.4/core/objstor/kxreaper.html) impact of the object storage library. The recommended way is to
   * provide an object storage path in `partitions`
   * `DATE=$(date +%m%d_%H%M%S)`
   * run a full test to populate data: `./nano.sh $(nproc) full keep $DATE`.
   * assign an empty directory on a fast local disk to the environment variable `KX_OBJSTR_CACHE_PATH` in file `./config/env`
   * run the test to populate cache: `./nano.sh $(nproc) readonly keep $DATE`
   * run the test again to use cache: `./nano.sh $(nproc) readonly delete $DATE`
   * delete cache files in object storage cache: `source ./config/env; rm -rf ${KX_OBJSTR_CACHE_PATH}/objects`

The random read kdb+ script is deterministic, i.e. it reads the same blocks in consecutive runs. The script uses [roll](https://code.kx.com/q/ref/deal/#roll-and-deal) for selecting random blocks which uses a fixed seed.

Environment variable `THREADNR` plays an important role in random read speed from object storage. See https://code.kx.com/insights/1.6/core/objstor/main.html#secondary-threads for more accounts.

### multiple hosts
For multinode tests (`multihost.sh`), list the other nodes in file `hostlist`. The script will `ssh` into the remote node to start the main script.

Each server in `hostlist` list will create the same number of processes of execution on each node,
and no data is shared between any individual processes.

If running across a cluster of nodes, each of the nodes must be time-synced (e.g. `ntp`).

## Running the scripts

It is recommended to exit all memory-heavy applications. The benchmark uses cca. half of the free memory and creates files on disks accordingly.

Scripts below rely on environment variables (e.g. `QBIN`) so first do

```bash
$ source ./config/kdbenv
$ source ./config/env
```

### nano.sh

Starts multiple processes of execution of the benchmark. Pass `-h` to learn about the parameters.

Example usages

```bash
$ ./nano.sh -p $(nproc)
$ COMPRESS="17 2 6" ./nano.sh -p 8 --noclean
$ ./nano.sh -p 8 -s readonly --noclean -d 0408_152349
```

Typical examples of the number of worker processes to test are 1, 2, 4, 8, 16, 32, 64, 128.

### multihost.sh

This is used to execute kdb+ across multiple hosts in parallel, it grabs the
aggregate throughputs and latencies. This will be based on the entries in `hostlist`.
You can also use this to drive the results from one server, by simply adding
`localhost` as a single entry in `hostlist`.  Or, for a single host calculation, just
run `nano.sh` directly.

Note that the execution of the top-level script `multihost.sh` may require `tty` control
to be added to the sudoers file if you are not already running as root. `multihost.sh` does ssh to the remote host, so you may need to use `~/.ssh/config` to set passwords or identity files.

```bash
$ source ./config/kdbenv
$ source ./config/env
$ ./multihost.sh -p 32
```

### Running several tests with different process count
If you are interested how the storage medium scales with the number of parallel requests, then you can run `runSeveral.sh`. It simply calls `nano.sh` with different process numbers and aggregates the results to a final PSV file. The results are saved in file `results/throughput_total.csv` but this can be overwritten by a command line parameter. Run the script with `--help` to learn about the command line parameters.


### Results

The results are saved as text files in a sub-directory set by the environment variable `RESULTDIR` (by default it is `results`). Each run of `nano.sh` saves
its results in a new directory, timestamped `mmdd_HHMM`, rounded to the nearest minute. Detailed results, including write rates, small IOPS tests, and so on, are
contained in the output files (one per system under test) in the `results/mmdd_HHMM-mmdd_HHMM/` files.

File `results/mmdd_HHMM-mmdd_HHMM/throughput-HOSTNAME` aggregates (calculates the average) the throughput metrics from the detailed result files. Column `throughput` displays the throughput of the test from kdb+ perspective. The read/write throughput based on `iostat` is also displayed. Column `accuracy` tries to capture the impact of [offset problem](#accuracy). For each test, it calculates the maximal difference of start times and divides it by the average test elapsed times.

### log files

The script itself reports the progress on the standard output. The log of each kdb+ process is available in the directory `logs`.

### Accuracy

The bash script starts a controller kdb+ process that is responsible to start each test kdb+ function at the same time on all worker kdb+ processes. This cannot be achieved perfectly, there is some offset so the aggregate results are better to be considered as upper bounds. You can check the startup offset by e.g. checking the `starttime` column of the detailed results files. The more kdb+ workers started the larger the offset is.

### Docker image
A docker image is available for nano on Gitlab and on nexus:

```bash
$ docker pull registry.gitlab.com/kxdev/benchmarking/nano/nano:latest
$ docker pull ext-dev-registry.kxi-dev.kx.com/benchmarking/nano:latest
```

The nano scripts are placed in the docker directory `/opt/kx/app` -see `Dockerfile`

To run the script by docker, you need to mount there directories to target directories
   1. `/tmp/qlic`: contains your kdb+ license file
   1. `/appdir`: results and logs are saved here into subdirectories `results` and `logs` respectively
   1. `/data`: that is on the storage you would like to test. For multi-partition test, you need to overwrite `/opt/kx/app/partitions` with your partition file.

You can overwrite default environment variables (e.g. `THREADNR`) that are listed in `./config/env`.

By default `flush/directmount.sh` is selected as the flush script which requires the `--privileged` options. You can choose other flush scripts by setting the environment variable `FLUSH`. For example, setting `FLUSH` to `/opt/kx/app/noflush.sh` does not require privileged mode.

Example usages:

```bash
$ docker run --rm -it -v $QHOME:/tmp/qlic:ro -v /mnt/$USER/nano:/appdir -v /mnt/$USER/nanodata:/data --privileged ext-dev-registry.kxi-dev.kx.com/benchmarking/nano:latest -p 4
$ docker run --rm -it -v $QHOME:/tmp/qlic:ro -v /mnt/$USER/nano:/appdir -v /mnt/storage1/nanodata:/data1 -v /mnt/storage2/nanodata:/data2 -v ${PWD}/partitions_2disks:/opt/kx/app/partitions:ro -e FLUSH=/opt/kx/app/flush/noflush.sh -e THREADNR=5 ext-dev-registry.kxi-dev.kx.com/benchmarking/nano:latest -p 4
```

## Troubleshooting

### Too many open files
If you see the error `Too many open files` in a log file, then increase the limit by

```bash
$ ulimit -n 2048
```

The controller open a TCP connection to all workers so this error typically occurs with a large number of workers (e.g. 512).

The ulimit change above is temporary and applies only to the current shell session.

### Out of memory
The memory need is proportional to the number of threads (`THREADNR`) for several q operations. For CPU tests, because vector lengths are fixed, the total memory required scales directly with the number of kdb+ workers.

If your test run fails with an OutOfMemory (OOM) error, you can address this by excluding the most memory-intensive tests. The primary tests known for high memory consumption are `.cpu.groupIntLarge` and `.cpu.groupFloatLarge`. Set the `EXCLUDETESTS` environment variable as shown below:

```bash
EXCLUDETESTS=".cpu.groupIntLarge .cpu.groupFloatLarge"
```

and rerun your test.

### Port in use
If the benchmark fails with e.g.

```bash
ERROR: Port 5501 is in use. Maybe leftover kdb+ processes are running.
```

then you either need to stop the process that takes the port or set alternative ports for the benchmark.

Most likely the port is taken by previously failed test so either

```bash
$ killall q
```

or

```bash
$ kill -9 $(pidof q)
```

will do the job. Be careful with these commands as they will terminate ALL q processes running under your user account. Alternatively, you can use `lsof` to find out the process using the port, for example `lsof -i :5501`.

All kdb+ workers and the kdb+ controller need a port. Environment variables `WORKERBASEPORT` and `CONTROLLERPORT` exported in `nano.sh` set these ports. Feel free to modify them. For `N` workers, ports `WORKERBASEPORT+1` through `WORKERBASEPORT+N` will be used.

## Technical Details

The script calculates the throughput (MiB/sec) of an operation by calculating the data size and the elapsed time of the operation.

Script `./nano.sh` executes 7 major tests:
   1. CPU
   1. Write
   1. Sequential read
   1. Sequential reread
   1. Meta
   1. Random read and reread
   1. xasc

If the scope is readonly then [Write](#Write) and [Meta](#Meta) tests are omitted.

All tests start multiple kdb+ processes (set by the parameter `-p` of `./nano.sh`) each having its own working space on the disk.

The cache is flushed before each test except for reread tests.

We detail each test in the next section.

### CPU (`cpu.q`)
   1. starts a few tests on in-memory lists that mainly stresses the CPU and memory. It uses tiny, small (16k long), medium and large vectors fitting into L1, L2, L3 caches and into memory. Test include
      * creating random permutation
      * sorting
      * calculating deltas
      * generating indices based on modulo
      * calculates moving and weighted averages
      * arithmetics and implicit iteration
      * serialization, deserialization and compressesion

### Write (`write.q`)
   1. performs three write tests
      1. `open append tiny`: appending tiny integer list to the end of list (this operation includes opening and closing a file): `[; (); ,; 2 3 5 7]`
      1. `append tiny`: appending tiny integer list to a handle of a kdb+ file: `H: hopen ...; H 2 3 5 7`
      1. `open replace tiny`: overwriting file content with two integers: `[; (); :; 42 7]`
   1. `create list`: creates a list in memory (function `til`), i.e. allocating memory and filling it with consecutive longs. The length of the list depends is set by `SEQWRITETESTLIMIT`.
   1. `write rate`: writes the list (`set`) to file `readtest`.
   1. `sync rate`: calling system command `sync` on `readtest`.
   1. `open append small`: appends a small integer list many times to a file.
   1. `open append large sym`: appends a large block a few times to a file. The result file is the `sym` column of a splayed table used in the `xasc` test.
   1. saves files for meta test:
      1. two long lists of length 63k
      1. a long list of length 31M


### Sequential read (`read.q`)
   1. memory maps (`get`) file `readtest` to variable `mapped`
   1. attempts to force `readtest` to be resident in memory (`-23!`) by calling the Linux command `madvice` with parameter `MADV_WILLNEED`.
   1. calls `max` on the `mapped` that sequentially marches through all pages
   1. performs binary read by calling `read1`

### Sequential reread (`reread.q`)
This is the same as the first two steps of test read. We do not flush the cache before this test so the data pages are already in cache. Reread is not expected to involve any data copy so its execution (`mmap` and `madvise`) should be much faster than [Read](#Read).

### Meta (`meta.q`)
The meta operations are executed (variable `N`) thousand times and the average execution time is returned.

   1. opening then closing a kdb+ file: `hclose hopen x`
   1. getting the size of a file: `hcount`
   1. read and parse kdb+ data: `get`
   1. locking file. [Enum extend](https://code.kx.com/q/ref/enum-extend/) is used for this which achieves more.

### Random read
This test consists of four subtests. Each subtest random reads 800 MiB of data by indexing a list stored on disk. Consecutive integers are used for indexing. Each random read uses a different random offset ([deal](https://code.kx.com/q/ref/deal/#roll-and-deal)). 800 MB is achieved either by reading blocks of sizes 1M, 64k or 4k. Each random read can also perform a `mmap`. This test is denoted by a `mmaps` postfix, e.g. `mmaps,random read 64k` stands for random reading integer list of size 64k after a memory map.

In a typical `select` statement with a `where` clause kdb+ does random reads with memory mappings. If you started your kdb+ process with [.Q.MAP](https://code.kx.com/q/ref/dotq/#map-maps-partitions) then memory mapping is done during `.Q.MAP` and the select statement only does a random read.

The throughput is based on the *useful* data read. For example, if you index a vector of long by 8000 consecutive numbers then the useful data size is 8x8000 bytes (the size of a long is 8 bytes). In reality, Linux may read much more data from the disk due to e.g. the prefetch technique. Just change the content of  `/sys/block/DBDEVICE/queue/read_ahead_kb` and see how the throughput changes. The disk may be fully saturated but the useful throughput is smaller.

### xasc
The script does an on-disk sort by `xasc` on `sym`. The second test is applying attribute `p` on column `sym`.