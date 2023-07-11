system "l src/common.q";

.test.read: {[]
  .qlog.info "Starting mmap read test";
  sT:.z.n;
  `mapped set get fRead;
  {-23!x;} mapped;
  eT: .z.n;
  writeRes["read disk";"sequential read";"get,-23!"; 1; count mapped; sT, eT; fix[2;SIZEOFLONG*count[mapped]%M*tsToSec eT-sT]; "MiB/sec\n"];
  }

.test.aggregate: {[]
  .qlog.info "Starting aggregate test";
  sT:.z.n;
  max mapped;
  eT: .z.n;
  writeRes["read mem";"aggregate";"max"; 1; count mapped; sT, eT; fix[2;SIZEOFLONG*count[mapped]%M*tsToSec eT-sT]; "MiB/sec\n"];
  }

.test.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  eT: .z.n;
  writeRes["read disk";"sequential read binary";"read1"; 1; hcount fReadBinary; sT, eT; fix[2;hcount[fReadBinary]%M*tsToSec eT-sT]; "MiB/sec\n"];  // TODO: avoid recalculating theoretical read binary file size
  }

controller (`addWorker; address[]; tests[]);