system "l src/log.q";

resfileprefix: "," vs first .z.x;
nproc: "I"$.z.x 1;
output: hsym `$last .z.x;


results: raze {("*S*FS"; enlist "|") 0:x} each `$resfileprefix cross string[1+til nproc] ,\: ".psv";
aggregate: select numproc: count result, count[result] * min result, first unit by testtype, test, qexpression from results where not unit = `ms;

output 0: "|" 0: `numproc xcols 0!aggregate;

if[ 0 < exec count i from aggregate where not numproc = nproc;
    .qlog.error "The following tests were not executed by all processes: ",
    "," sv string exec distinct test from aggregate where not numproc = nproc;
    exit 1];

exit 0
