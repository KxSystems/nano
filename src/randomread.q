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
  sT:.z.n;
  blocksize {[f;blocksize;offset] f offset+til blocksize;}[f]/: offsets;
  elapsed:tsToSec .z.n-sT;
  resultH argv[`testtype], "|random read ",sizeM[blocksize],"|til,@|", fix[2;totalreadInB % M*elapsed], "|MiB/sec\n";
  };

randomreadwithmmap:{[blocksize]
  blockNr: totalreadInB div SIZEOFLONG * blocksize;
  .qlog.info "Indexing ", string[blockNr], " number of continuous blocks of length ", string blocksize;
  offsets: blockNr?neg[blocksize]+(-14+hcount fRandomRead)div SIZEOFLONG;  // 14 bytes overhead
  sT:.z.n;
  blocksize {[blocksize; offset] get[fRandomRead] offset+til blocksize;}/: offsets;
  elapsed:tsToSec .z.n-sT;
  resultH argv[`testtype], "|mmap,random read ",sizeM[blocksize],"|get,til,@|", fix[2;totalreadInB % M* elapsed], "|MiB/sec\n";
  };

fn: $[`withmmap in argvk; randomreadwithmmap; randomread]
fn "I"$argv `listsize;

if [not `debug in argvk; exit 0];
