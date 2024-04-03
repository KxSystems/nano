system "l src/log.q";

argvk:key argv:first each .Q.opt .z.x

resfileprefix: "," vs argv `inputs;
output: hsym `$argv `output;


results: raze {("ISS*FFSFF"; enlist "|") 0:x} each `$resfileprefix cross read0[`hostlist] ,\: ".psv";
aggregate: select sum numproc, avg accuracy, sum throughput, sum iostat_read_throughput, sum iostat_write_throughput, first unit
    by testtype, test, qexpression from results


output 0: "|" 0: 0!aggregate

if[not `debug in argvk; exit 0];
