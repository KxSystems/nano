system "l src/log.q";

argvk:key argv:first each .Q.opt .z.x

resfileprefix: "," vs argv `inputs;
iostatfile: argv `iostatfile
nproc: "I"$argv `processes;
output: hsym `$argv `output;


results: raze {("SSS*IJNNFS"; enlist "|") 0:x} each `$resfileprefix cross string[1+til nproc] ,\: ".psv";
aggregate: select numproc: count result, accuracy: 5 sublist string 100*1- (max[starttime] - min starttime) % avg endtime-starttime, sum result, first unit by testid, testtype, test, qexpression from results where not unit = `ms;
iostat: ("SFF"; enlist "|") 0: `$iostatfile;

output 0: "|" 0: `numproc xcols delete testid from 0!aggregate lj `testid xkey iostat;

if[ 0 < exec count i from aggregate where not numproc = nproc;
    .qlog.error "The following tests were not executed by all processes: ",
    "," sv string exec distinct test from aggregate where not numproc = nproc;
    exit 1
    ];

if[not `debug in argvk; exit 0];
