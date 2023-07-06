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
sizeM: (64000 1000000 div SIZEOFLONG)!("64k"; "1M");  // good enough for now

randomread:{[blocksize]
  blockNr: totalreadInB div blocksize;
  blockLength: blocksize div SIZEOFLONG;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of size ", string blocksize;
  f:get fRandomRead;
  offsets: blockNr?neg[blockLength]+count f;
  :{[f; offsets; blockLength; dontcare]
    sT:.z.n;
    blockLength {[f;blockLength;offset] f offset+til blockLength;}[f]/: offsets;
    eT: .z.n;
    writeRes[ argv[`testtype];"random read ",sizeM[blockLength];"til,@"; count offsets; blockLength; sT, eT; fix[2;totalreadInB % M*tsToSec eT-sT];"MiB/sec\n"]
    }[f; offsets; blockLength]
  };

randomreadwithmmap:{[blocksize]
  blockNr: totalreadInB div blocksize;
  blockLength: blocksize div SIZEOFLONG;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of size ", string blocksize;
  offsets: blockNr?neg[blockLength]+(-14+hcount fRandomRead)div SIZEOFLONG;  // 14 bytes overhead
  :{[offsets; blockLength; dontcare]
    sT:.z.n;
    blockLength {[blockLength; offset] get[fRandomRead] offset+til blockLength;}/: offsets;
    eT: .z.n;
    writeRes[argv[`testtype];"mmap,random read ",sizeM[blockLength];"get,til,@"; count offsets; blockLength; sT, eT; fix[2;totalreadInB % M* tsToSec eT-sT];"MiB/sec\n"];
    }[offsets; blockLength]
  };

fn: $[`withmmap in argvk; randomreadwithmmap; randomread]
.test.randomread: fn "I"$argv `listsize;

controller (`addWorker; ) .Q.dd[`.test;] each except[; `] key .test;
