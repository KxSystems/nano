system "l src/common.q";

// processes are executed by multiple independent executions of the kdb+ script, via calling
// script. processcount is used to figure out how big to make each file
// depending on the available memory
// we go high with most memory settings in cloud as this mimics customer systems
// and side-benefits by gaining more instance capability. So this is a lazy calc
//

if[not "full" ~ getenv `DBSIZE;
  .qlog.warn "Test runs with ", getenv[`DBSIZE], " data. Reduce ratio is ", string MODIFIER];

smallVec:`long$til 16*k;
midVec: `long$til `long$MODIFIER*4*M;

.prepare.smallPermute: {[]
  .qlog.info "starting permute small test";
  sT: .z.n;
  `smallVec set 0N?smallVec;
  eT: .z.n;
  writeRes["read mem"; ".prepare.smallPermute|permute"; "0N?"; 1; count smallVec; sT, eT; fix[2; getMBPerSec[count smallVec; eT-sT]]; "MB/sec\n"];
  }

.prepare.smallSort: {[]
  .qlog.info "starting sort small test";
  sT: .z.n;
  asc smallVec;
  eT: .z.n;
  writeRes["read mem"; ".prepare.smallSort|sort"; "asc"; 1; count smallVec; sT, eT; fix[2; getMBPerSec[count smallVec; eT-sT]]; "MB/sec\n"];
  }

.prepare.midPermute: {[]
  .qlog.info "starting permute mid test";
  sT: .z.n;
  `midVec set 0N?midVec;
  eT: .z.n;
  writeRes["read mem"; ".prepare.midPermute|permute"; "0N?"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.prepare.midDeltas: {[]
  .qlog.info "starting deltas mid test";
  sT: .z.n;
  deltas midVec;
  eT: .z.n;
  writeRes["read mem"; ".prepare.midDeltas|deltas"; "deltas"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.prepare.midModWhere: {[]
  .qlog.info "starting modulo-eq-where mid test";
  sT: .z.n;
  where 0=midVec mod 7;
  eT: .z.n;
  writeRes["read mem"; ".prepare.midModWhere|where mod ="; "where 0=mod[;7]"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.prepare.midSort: {[]
  .qlog.info "starting sort mid test";
  sT: .z.n;
  asc midVec;
  eT: .z.n;
  writeRes["read mem"; ".prepare.midSort|sort"; "asc"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

tinyVec: 2 3 5 7;
if[ not OBJSTORE;
  .prepare.tinyAppend: {[]
    .qlog.info "starting append tiny test";
    ftinyAppend: hsym `$DB, "/tinyAppend";
    sT: .z.n;
    do[N; .[ftinyAppend;();,; tinyVec]];
    eT: .z.n;
    fsize: SIZEOFLONG * N * count tinyVec;
    writeRes["write disk"; ".prepare.tinyAppend|open append tiny"; ".[;();,;", (" " sv string tinyVec), "]"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };

  .prepare.tinyAppendToHandler: {[]
    .qlog.info "starting handler append tiny test";
    ftinyAppendFH: hsym `$DB, "/tinyAppendFH";
    H: hopen ftinyAppendFH;
    sT: .z.n;
    do[N; H tinyVec];
    eT: .z.n;
    hclose H;
    fsize: SIZEOFLONG * N * count tinyVec;
    writeRes["write disk"; ".prepare.tinyAppendToHandler|append tiny"; "H ", " " sv string tinyVec; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };

  .prepare.tinyReplace: {[]
    .qlog.info "starting replace tiny test";
    ftinyReplace: hsym `$DB, "/tinyReplace";
    ftinyReplace set smallVec;
    sT: .z.n;
    do[N; .[ftinyReplace;();:; tinyVec]];
    eT: .z.n;
    writeRes["write disk"; ".prepare.tinyReplace|open replace tiny"; ".[;();:;", (" " sv string tinyVec), "]"; N; count tinyVec; sT, eT; fix[3; getMBPerSec[N * count tinyVec; eT-sT]]; "MB/sec\n"];
  };
  ];


MEMUSAGERATEDEFAULT: 0.6;
ssm: `long$MODIFIER * $["abs" ~ getenv `MEMUSAGETYPE;
   1024*1024*"J"$getenv `MEMUSAGEVALUE;
   0.5 * (MEMUSAGERATEDEFAULT^"F"$getenv `MEMUSAGEVALUE) * .Q.w[]`mphy];  // vectors can reserve memory twice the length of the vector

ssm:`long$(ssm-(ssm mod 1024*1024))%processcount;
SAMPLESIZE:`long$ssm%SIZEOFLONG;

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
  .prepare.appendSmall: {[]
    .qlog.info "creating files for read tests";
    .qlog.info "starting append small test";
    chunkSize: count smallVec;
    DISKRATEDEFAULT: 3;
    disksize: $["abs" ~ getenv `RANDOMREADFILESIZETYPE;
      1024*1024*"J"$getenv `RANDOMREADFILESIZEVALUE;
      (DISKRATEDEFAULT^"F"$getenv `RANDOMREADFILESIZEVALUE) * MODIFIER * .Q.w[]`mphy];
    chunkNr: `long$disksize % SIZEOFLONG * chunkSize * processcount;
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fRandomRead;();,;smallVec]];
    eT: .z.n;
    fsize: SIZEOFLONG * chunkNr * chunkSize;
    writeRes["write disk";".prepare.appendSmall|open append mid";".[;();,;til 16*k]"; chunkNr; chunkSize; sT, eT; fix[2; getMBPerSec[chunkNr*chunkSize; eT-sT]]; "MB/sec\n"];

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

.z.exit: {
  .qlog.info "exiting prepare";
  if[OBJSTORE; hdel tmpdirH]};

controller (`addWorker; address[]; getDisk[]; getTests[`.prepare]);

.qlog.info "Ready for test execution";