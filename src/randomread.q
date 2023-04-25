/ Copyright Kx Systems 2023
/ q randomread.q -listsize N / hardware timings
include: {
  curFile: value[{}][6];
  system "l ", sublist[1+last where curFile = "/"; curFile], x;
  }

include "common.q";
if[0=count .z.x;STDOUT">q ",(string .z.f)," -listsize N -threads N [-withmmap] -rl remotelocation";exit 1]

/ throw a list of longs into shared mem prior to the prep phase write out
/ mixed data. so that some compression testing going on

/ hopefully we flushed before this...

k64: 64*k
totalreadInB: SIZEOFLONG * 100*M;

randomread:{[blocksize]
  STDOUT "Start random reads ", string blocksize;
  sT:.z.n;
  {[f;blocksize;offset] f offset+til blocksize;}[f;blocksize]each (totalreadInB div SIZEOFLONG * blocksize)?neg[blocksize]+count f:get lrfile;
  milly:tsToMsec .z.n-sT;
  STDOUT "End random reads ", string[blocksize], " - ", string[totalreadInB % 1000*milly]," MiB/sec";
  };

randomreadwithmmap:{[blocksize]
  STDOUT "Start random reads with mmaps ", string blocksize;
  sT:.z.n;
  {[blocksize; offset] get[lrfile] offset+til blocksize}[blocksize] each (totalreadInB div SIZEOFLONG * blocksize)?neg[blocksize]+hcount[lrfile]div SIZEOFLONG;
  milly:tsToMsec .z.n-sT;
  STDOUT "End random reads with mmaps ", string[blocksize], " - ", string[totalreadInB % 1000*milly]," MiB/sec";
  };

fn: $[`withmmap in argvk; randomreadwithmmap; randomread]
fn "I"$first argv `listsize;

if [not `debug in argvk; exit 0];
