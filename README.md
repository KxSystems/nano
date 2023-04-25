# nano benchmark README v1.18.  January 2020.

© Kx Systems 2020


"nano" calculates basic raw I/O capability of non-volatile storage, as measured from the perspective of kdb+

It measures results from running on one server, or aggregated across several servers.
Servers can be attached either directly to storage, or connected to a
distributed/shared storage system.

The throughput and latency measurements are taken directly from kdb+/q,
results include read/mmap allocation, creation and ingest of data.
There is an option to test compressed data via algorithms on the client or, in the
case of a storage system supporting built-in compression, that compression can be
measured when being entirely off-loaded onto the target storage device.

This utility is used to confirm the basic expectations for storage subsystem
prior to a more detailed testing regime.

"nano" does not simulate parallel IO rates via the creation of multi-column tick databases,
but instead shows both a maximum I/O capability for kdb+ on the system under test, and is a
useful utility to examine OS settings, scalability, and identify any pinch points related
to the kdb+ I/O models.

Multi-node client testing can be used to either test a single namespace solution, or to test read/write rates for multiple hosts using multiple different storage targets on a shared storage device.


## Installing and configuring

Place these scripts in a single working directory.
**Do not** place these scripts directly in the destination location being used for the IO testing, as that directory may be unmounted during the tests.

The scripts can best be run as root user. If root user is not available to you, the
`flush.sh` scripts will have to be placed in the sudo list by your systems administrator.
Set the variable `QHOME` in config file `env` to point to the q home directory. The script also tries to figure out the location of the kdb+ binary in case `QHOME` is not set up properly.

Lack of super-user permissions or incorrect `$PATH` or incorrect `$QHOME` settings are
the primary reasons behind the nano script failing on the very first run as well
as the `flush.sh` script not being linked to or created.

If testing across multiple nodes in parallel, ensure that the above variables will be
picked up on execution of the scripts on remote nodes as well as the head or
master/login nodes.

Note that execution of the top level script `multihost.sh` may require `tty` control
to be added to the sudoers file if you are not already running as root.

Do not proceed if you do not have these privileges.

If the scripts are to be executed across multiple nodes, place the directory
containing them in a shared (e.g NFS) directory.

Finally, edit "partitions" and "hostlist" to reflect your configuration:


### partitions

Edit the partitions configuration file to either:

-   Contain one line representing the pathname to a single directory,
    without naming any underlying sub-segments/partitions,

    or,

-   Contain multiple lines, each representing one partition to test.

Use absolute path names. Using a single line entry is a simple way of testing
a single shared/parallel file-system. This would allow the shared FS to control the
distribution of the data across a number of storage targets (objects, et al)
automatically.

With multiple entries in the partitions table, this will allow you to populate
files in individual directories described in this list. This allows for explicit
creations of one file system indexed by target path.

For example, if there is one entry on the partitions file, thus:
```
/mnt/mytestdir
```
This directory would be automatically populated with test data files created by
each active thread as defined in the argument to `mthread.sh`, and by each active
server described in `hostlist`.

Multiple lines in the file `partitions` would be used when you have a list of
directory names already declared and created.  For example if you have one
filesystem per LUN presented to the server, this would be the method to use.


### hostlist

Just use one entry if this is a single server test. It is more legible if you use
given hostnames instead of using `localhost`, although both will work.
If testing multiple servers, add each server name to this file.  Each server in
this list will create the same number of processes of execution on each node,
and no data is shared between any individual processes.


### flush.sh

This bash script file needs to be created. Samples of typical flush scripts are
supplied. Choose the one most appropriate, make a copy of it as `flush.sh` and
edit to your site-specific settings.

This script `flush.sh` must be set up to be run under sudo root privileges,
either run as `root` or `sudo`.


## Calling scripts

### multihost.sh

This is used to execute kdb+ across multiple hosts in parallel, it grabs the
aggregate throughputs and latencies. This will be based on the entries in `hostlist`.
You can also use this to drive the results from one server, by simply adding
`localhost` as a single entry in `hostlist`.  Or, for a single host calculation, just
run `mthread.sh` directly.


### mthread.sh

Executes multiple processes of execution of the benchmark on the execution host

This takes three arguments :

1. The number of executions of q on each node, integer.
1. `full|readonly` to select between full and read only test. Subtests `prepare` and `meta` are not executed in readonly tests.
1. `delete | keep`. Flag, determines if the data created from each thread
   is kept on the filesystem. Useful for testing performance on a fuller
   filesystem, which could be modeled through running multiple iterations
   of `mthread.sh`.
1. Optional: date. This test assume that data was already generated (`keep` flag was used the previous test). Format of `%m%d:%H%M` is expected like `0404:1232`.

If you would like the data to be compressed then pass environment variable `COMPRESS` with the [kdb+ compression parameters](https://code.kx.com/q/kb/file-compression/#compression-parameters).

Example usages

```bash
$ ./mthread.sh $(nproc) full delete
$ COMPRESS="17 2 6" ./mthread.sh 8 full keep
$ ./mthread.sh 8 readonly keep 0404:1232
```


Typical examples for the number of threads to test are 1, 2, 4, 8, 16, 32, 64, 128.
The script will consume approximately 85% of available memory during the latter
stages of the "run" phase, as lists are modified.
If the server has 32GB of DRAM, or less, the results will be sub-optimal.

### multihost-ro.sh

This test exercises read-only data (dates) that have already been created by previous
runs of `mthread.sh`. The additional argument to this is the name of the directory
containing the test data.
This version of the script is useful where the file system is ‘tiered’ and you wish
to read from files that might be retired to a long-term or slower tier, for example
when testing files that you know are migrated to an object store, via the file system
layer.

### Running several tests with different thread count
If you are interested how the storage medium scales with the number of parallel requests, then you can run `runSeveral.sh`. It simply calls `mthread.sh` with different thread numbers and does a log processing to generate a result CSV file.

## Results & potential errors

The results are saved as text files in a sub-directory of directory `results` , which
by default should be the scripts directory. Each run of the `mthread.sh` will save
its results in a new directory, timestamped MMDD:HHMM, rounded to the nearest minute.

If running across a cluster of nodes, each of the nodes must be time-synced
(e.g. ntp).

The script itself will report some key results on the standard output.
But the "aggregate*" files contain the real results data, sorted by host and process count, aggregated.

Other detailed results, including write rates, small IOPS tests, and so on, are
contained in the output files (one per system under test) in the results directory.

If the utility fails to run correctly, and there are no errors presented on the
standard output, you should check in the results files for error messages from the
execution of q, or the shell script.

### Accuracy

The bash script starts several, single-threaded kdb+ processes in parallel (if the `thread` parameter is larger than 1) and assumes that they start their work (e.g. `til`, `set`, `get`, `-23!`, etc.) at the same time. This is not necessarily true, there is some offset (e.g. due to each kdb+ processes verifies license over the internet) so the aggregate results is better to be considered as upper bounds. You can check the startup offset by e.g. checking the output of read test that displays current time after license verification. In our case the offset is around 6 msec.

The more memory the box has (hence the more data is used), the more marginal the offset issue is. It also helps if you have a kdb+ license that is bound to the host (`hostname -f`) and does not ping the license server.

## Technical Details

The script calculates throughput (MiB/sec) of an operation by calculating the data size and the elapsed time of the operation.

Script `./mthread.sh` executes 5 major tests:
   1. Prepare
   1. Read
   1. Reread
   1. Meta
   1. Random read

In read-only tests (when DB dir parameter is passed to `mthread.sh` as a third parameter) the [Prepare](#Prepare) and [Meta](#Meta) tests are omitted.

All tests start multiple kdb+ processes (set by the first parameter of `./mthread.sh`) each having its own working space on the disk.

The cache is flushed before each tests except reread.

We detail each test in the next section.

### Prepare (`prepare.q`)
   1. `create list`: creates a list in memory (function `til`), i.e. allocating memory and filling it with consecutive longs. The length of the list depends on the
      1. available free memory (returned by system command `free`)
      1. percentage of memory to use (variable `MEMUSAGERATE`, default 40%) and
      1. the thread count.
   1. `sync write rate`: writes the list (`set`) to file `readtest` and calls system command `sync`. The ratio of `set` to the overall time is displayed in parenthesis.
   1. displays file size (`hcount`)
   1. saves four long lists of length 16 k (size 128 k)
   1. saves an long list of size 4 M (size 32 M)
   1. saves three long lists of size 16 k

### Read (`read.q`)
   1. memory maps (`get`) file `readtest` to variable `mapped`
   1. attempts to force `readtest` to be resident in memory (`-23!`) by calling Linux command `madvice` with parameter `MADV_WILLNEED`.
   1. calls `max` on the `mapped` that sequentially marches through all pages

### Reread (`reread.q`)
This is the same as the first two steps of test read. We do not flush cache before this test so the data pages are already in cache. Reread is not expected to involve any data copy so its execution (`mmap` and `madvise`) should be much faster than [Read](#Read).

### Meta (`meta.q`)
The meta operations are executed (variable `N`) thousand times and the average execution time is returned.

   1. opening then closing a kdb file: `hclose hopen x`
   1. appending two integers to the end of list (this operation includes opening and closing a file): `[; (); ,; 2 3]`
   1. overwriting file content with two integers: `[; (); :; 2 3]`
   1. appending two integers to a handle of a kdb file: `H: hopen ...; H 2 3`
   1. getting the size of a file: `hcount`
   1. read binary data: `read1`
   1. read and parse kdb+ data: `get`
   1. locking file. (Enum extend)[https://code.kx.com/q/ref/enum-extend/] is used for this which achieves more.

### Random read
This test consists of four subtests. Each subtest random reads 800 MiB of data by indexing a list stored on disk. Consecutive integers are used for indexing. Each random read uses a different random offset ([deal](https://code.kx.com/q/ref/deal/#roll-and-deal)). 800 MiB is achieved either by either reading 100 times 1M or 1600 times 64k 8-byte integers. Each random read can also perform a `mmap`. This test is denoted by a `with mmaps` postfix, e.g. `Random 64k with mmaps` stands for random reading integer list of size 64k after a memory map.

In a typical `select` statement with a `where` clause kdb+ does random reads with memory mappings. If you started your kdb+ process with [.Q.MAP](https://code.kx.com/q/ref/dotq/#map-maps-partitions) then memory mapping is done during `.Q.MAP` and the select statement only does a random read.