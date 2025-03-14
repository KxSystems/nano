system "l src/log.q";

argvk:key argv:first each .Q.opt .z.x

resfileprefix: "," vs argv `inputs;
iostatfile: argv `iostatfile
nproc: "I"$argv `processes;
outputprefix: argv `outputprefix;
outthroughput: hsym `$outputprefix,"throughput.psv"
outlatency: hsym `$outputprefix,"latency.psv"

results: raze {("ISSS*IJNNFS"; enlist "|") 0:x} each `$resfileprefix cross string[1+til nproc] ,\: ".psv";
throughput: select numproc: count result, first threadnr, accuracy: 5 sublist string 100*1- (max[starttime] - min starttime) % avg endtime-starttime, throughput: sum result, first unit by testid, testtype, test, qexpression from results where not unit = `ms;
latency: select numproc: count result, first threadnr, accuracy: 5 sublist string 100*1- (max[starttime] - min starttime) % avg endtime-starttime, avgLatency: avg result, maxLatency: max result, first unit by testid, testtype, test, qexpression from results where unit = `ms;
iostat: ("SFFF"; enlist "|") 0: `$iostatfile;

outthroughput 0: "|" 0: `numproc`threadnr xcols delete testid from 0!throughput lj `testid xkey iostat;
outlatency 0: "|" 0: `numproc`threadnr xcols delete testid from 0!latency;

if[ 0 < exec count i from throughput where not numproc = nproc;
    .qlog.error "The following tests were not executed by all processes: ",
    "," sv string exec distinct test from throughput where not numproc = nproc;
    exit 1
    ];

if[not `debug in argvk; exit 0];
