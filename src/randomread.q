/ Copyright Kx Systems 2023
/ q randomread.q -listsize N / hardware timings

system "l src/common.q";

if[0=count .z.x;STDOUT">q ",(string .z.f)," -listsize N [-withmmap] -db DBDIR -result RESULT.PSV -testtype [read disk|read mem]";exit 1]

/ throw a list of longs into shared mem prior to the prep phase write out
/ mixed data. so that some compression testing going on

/ hopefully we flushed before this...

RANDOMREADMODIFIER: 1f^MEMRATIOMODIFIERS `$getenv `RANDOMREADSIZE
k64: 64*k
totalreadInB: `long$RANDOMREADMODIFIER * SIZEOFLONG * 100*M;
.qlog.info "Reading altogether ", string[totalreadInB], " bytes of data";
sizeM: 64000 1000000!("64k"; "1M");

randomread:{[blocksize]
  blockNr: totalreadInB div SIZEOFLONG * blocksize;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of length ", string blocksize;
  f:get fRandomRead;
  offsets: blockNr?neg[blocksize]+count f;
  :{[f; offsets; blocksize; dontcare]
    sT:.z.n;
    blocksize {[f;blocksize;offset] f offset+til blocksize;}[f]/: offsets;
    eT: .z.n;
    writeRes[ argv[`testtype];"random read ",sizeM[blocksize];"til,@"; sT; eT; fix[2;totalreadInB % M*tsToSec eT-sT];"MiB/sec\n"]
    }[f; offsets; blocksize]
  };

randomreadwithmmap:{[blocksize]
  blockNr: totalreadInB div SIZEOFLONG * blocksize;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of length ", string blocksize;
  offsets: blockNr?neg[blocksize]+(-14+hcount fRandomRead)div SIZEOFLONG;  // 14 bytes overhead
  :{[offsets; blocksize; dontcare]
    sT:.z.n;
    blocksize {[blocksize; offset] get[fRandomRead] offset+til blocksize;}/: offsets;
    eT: .z.n;
    writeRes[argv[`testtype];"mmap,random read ",sizeM[blocksize];"get,til,@"; sT; eT; fix[2;totalreadInB % M* tsToSec eT-sT];"MiB/sec\n"];
    }[offsets; blocksize]
  };

fn: $[`withmmap in argvk; randomreadwithmmap; randomread]
.test.randomread: fn "I"$argv `listsize;

controller (`addWorker; ) .Q.dd[`.test;] each except[; `] key .test;
