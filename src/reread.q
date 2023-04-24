include: {
  curFile: value[{}][6];
  system "l ", sublist[1+last where curFile = "/"; curFile], x;
  }

include "common.q";
STDOUT"v",ioq;
STDOUT(string .z.p)," - ",(string `date$.z.p)," ",(string `minute$.z.p)," ",(string .z.h)," - times in ms for single execution";

/ read whole file, no write
sT:.z.n;
STDOUT("Start thread -23! mapped reread ",string sT);
mapped: get lrfile;
{-23!x;} mapped;
milly:tsToMsec .z.n-sT;
STDOUT("End thread -23! mapped reread ",string milly);

if [not `debug in argvk; exit 0];