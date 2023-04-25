include: {
  curFile: value[{}][6];
  system "l ", sublist[1+last where curFile = "/"; curFile], x;
  }

include "common.q";

STDOUT"v",ioq;


STDOUT"list creation...";
sT:.z.n;
/ 8 bytes in a word (64bit version of kdb+ only)
SAMPLESIZE:`long$ssm%SIZEOFLONG

privmem:til SAMPLESIZE;
milly:tsToMsec .z.n-sT;
listsize: ssm%(2 xexp 20);  // FERENC: Why not -22!privmem instead of ssm?
STDOUT"create list"," - ",(string floor 0.5+listsize%0.001*milly)," MiB/sec";

if[count getenv `COMPRESS;
  STDOUT "setting compression parameters to ", getenv `COMPRESS;
  .z.zd: "J"$" " vs getenv `COMPRESS];

STDOUT "persisting the list as a file...";
sT:.z.n;
lrfile set privmem;
mT: .z.n
system"sync";
milly:tsToMsec .z.n-sT;
STDOUT"sync write rate (set ratio: ", fix[1; 100* tsToMsec[mT-sT] % milly],"%): "," - ",(string floor 0.5+listsize%0.001*milly)," MiB/sec";
/ re read test sizing
fsize:hcount lrfile;
STDOUT"filesize ",(string fsize%M)," MiB";
fileopsmem:`long$til 16*k;
ffileo set fileopsmem;
ffile1 set fileopsmem;
ffile2 set fileopsmem;
ffile3 set fileopsmem;
/ more generous for hcount
hcn:`long$til 4*M;
ffile4 set hcn;
ffile5 set fileopsmem;
ffile6 set fileopsmem;

//////////////////////////////////////////
/  this is deprecated and currently unused...
WSAMPLESIZE:`long$ssm%16
write:{[file]
    / this is to allow any 3rd party performance monotoring tools to see a time gap
  system"sleep 5";
  STDOUT(string .z.p);
  STDOUT"write `",(string file)," - ",(string floor 0.5+(ssm%(2 xexp 20))%0.001*value "\\t `",(string file)," 1:WSAMPLESIZE#key 11+rand 111")," MiB/sec";hdel file;
  STDOUT(string .z.p);
  }
//////////////////////////////////////////

if [not `debug in argvk; exit 0];