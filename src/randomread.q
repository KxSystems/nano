/ Copyright Kx Systems 2023
/ q randomread.q -listsize N / hardware timings

system "l src/common.q";

if[0=count .z.x;STDOUT">q ",(string .z.f)," -listsize N [-withmmap] -db DBDIR -result RESULT.PSV -testtype [read disk|read mem]";exit 1]

/ throw a list of longs into shared mem prior to the prep phase write out
/ mixed data. so that some compression testing going on

/ hopefully we flushed before this...


k64: 64*k
totalreadInB: `long$MODIFIER * SIZEOFLONG * 100*1000*1000;
.qlog.info "Reading altogether ", string[totalreadInB], " bytes of data";
sizeM: (4000 64000 1000000 div SIZEOFLONG)!("4k"; "64k"; "1M");  // good enough for now

randomread:{[blocksize:`j]
  blockNr: totalreadInB div blocksize;
  blockLength: blocksize div SIZEOFLONG;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of size ", string blocksize;
  f:get fRandomRead;
  offsets: blockNr?neg[blockLength]+count f;
  :{[f; offsets; blockLength; dontcare]
    idxBase: til blockLength;
    sT:.z.n;
    idxBase {[f;idxBase;offset] f offset+idxBase;}[f]/: offsets;
    eT: .z.n;
    writeRes[argv[`testtype];".randomread.", argv[`testname],"|random read ",sizeM[blockLength];"+,@"; count offsets; blockLength; sT, eT; fix[2;getMBPerSec[blockLength*count offsets; eT-sT]];"MB/sec\n"]
    }[f; offsets; blockLength]
  };

randomreadwithmmap:{[blocksize:`j]
  blockNr: totalreadInB div blocksize;
  blockLength: blocksize div SIZEOFLONG;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of size ", string blocksize;
  offsets: blockNr?neg[blockLength]+(-14+hcount fRandomRead)div SIZEOFLONG;  // 14 bytes overhead
  :{[offsets; blockLength; dontcare]
    idxBase: til blockLength;
    sT:.z.n;
    idxBase {[idxBase; offset] get[fRandomRead] offset+idxBase;}/: offsets;
    eT: .z.n;
    writeRes[argv[`testtype];".randomread.", argv[`testname], "|mmap,random read ",sizeM[blockLength];"get,+,@"; count offsets; blockLength; sT, eT; fix[2;getMBPerSec[blockLength*count offsets; eT-sT]];"MB/sec\n"];
    }[offsets; blockLength]
  };

fn: $[`withmmap in argvk; randomreadwithmmap; randomread]
.Q.dd[`.randomread; `$argv[`testname]] set fn "J"$argv `listsize;

sendTests[controller;DB;`.randomread]

.qlog.info "Ready for test execution";