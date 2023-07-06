system "l src/common.q";

.test.read: {[]
  .qlog.info "Starting mmap read test";
  sT:.z.n;
  `mapped set get fRead;
  {-23!x;} mapped;
  eT: .z.n;
  fsize:hcount fRead;
  writeRes["read mem";"sequential reread";"get,-23!"; 1; count mapped; sT, eT; fix[2;SIZEOFLONG*count[mapped]%M*tsToSec eT-sT]; "MiB/sec\n"];
  }

.test.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  eT: .z.n;
  writeRes["read mem";"sequential read binary";"read1"; 1; hcount fReadBinary; sT, eT; fix[2;hcount[fReadBinary]*tsToSec eT-sT]; "MiB/sec\n"];
  }

controller (`addWorker; ) .Q.dd[`.test;] each except[; `] key .test;