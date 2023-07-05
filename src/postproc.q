system "l src/log.q";

argvk:key argv:first each .Q.opt .z.x

resfileprefix: "," vs argv `inputs;
nproc: "I"$argv `processes;
output: hsym `$argv `output;


results: raze {("SS*NNFS"; enlist "|") 0:x} each `$resfileprefix cross string[1+til nproc] ,\: ".psv";
aggregate: select numproc: count result, accuracy: 5 sublist string 100*1- (max[starttime] - min starttime) % avg endtime-starttime, sum result, first unit by testtype, test, qexpression from results where not unit = `ms;

output 0: "|" 0: `numproc xcols 0!aggregate;

if[ 0 < exec count i from aggregate where not numproc = nproc;
    .qlog.error "The following tests were not executed by all processes: ",
    "," sv string exec distinct test from aggregate where not numproc = nproc;
    exit 1
    ];

if[not `debug in argvk; exit 0];
