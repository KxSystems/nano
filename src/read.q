system "l src/common.q";

.read.read: {[]
  .qlog.info "Starting mmap read test";
  sT:.z.n;
  `mapped set get fRead;
  {-23!x;} mapped;
  eT: .z.n;
  writeRes["read disk";".read.read|sequential read";"get,-23!"; 1; count mapped; sT, eT; fix[2;getMBPerSec[count mapped; eT-sT]]; "MB/sec\n"];
  }

.read.aggregate: {[]
  .qlog.info "Starting aggregate test";
  sT:.z.n;
  max mapped;
  eT: .z.n;
  writeRes["read mem";".read.aggregate|aggregate";"max"; 1; count mapped; sT, eT; fix[2;getMBPerSec[count mapped; eT-sT]]; "MB/sec\n"];
  }

.read.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  eT: .z.n;
  writeRes["read disk";".read.readbinary|sequential read binary";"read1"; 1; hcount fReadBinary; sT, eT; fix[2;getMBPerSec[div[; 8] -16+hcount fReadBinary; eT-sT]]; "MB/sec\n"];  // TODO: avoid recalculating theoretical read binary file size
  }

controller (`addWorker; system "p"; getDisk[]; getTests[`.read]);
