system "l src/common.q";

// processes are executed by multiple independent executions of the kdb+ script, via calling
// script. processcount is used to figure out how big to make each file
// depending on the available memory
// we go high with most memory settings in cloud as this mimics customer systems
// and side-benefits by gaining more instance capability. So this is a lazy calc
//

if[not "full" ~ getenv `DBSIZE;
  .qlog.warn "Test runs with ", getenv[`DBSIZE], " data. Reduce ratio is ", string MODIFIER];

fileopsmem:`long$til 16*k;
smallVec: 2 3 5 7;
if[ not OBJSTORE;
  .test.smallAppend: {[]
    .qlog.info "starting append small test";
    fSmallAppend: hsym `$DB, "/smallAppend";
    sT: .z.n;
    do[N; .[fSmallAppend;();,; smallVec]];
    eT: .z.n;
    fsize: SIZEOFLONG * N * count smallVec;
    writeRes["write disk"; "open append small"; ".[;();,;", (" " sv string smallVec), "]"; sT; eT; fix[2; fsize%M*tsToSec eT - sT]; "MiB/sec\n"];
  };

  .test.smallAppendToHandler: {[]
    .qlog.info "starting handler append small test";
    fSmallAppendFH: hsym `$DB, "/SmallAppendFH";
    H: hopen fSmallAppendFH;
    sT: .z.n;
    do[N; H smallVec];
    eT: .z.n;
    hclose H;
    fsize: SIZEOFLONG * N * count smallVec;
    writeRes["write disk"; "append small"; "H ", " " sv string smallVec; sT; eT; fix[2; fsize%M*tsToSec eT - sT]; "MiB/sec\n"];
  };

  .test.smallReplace: {[]
    .qlog.info "starting replace small test";
    fSmallReplace: hsym `$DB, "/smallReplace";
    fSmallReplace set fileopsmem;
    sT: .z.n;
    do[N; .[fSmallReplace;();:; smallVec]];
    eT: .z.n;
    writeRes["write disk"; "open replace small"; ".[;();:;", (" " sv string smallVec), "]"; sT; eT; fix[3; (SIZEOFLONG * N* count smallVec)%M*tsToSec eT - sT]; "MiB/sec\n"];
  };
  ];


.test.createList: {[]
  / 8 bytes in a word (64bit version of kdb+ only)
  SAMPLESIZE:`long$ssm%SIZEOFLONG;
  .qlog.info "starting list creation test of length ", string[`int$SAMPLESIZE % 1000 * 1000], " M";
  sT:.z.n;
  `privmem set til SAMPLESIZE;
  eT: .z.n;
  writeRes["write mem"; "create list"; "til"; sT; eT; string[floor 0.5+ssm%M*tsToSec eT-sT]; "MiB/sec\n"];
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
  .test.set: {[]
    sT:.z.n;
    lrfileTmpH set privmem;
    eT: .z.n;
    writeRes["write disk"; "write rate"; "set"; sT; eT; fix[2; ssm%M*tsToSec eT - sT]; "MiB/sec\n"];
  };
  .test.cloudcmd: {[]
    sT:.z.n;
    system cloudcmd[lrfileTmp; fReadFileName];
    eT: .z.n;
    .qlog.info "Write test finished";
    hdel lrfileTmpH;
    writeRes["write objstore";"cli cp rate";"vendor obj store cli cp"; sT; eT; fix[2; ssm%M*tsToSec eT - sT]; "MiB/sec\n"];
  };
  .test.prepare: {[]
    .qlog.info "creating files for read tests";
    (hsym `$ffileoTmp: tmpdir, fOpenCloseFileName) set fileopsmem;
    system cloudcmd[ffileoTmp; fOpenCloseFileName];
    system cloudcmd[ffileoTmp; fHReadBinaryFileName];
    system cloudcmd[ffileoTmp; fHmmapFileName];
    hdel hsym `$ffileoTmp;

    / more generous for hcount
    hcn:`long$til `long$MODIFIER*4*M;
    (hsym `$ffile4Tmp: tmpdir, fHCountFileName) set hcn;
    system cloudcmd[ffile4Tmp; fHCountFileName];
    hdel hsym `$ffile4Tmp
  }
  ];[
  .test.set: {[]
    .qlog.info "starting set test";
    sT:.z.n;
    fRead set privmem;
    eT: .z.n;
    writeRes["write disk";"write rate";"set";sT; eT; fix[2; ssm%M*tsToSec eT - sT]; "MiB/sec\n"];
  };
  .test.sync: {[]
    .qlog.info "starting sync test";
    sT: .z.n;
    system "sync ", DB, fReadFileName;
    eT: .z.n;
    writeRes["write disk";"sync rate";"system sync"; sT; eT; fix[2; ssm%M*tsToSec eT - sT]; "MiB/sec\n"];
  };
  .test.appendMid: {[]
    .qlog.info "creating files for read tests";
    fOpenClose set fileopsmem;
    .qlog.info "starting append mid test";
    chunkSize: count fileopsmem;
    DISKRATEDEFAULT: 3;
    disksize: $["abs" ~ getenv `RANDOMREADFILESIZETYPE;
      1024*1024*"J"$getenv `RANDOMREADFILESIZEVALUE;
      (DISKRATEDEFAULT^"F"$getenv `RANDOMREADFILESIZEVALUE) * MODIFIER * .Q.w[]`mphy];
    chunkNr: `long$disksize % SIZEOFLONG * chunkSize * processcount;
    .qlog.info "Appending ", string[chunkNr], " times long block of length ", string chunkSize;
    sT: .z.n;
    do[chunkNr; .[fRandomRead;();,;fileopsmem]];
    eT: .z.n;
    fsize: SIZEOFLONG * chunkNr * chunkSize;
    writeRes["write disk";"open append mid";".[;();,;til 16*k]";sT; eT; fix[2; fsize%M*tsToSec eT - sT]; "MiB/sec\n"];

  };
  .test.prepare: {[]
    / more generous for hcount
    hcn:`long$til `long$MODIFIER*4*M;
    fhcount set hcn;
    fReadBinary set fileopsmem;
    fmmap set fileopsmem;
    .qlog.info "files created";
  };
  ]
  ];

controller (`addWorker; ) .Q.dd[`.test;] each except[; `] key .test;

//////////////////////////////////////////
/  this is deprecated and currently unused...
WSAMPLESIZE:`long$ssm%16
write:{[file]
    / this is to allow any 3rd party performance monotoring tools to see a time gap
  system"sleep 5";
  STDOUT(string .z.p);
  STDOUT"write `",(string file)," - ",(string floor 0.5+(ssm%(2 xexp 20))%value "\\t `",(string file)," 1:WSAMPLESIZE#key 11+rand 111")," MiB/sec";hdel file;
  STDOUT(string .z.p);
  }
//////////////////////////////////////////

.z.exit: {
  .qlog.info "exiting prepare";
  if[OBJSTORE; hdel tmpdirH]};

.qlog.info "Ready for test execution";