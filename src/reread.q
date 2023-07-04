system "l src/common.q";

.test.read: {[]
  .qlog.info "Starting mmap read test";
  sT:.z.n;
  `mapped set get fRead;
  {-23!x;} mapped;
  elapsed:tsToSec .z.n-sT;
  fsize:hcount fRead;
  resultH "read mem|reread|get,-23!|", fix[2;fsize%M*elapsed], "|MiB/sec\n";
  }

.test.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  elapsed:tsToSec .z.n-sT;
  resultH "read mem|read binary|read1|", fix[2;hcount[fReadBinary]%M*elapsed], "|MiB/sec\n";
  }

controller (`addWorker; ) .Q.dd[`.test;] each except[; `] key .test;