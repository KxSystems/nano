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


tinyVec: 2 3 5 7;
if[ not OBJSTORE;
  .prepare.tinyAppend: {[]
    .qlog.info "starting append tiny test";
    ftinyAppend: hsym `$DB, "/tinyAppend";
    sT: .z.n;
    do[N; .[ftinyAppend;();,; tinyVec]];
    system "sync ", DB, "/tinyAppend";
    eT: .z.n;
    writeRes["write disk"; ".prepare.tinyAppend|open append tiny, sync once"; ".[;();,;", (" " sv string tinyVec), "]"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };

  .prepare.tinyAppendToHandler: {[]
    .qlog.info "starting handler append tiny test";
    ftinyAppendFH: hsym `$DB, "/tinyAppendFH";
    ftinyAppendFH set 0#tinyVec;
    H: hopen ftinyAppendFH;
    sT: .z.n;
    do[N; H tinyVec];
    system "sync ", DB, "/tinyAppendFH";
    eT: .z.n;
    hclose H;
    writeRes["write disk"; ".prepare.tinyAppendToHandler|append tiny, sync once"; "H ", " " sv string tinyVec; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };

  .prepare.smallAppendToHandler: {[]
    .qlog.info "starting handler append small test";
    fsmallAppendFH: hsym `$DB, "/smallAppendFH";
    fsmallAppendFH set 0#smallVec;
    H: hopen fsmallAppendFH;
    M: N div 10;
    sT: .z.n;
    do[M; H smallVec];
    system "sync ", DB, "/smallAppendFH";
    eT: .z.n;
    hclose H;
    writeRes["write disk"; ".prepare.smallAppendToHandler|append small, sync once"; "H til 16*k"; M; count smallVec; sT, eT; fix[2; getMBPerSec[M * count smallVec; eT-sT]]; "MB/sec\n"];
  };

  .prepare.tinyReplace: {[]
    .qlog.info "starting replace tiny test";
    ftinyReplace: hsym `$DB, "/tinyReplace";
    ftinyReplace set smallVec;
    sT: .z.n;
    do[N; .[ftinyReplace;();:; tinyVec]];
    system "sync ", DB, "/tinyReplace";
    eT: .z.n;
    writeRes["write disk"; ".prepare.tinyReplace|open replace tiny, sync once"; ".[;();:;", (" " sv string tinyVec), "]"; N; count tinyVec; sT, eT; fix[3; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };
  ];


ssm: `long$MODIFIER * (0.3 * .Q.w[]`mphy) & "J"$getenv `SEQWRITETESTLIMIT;  // vectors can reserve memory twice the length of the vector
ssm: (ssm-(ssm mod 1024*1024)) div processcount;
SAMPLESIZE: ssm div SIZEOFLONG;

TBLSIZE: (`long$MODIFIER * "J"$getenv `SORTFILESIZE) div SIZEOFLONG

.prepare.createList: {[]
  .qlog.info "starting list creation test of length ", string[`int$SAMPLESIZE % 1000 * 1000], " M";
  sT:.z.n;
  `privmem set til SAMPLESIZE;
  eT: .z.n;
  writeRes["write mem"; ".prepare.createList|create list"; "til"; 1; SAMPLESIZE; sT, eT; fix[2; getMBPerSec[SAMPLESIZE; eT-sT]]; "MB/sec\n"];
  }



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
  .prepare.set: {[]
    sT:.z.n;
    lrfileTmpH set privmem;
    eT: .z.n;
    writeRes["write disk"; ".prepare.set|write rate"; "set"; 1; count privmem; sT, eT; fix[2; getMBPerSec[SAMPLESIZE; eT-sT]]; "MB/sec\n"];
  };
  .prepare.cloudcmd: {[]
    sT:.z.n;
    system cloudcmd[lrfileTmp; fReadFileName];
    eT: .z.n;
    .qlog.info "Write test finished";
    hdel lrfileTmpH;
    writeRes["write objstore";".prepare.cloudcmd|cli cp rate";"vendor obj store cli cp"; 1; count lrfileTmp; sT, eT; fix[2; getMBPerSec[SAMPLESIZE; eT-sT]]; "MB/sec\n"];
  };
  .prepare.prepare: {[]
    .qlog.info "creating files for read tests";
    (hsym `$ffileoTmp: tmpdir, fOpenCloseFileName) set smallVec;
    system cloudcmd[ffileoTmp; fOpenCloseFileName];
    system cloudcmd[ffileoTmp; fHReadBinaryFileName];
    system cloudcmd[ffileoTmp; fHmmapFileName];
    hdel hsym `$ffileoTmp;

    / more generous for hcount
    (hsym `$ffile4Tmp: tmpdir, fHCountFileName) set midVec;
    system cloudcmd[ffile4Tmp; fHCountFileName];
    hdel hsym `$ffile4Tmp
  }
  ];[
  .prepare.set: {[]
    .qlog.info "starting set test";
    sT:.z.n;
    fRead set privmem;
    eT: .z.n;
    writeRes["write disk";".prepare.set|write rate";"set";1; count privmem; sT, eT; fix[2; getMBPerSec[SAMPLESIZE; eT-sT]]; "MB/sec\n"];
  };
  .prepare.sync: {[]
    .qlog.info "starting sync test";
    sT: .z.n;
    system "sync ", DB, fReadFileName;
    eT: .z.n;
    writeRes["write disk";".prepare.sync|sync rate";"system sync"; 1; count privmem; sT, eT; fix[2; getMBPerSec[SAMPLESIZE; eT-sT]]; "MB/sec\n"];
  };

  disksize: MODIFIER * SIZEOFLONG * "J"$getenv `RANDREADFILESIZE;

  .prepare.appendSmall: {[]
    .qlog.info "creating files for random read test";
    .qlog.info "starting append small test";
    chunkSize: count smallVec;
    chunkNr: `long$disksize % SIZEOFLONG * chunkSize * 1+2 xlog processcount;
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fRandomRead;();,;smallVec]];
    system "sync ", 1_string fRandomRead;
    eT: .z.n;
    writeRes["write disk";".prepare.appendSmall|open append small, sync once";".[;();,;til 16*k]"; chunkNr; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize; eT-sT]]; "MB/sec\n"];
  };
  .prepare.appendMidSym: {[]
    .qlog.info "creating files for xasc tests";
    .qlog.info "starting append mid sym vector test";
    chunkSize: count midSymVec;
    chunkNr: `long$TBLSIZE % SIZEOFLONG * chunkSize * 1+2 xlog processcount; // enumerated symbols are stored as longs
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fSymCol;();,;`sym$midSymVec]];
    system "sync ", 1_string fSymCol;
    eT: .z.n;
    writeRes["write disk";".prepare.appendMidSym|open append mid sym, sync once";".[;();,;`sym$]"; chunkNr; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize; eT-sT]]; "MB/sec\n"];
  };
  .prepare.appendMidFloat: {[]
    .qlog.info "creating files for xasc tests";
    .qlog.info "starting append mid sym vector test";
    chunkSize: count midSymVec;
    chunkNr: `long$TBLSIZE % SIZEOFLONG * chunkSize * 1+2 xlog processcount; // enumerated symbols are stored as longs
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fFloatCol;();,;midFloatVec]];
    system "sync ", 1_string fSymCol;
    eT: .z.n;
    writeRes["write disk";".prepare.appendMidFloat|open append mid float, sync once";".[;();,;]"; chunkNr; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize; eT-sT]]; "MB/sec\n"];
  };
  .prepare.makeTable: {[]
    .qlog.info "make ", (1_string KDBDB), " a normal kdb+ database (for e.g. xasc test)";
    .Q.dd[KDBDB; `sym] set sym;
    .Q.dd[KDBTBL; `.d] set `sym`floatcol;
    system "sync ", 1_string KDBTBL;
  };
  .prepare.prepare: {[]
    / more generous for hcount
    fhcount set midVec;
    fReadBinary set raze 64#enlist smallVec;
    fmmap set smallVec;
    fOpenClose set smallVec;
    .qlog.info "files created";
  };
  ]
  ];

//////////////////////////////////////////
/  this is deprecated and currently unused...
WSAMPLESIZE:`long$ssm%16
write:{[file]
    / this is to allow any 3rd party performance monotoring tools to see a time gap
  system"sleep 5";
  STDOUT(string .z.p);
  STDOUT"write `",(string file)," - ",(string floor 0.5+(ssm%(2 xexp 20))%value "\\t `",(string file)," 1:WSAMPLESIZE#key 11+rand 111")," MB/sec";hdel file;
  STDOUT(string .z.p);
  }
//////////////////////////////////////////

exitcustom: {[]
  if[OBJSTORE; hdel tmpdirH]};

sendTests[controller;DB;`.prepare]

.qlog.info "Ready for test execution";