system "l src/common.q";

.reread.readSmall: {[]
  .qlog.info "Starting mmap read int small test";
  sT:.z.n;
  `mappedSmall set get fReadSmall;
  {-23!x;} mappedSmall;
  eT: .z.n;
  writeRes["read mem write mem"; ".reread.readSmall|sequential reread int small";"get,-23!"; 1; count mappedSmall; sT, eT; fix[2;getMBPerSec[count mappedSmall; eT-sT]]; "MB/sec\n"];
  }

.reread.readMedium: {[]
  .qlog.info "Starting mmap read int medium test";
  sT:.z.n;
  `mappedMedium set get fReadMedium;
  {-23!x;} mappedMedium;
  eT: .z.n;
  writeRes["read mem write mem"; ".reread.readMedium|sequential reread int medium";"get,-23!"; 1; count mappedMedium; sT, eT; fix[2;getMBPerSec[count mappedMedium; eT-sT]]; "MB/sec\n"];
  }

.reread.readLarge: {[]
  .qlog.info "Starting mmap read float large test";
  sT:.z.n;
  `mappedLarge set get fFloatCol;
  {-23!x;} mappedLarge;
  eT: .z.n;
  writeRes["read mem write mem"; ".reread.readLarge|sequential reread float large";"get,-23!"; 1; count mappedLarge; sT, eT; fix[2;getMBPerSec[count mappedLarge; eT-sT]]; "MB/sec\n"];
  }

.reread.readHuge: {[]
  .qlog.info "Starting mmap read int huge test";
  sT:.z.n;
  `mappedHuge set get fReadHuge;
  {-23!x;} mappedHuge;
  eT: .z.n;
  writeRes["read mem write mem";".reread.readHuge|sequential reread int huge";"get,-23!"; 1; count mappedHuge; sT, eT; fix[2;getMBPerSec[count mappedHuge; eT-sT]]; "MB/sec\n"];
  }

.reread.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  eT: .z.n;
  writeRes["read mem write mem";".reread.readbinary|sequential read binary";"read1"; 1; hcount fReadBinary; sT, eT; fix[2;getMBPerSec[div[; 8] -16+hcount fReadBinary; eT-sT]]; "MB/sec\n"];
  }

sendTests[controller;DB;`.reread]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i