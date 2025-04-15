/ Copyright Kx Systems 2023
/ q randomread.q -listsize N / hardware timings

system "l src/common.q";

if[0=count .z.x;STDOUT">q ",(string .z.f)," -listsize N [-withmmap] -db DBDIR -result RESULT.PSV -testtype [read disk|read mem]";exit 1]

/ throw a list of longs into shared mem prior to the prep phase write out
/ mixed data. so that some compression testing going on

/ hopefully we flushed before this...


k64: 64*k
totalreadInB: `long$MODIFIER * SIZEOFLONG * "J"$getenv `RANDREADNUMBER;
.qlog.info "Reading altogether ", string[totalreadInB], " bytes of data";
sizeM: (4000 64000 1000000 div SIZEOFLONG)!("4k"; "64k"; "1M");  // good enough for now
pageLength: 4096 div SIZEOFLONG / the page size is 4k in Linux

randomread:{[blocksize:`j]
  blockNr: totalreadInB div blocksize * FILENRPERWORKER;
  blockLength: blocksize div SIZEOFLONG;
  .qlog.info "Indexing each memory-maped file vectors with ", string[blockNr], " number of continuous blocks of size ", string blocksize;
  fs:get each fsRandomRead;
  offsetlists: pageLength*neg[blockNr]?/:(neg[blockLength]+count each fs) div pageLength;
  :{[fs; offsetlists; blockLength; dontcare]
    idxBase: til blockLength;
    idxpairs: 0N?raze til[FILENRPERWORKER] ,/:' offsetlists;
    sT:.z.n;
    ({[fs;idxBase;fidx;offset] fs[fidx] offset+idxBase;}[fs;idxBase].) each idxpairs;
    eT: .z.n;
    writeRes[argv[`testtype];".randomread.", argv[`testname],"|random read ",sizeM[blockLength];"+,@"; sum count each offsetlists; blockLength; sT, eT; fix[2;getMBPerSec[blockLength*sum count each offsetlists; eT-sT]];"MB/sec\n"]
    }[fs; offsetlists; blockLength]
  };

randomreadwithmmap:{[blocksize:`j]
  blockNr: totalreadInB div blocksize * FILENRPERWORKER;
  blockLength: blocksize div SIZEOFLONG;
  .qlog.info "Memory-maping and indexing each file vectors with ", string[blockNr], " number of continuous blocks of size ", string blocksize;
  offsetlists: pageLength*neg[blockNr]?/:(neg[blockLength]+(-14+hcount each fsRandomRead)div SIZEOFLONG) div pageLength;  // 14 bytes overhead
  :{[offsetlists; blockLength; dontcare]
    idxBase: til blockLength;
    idxpairs: 0N?raze fsRandomRead ,/:' offsetlists;
    sT:.z.n;
    ({[idxBase;f;offset] get[f] offset+idxBase;}[idxBase].) each idxpairs;
    eT: .z.n;
    writeRes[argv[`testtype];".randomread.", argv[`testname], "|mmap,random read ",sizeM[blockLength];"get,+,@"; sum count each offsetlists; blockLength; sT, eT; fix[2;getMBPerSec[blockLength*sum count each offsetlists; eT-sT]];"MB/sec\n"];
    }[offsetlists; blockLength]
  };

fn: $[`withmmap in argvk; randomreadwithmmap; randomread]
.Q.dd[`.randomread; `$argv[`testname]] set fn "J"$argv `listsize;

sendTests[controller;DB;`.randomread]

.qlog.info "Ready for test execution";