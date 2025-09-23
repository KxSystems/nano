system "l src/common.q";
system "l src/samplearrays.q";

// processes are executed by multiple independent executions of the kdb+ script, via calling
// script. processcount is used to figure out how big to make each file
// depending on the available memory
// we go high with most memory settings in cloud as this mimics customer systems
// and side-benefits by gaining more instance capability. So this is a lazy calc
//

if[not "full" ~ lower getenv `DBSIZE;
  .qlog.warn "Test runs with ", getenv[`DBSIZE], " data. Reduce ratio is ", string MODIFIER];


if[ not OBJSTORE;
  tinyRepr: (" " sv string 3#tinyVec), "...";
  .write.tinyAppend: {[]
    .qlog.info "starting append tiny test";
    ftinyAppend: hsym `$DB, "/tinyAppend";
    N:200;
    sT: .z.n;
    do[N; .[ftinyAppend;();,; tinyVec]];
    system "sync ", DB, "/tinyAppend";
    eT: .z.n;
    writeRes["write disk"; ".write.tinyAppend|open append tiny, sync once"; ".[;();,;", tinyRepr, "]"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };

  .write.tinyAppendToHandler: {[]
    .qlog.info "starting handler append tiny test";
    ftinyAppendFH: hsym `$DB, "/tinyAppendFH";
    ftinyAppendFH set 0#tinyVec;
    H: hopen ftinyAppendFH;
    N:500;
    sT: .z.n;
    do[N; H tinyVec];
    system "sync ", DB, "/tinyAppendFH";
    eT: .z.n;
    hclose H;
    writeRes["write disk"; ".write.tinyAppendToHandler|append tiny, sync once"; "H ", tinyRepr; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };

  .write.smallAppendToHandler: {[]
    .qlog.info "starting handler append small test";
    fsmallAppendFH: hsym `$DB, "/smallAppendFH";
    fsmallAppendFH set 0#smallVec;
    H: hopen fsmallAppendFH;
    N:50;
    sT: .z.n;
    do[N; H smallVec];
    system "sync ", DB, "/smallAppendFH";
    eT: .z.n;
    hclose H;
    writeRes["write disk"; ".write.smallAppendToHandler|append small, sync once"; "H til 16*k"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N * count smallVec; eT-sT]]; "MB/sec\n"];
  };

  .write.tinyReplace: {[]
    .qlog.info "starting replace tiny test";
    ftinyReplace: hsym `$DB, "/tinyReplace";
    ftinyReplace set smallVec;
    N:100;
    sT: .z.n;
    do[N; .[ftinyReplace;();:; tinyVec]];
    system "sync ", DB, "/tinyReplace";
    eT: .z.n;
    writeRes["write disk"; ".write.tinyReplace|open replace tiny, sync once"; ".[;();:;", tinyRepr, "]"; N; count tinyVec; sT, eT; fix[3; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };
  ];


HUGELENGTH: `long$MODIFIER * "J"$getenv `HUGELENGTH;
if[ .Q.w[][`mphy] < processcount*16*HUGELENGTH;
  HUGELENGTH: .Q.w[][`mphy] div 2 * 16 * processcount; / use half of the physical memory
  .qlog.info "Reducing HUGELENGTH to ", string[HUGELENGTH], " due to memory limit"];
hugeVec: til HUGELENGTH;
largeSymVec: LARGELENGTH?sym;

if[count getenv `COMPRESS;
  .qlog.info "setting compression parameters to ", getenv `COMPRESS;
  .z.zd: "J"$" " vs getenv `COMPRESS];

getAWSCPCmd: {[db]
  if[ not count getenv `AWS_REGION;
    STDOUT "Environment variable AWS_REGION is not set! Exiting";
    exit 4];
  :{[db; f; fn] "aws s3 cp ", f, " ", db, fn} db
  };

getGCPCPCmd: {[db]
  :{[db; f; fn] "gsutil cp ", f, " ", db, fn} db
  };

getAzureCPCmd: {[db]
  noprefix: 5 _ db;
  storageaccount: (noprefix?".") # noprefix;
  loc: (1+noprefix?"/") _ noprefix;
  container: (loc?"/")#loc;
  dir: (1+loc?"/")_loc;

  :{[storageaccount; container; dir; f; fn] "az storage blob upload --account-name ", storageaccount, " -c ", container, " -f ", f,
    " -n ", dir, fn}[storageaccount; container;dir];
  };

vendorCPCmd: ("s3"; "gs"; "ms")!(getAWSCPCmd; getGCPCPCmd; getAzureCPCmd);


$[OBJSTORE; [
  tmpdirH: hsym `$tmpdir: $[count getenv `OBJSTORELOCTMPDIRBASE;
   getenv[`OBJSTORELOCTMPDIRBASE], "/", string .z.i;
   first system "mktemp -d"];
  cloudcmd: vendorCPCmd[2 sublist DB] DB;
  .qlog.info "using temporal dir ", tmpdir;

  lrfileTmpH:hsym `$lrfileTmp: tmpdir, fReadFileName;
  testFactory["write disk"; `.write.setHuge;1;set[lrfileTmpH];"set";hugeVec;"write huge";1];

  .write.cloudcmd: {[]
    sT:.z.n;
    system cloudcmd[lrfileTmp; fReadFileName];
    eT: .z.n;
    .qlog.info "Write test finished";
    hdel lrfileTmpH;
    writeRes["write objstore";".write.cloudcmd|cli cp rate";"vendor obj store cli cp"; 1; count lrfileTmp; sT, eT; fix[2; getMBPerSec[HUGELENGTH; eT-sT]]; "MB/sec\n"];
  };
  .write.prepare: {[]
    .qlog.info "creating files for read tests";
    (hsym `$ffileoTmp: tmpdir, fOpenCloseFileName) set smallVec;
    system cloudcmd[ffileoTmp; fOpenCloseFileName];
    system cloudcmd[ffileoTmp; fHReadBinaryFileName];
    system cloudcmd[ffileoTmp; fHmmapFileName];
    hdel hsym `$ffileoTmp;

    / more generous for hcount
    (hsym `$ffile4Tmp: tmpdir, fHCountFileName) set largeVec;
    system cloudcmd[ffile4Tmp; fHCountFileName];
    hdel hsym `$ffile4Tmp
  }
  ];[


  testFactory["write disk"; `.write.setIntSmall;1;set[fReadSmall];"set";smallVec;"write int small";1];
  testFactory["write disk"; `.write.syncIntSmall;1;system;"system sync";"sync ",1_string fReadSmall;"sync int small";SMALLLENGTH];


  testFactory["write disk"; `.write.setIntMedium;1;set[fReadMedium];"set";mediumVec;"write int medium";1];
  testFactory["write disk"; `.write.syncIntMedium;1;system;"system sync";"sync ",1_string fReadMedium;"sync int medium";MEDIUMLENGTH];

  testFactory["write disk"; `.write.setLargeSym;1;set[fSymCol];"set";largeSymVec;"write sym large";1];
  testFactory["write disk"; `.write.syncLargeSym;1;system;"system sync";"sync ",1_string fSymCol;"sync sym large";LARGELENGTH];

  testFactory["write disk"; `.write.setLargeFloat;1;set[fFloatCol];"set";largeFloatVec;"write float large";1];
  testFactory["write disk"; `.write.syncLargeFloat;1;system;"system sync";"sync ",1_string fFloatCol;"sync float large";LARGELENGTH];

  testFactory["write disk"; `.write.setIntHuge;1;set[fReadHuge];"set";hugeVec;"write int huge";1];
  testFactory["write disk"; `.write.syncIntHuge;1;system;"system sync";"sync ",DB,fReadFileName;"sync int huge";HUGELENGTH];

  disksize: MODIFIER * SIZEOFLONG * "J"$getenv `RANDREADFILESIZE;

  .write.appendSmall: {[]
    .qlog.info "creating files for random read test";
    .qlog.info "starting append small test";
    chunkSize: count smallVec;
    chunkNr: `long$disksize % SIZEOFLONG * chunkSize * FILENRPERWORKER * 1+2 xlog processcount;
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    chunkNr {[chunkNr;f] do[chunkNr; .[f;();,;smallVec]]}' fsRandomRead;
    system "sync ", " " sv 1_/:string fsRandomRead;
    eT: .z.n;
    writeRes["write disk";".write.appendSmall|open append small, sync once";".[;();,;til 16*k]"; chunkNr*FILENRPERWORKER; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize*FILENRPERWORKER; eT-sT]]; "MB/sec\n"];
  };

  TBLLENGTH: `long$MODIFIER * "J"$getenv `SORTFILESIZE;

  .write.appendLargeSym: {[]
    .qlog.info "creating files for xasc tests";
    .qlog.info "starting append large sym vector test";
    chunkSize: count largeSymVec;
    chunkNr: `long$TBLLENGTH % chunkSize * 1+2 xlog processcount; // enumerated symbols are stored as longs
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fSymCol;();,;largeSymVec]];
    system "sync ", 1_string fSymCol;
    eT: .z.n;
    writeRes["write disk";".write.appendLargeSym|open append mid sym, sync once";".[;();,;`sym$]"; chunkNr; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize; eT-sT]]; "MB/sec\n"];
  };
  .write.appendLargeFloat: {[]
    .qlog.info "creating files for xasc tests";
    .qlog.info "starting append large float vector test";
    chunkSize: count largeFloatVec;
    chunkNr: `long$TBLLENGTH % chunkSize * 1+2 xlog processcount; // enumerated symbols are stored as longs
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fFloatCol;();,;largeFloatVec]];
    system "sync ", 1_string fFloatCol;
    eT: .z.n;
    writeRes["write disk";".write.appendLargeFloat|open append mid float, sync once";".[;();,;]"; chunkNr; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize; eT-sT]]; "MB/sec\n"];
  };
  .write.makeTable: {[]
    .qlog.info "make ", (1_string KDBDB), " a normal kdb+ database (for e.g. xasc test)";
    .Q.dd[KDBDB; `sym] set sym;
    .Q.dd[KDBTBL; `.d] set `sym`floatcol;
    system "sync ", 1_string KDBTBL;
  };
  .write.prepare: {[]
    / more generous for hcount
    fhcount set largeVec;
    fReadBinary set raze 64#enlist smallVec;
    fmmap set smallVec;
    fOpenClose set smallVec;
    .qlog.info "files created";
  };
  ]
  ];

exitcustom: {[]
  if[OBJSTORE; hdel tmpdirH]
  };

sendTests[controller;DB;`.write]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i