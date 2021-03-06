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
useful utilty to examine OS settings, scalability, and identify any pinch points related 
to the kdb+ I/O models.

Multinode client testing can be used to either test a single namespace solution, or to test read/write rates for multiple hosts using multiple different storage targets on a shared storage device.


## Installing and configuring

Place these scripts in a single working directory. 
**Do not** place these scripts directly in the destination location being used for the IO testing, as that directory may be unmounted during the tests.

The scripts can best be run as root user. If root user is not available to you, the 
`flush.sh` scripts will have to be placed in the sudo list by your systems administrator. 
Include the q binary directory location in `PATH` and edit `QHOME` setting in the `mthread.sh` 
script, by hand.  Set the variable `QHOME` to point to the q home directory and set to export 
in the environment.

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

Uncomment and fix `QHOME` and `PATH` in `mthread.sh`

Then, edit "partitions" and "hostlist" to reflect your configuration:


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

This bash script file needs to be created. Samples of tyical flush scripts are 
supplied. Choose the one most appropriate, make a copy of it as `flush.sh` and 
edit to your site-specific settings.

This script `flush.sh` must be set up to be run under sudo root priviledges, 
either run as `root` or `sudo`.


## Calling scripts

### multihost.sh 

This is used to execute kdb+ across multiple hosts in parallel, it grabs the 
aggregate througputs and latencies. This will be based on the entries in hostlist. 
You can also use this to drive the results from one server, by simply adding 
`localhost` as a single entry in hostlist.  Or, for a single host calculation, just 
run `mthread.sh` directly.


### mthread.sh

Executes multiple processes of execution of the benchmark on the execution host

This takes three arguments :

1. The number of executions of q on each node, integer.
2. `delete | keep`. Flag, determines if the data created from each thread 
   is kept on the filesytem. Useful for testing performance on a fuller 
   filesystem, which could be modelled through running multiple iterations 
   of `mthread.sh`.
3. `compress`. Flag, if  set, inbuilt q file compression algorithm 1 will 
   be used, with 256KB blocksize.  If undefined, there is no 
   compression (default)

Typical examples for the number of threads to test are 1, 2, 4, 8, 16, 32, 64.  
The script will consume approx approx 85% of available memory during the latter 
stages of the "run" phase, as lists are modified.
If the server has 32&nbsp;GB of DRAM, or less, the results will be sub-optimal.

### mthread-ro.sh & multihost-ro.sh

This test exercises read-only data (dates) that have already been created by previous 
runs of `mthread.sh`. The additional argument to this is the name of the directory 
containing the test data. 
This version of the script is useful where the file system is ‘tiered’ and you wish 
to read from files that might be retired to a long-term or slower tier, for example 
when testing files that you know are migrated to an object store, via the file system 
layer.


## Results & potential errors

The results are saved as text files in a sub-directory of the working directory, which 
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
