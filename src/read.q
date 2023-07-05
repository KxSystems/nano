system "l src/common.q";

.test.read: {[]
  .qlog.info "Starting mmap read test";
  sT:.z.n;
  `mapped set get fRead;
  {-23!x;} mapped;
  eT: .z.n;
  writeRes["read disk";"read";"get,-23!"; sT; eT; fix[2;ssm%M*tsToSec eT-sT]; "MiB/sec\n"];
  }

.test.aggregate: {[]
  .qlog.info "Starting aggregate test";
  sT:.z.n;
  max mapped;
  eT: .z.n;
  writeRes["read mem";"aggregate";"max"; sT; eT; fix[2;ssm%M*tsToSec eT-sT]; "MiB/sec\n"];
  }

.test.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  eT: .z.n;
  // k%M is shortened to %k
  writeRes["read disk";"read binary";"read1"; sT; eT; fix[2;SIZEOFLONG*16%k*tsToSec eT-sT]; "MiB/sec\n"];  // TODO: avoid recalculating theoretical read binary file size
  }

controller (`addWorker; ) .Q.dd[`.test;] each except[; `] key .test;