include: {
  curFile: value[{}][6];
  system "l ", sublist[1+last where curFile = "/"; curFile], x;
  }

include "common.q";

STDOUT "v",ioq;
STDOUT (string .z.p)," - ",(string `date$.z.p)," ",(string `minute$.z.p)," ",(string .z.h)," - times in ms for single execution";

/ read whole file, no write
sT:.z.n;
STDOUT "Start thread -23! mapped read ",string sT;
mapped:get [lrfile];
mT: .z.n;
{-23!x;} mapped;
milly:tsToMsec .z.n-sT;
STDOUT "End thread -23! mapped read (get ratio ", fix[1; 100* tsToMsec[mT-sT] % milly],"%) ", string milly;

sT:.z.n;
STDOUT "Start thread walklist ",string sT;
max mapped;
milly:tsToMsec .z.n-sT;
STDOUT "End thread walklist ",string milly;

// Why do we need this if we exit anyway?
STDOUT"Clearing Heap....";
.Q.gc[];

if [not `debug in argvk; exit 0];