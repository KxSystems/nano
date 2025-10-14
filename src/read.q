system "l src/common.q";


.read.readTiny: {[]
  .qlog.info "Starting mmap read int tiny test";
  sT:.z.n;
  `mappedTiny set get fReadTiny;
  {-23!x;} mappedTiny;
  eT: .z.n;
  writeRes["read disk write mem"; ".read.readTiny|sequential read int tiny";"get,-23!"; 1; count mappedTiny; sT, eT; fix[2;getMBPerSec[count mappedTiny; eT-sT]]; "MB/sec\n"];
  }

.read.readSmall: {[]
  .qlog.info "Starting mmap read int small test";
  sT:.z.n;
  `mappedSmall set get fReadSmall;
  {-23!x;} mappedSmall;
  eT: .z.n;
  writeRes["read disk write mem"; ".read.readSmall|sequential read int small";"get,-23!"; 1; count mappedSmall; sT, eT; fix[2;getMBPerSec[count mappedSmall; eT-sT]]; "MB/sec\n"];
  }

.read.readMedium: {[]
  .qlog.info "Starting mmap read int medium test";
  sT:.z.n;
  `mappedMedium set get fReadMedium;
  {-23!x;} mappedMedium;
  eT: .z.n;
  writeRes["read disk write mem"; ".read.readMedium|sequential read int medium";"get,-23!"; 1; count mappedMedium; sT, eT; fix[2;getMBPerSec[count mappedMedium; eT-sT]]; "MB/sec\n"];
  }

.read.readLarge: {[]
  .qlog.info "Starting mmap read float large test";
  sT:.z.n;
  `mappedLarge set get fFloatCol;
  {-23!x;} mappedLarge;
  eT: .z.n;
  writeRes["read disk write mem"; ".read.readLarge|sequential read float large";"get,-23!"; 1; count mappedLarge; sT, eT; fix[2;getMBPerSec[count mappedLarge; eT-sT]]; "MB/sec\n"];
  }

.read.readHuge: {[]
  .qlog.info "Starting mmap read int huge test";
  sT:.z.n;
  `mappedHuge set get fReadHuge;
  {-23!x;} mappedHuge;
  eT: .z.n;
  writeRes["read disk write mem"; ".read.readHuge|sequential read int huge";"get,-23!"; 1; count mappedHuge; sT, eT; fix[2;getMBPerSec[count mappedHuge; eT-sT]]; "MB/sec\n"];
  }

.read.aggregate: {[]
  .qlog.info "Starting aggregate test";
  sT:.z.n;
  max mappedHuge;
  eT: .z.n;
  writeRes["cpu read mem"; ".read.aggregate|aggregate int huge";"max"; 1; count mappedHuge; sT, eT; fix[2;getMBPerSec[count mappedHuge; eT-sT]]; "MB/sec\n"];
  }

.read.readbinary: {[]
  .qlog.info "starting read binary test";
  sT:.z.n;
  read1 fReadBinary;
  eT: .z.n;
  writeRes["read disk"; ".read.readbinary|sequential read binary";"read1"; 1; hcount fReadBinary; sT, eT; fix[2;getMBPerSec[div[; 8] -16+hcount fReadBinary; eT-sT]]; "MB/sec\n"];  // TODO: avoid recalculating theoretical read binary file size
  }

sendTests[controller;DB;`.read]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i