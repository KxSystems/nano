system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x
system "l src/util.q";

workerNr: system "s" // We assume that each worker has its own thread
iostatH: hopen ":", argv `iostatfile

`alltest set ();
`workers set ();
`disks set ();

iostatError: `kB_read`kB_wrtn!2#0Nj;

getKBReadMac: {[x] iostatError}
getKBReadLinux: {[disks]
  iostatcmd: "iostat -dk -o JSON ", (" " sv disks), " 2>&1";
  r: @[system; iostatcmd; .qlog.error];
  :$[10h ~ type r; [
  	iostats: @[; `disk] first @[; `statistics] first first first value flip value .j.k raze r;
  	$[count iostats; exec `long$sum kB_read, `long$sum kB_wrtn from iostats; iostatError]];
	iostatError]
  }

getKBRead: $["Darwin" ~ first system "uname -s"; getKBReadMac; getKBReadLinux]

executeTest: {[dontcare]
  if[workerNr = count workers;
    system "t 0";
    if[ any 1_differ alltest; .qlog.error "Not all tests are the same!"; exit 1];
    {[t]
      .qlog.info "Executing test ", string t;
      ddisks: distinct disks;
      sS: getKBRead[ddisks]; sT: .z.n;
      @[; (t; ::)] peach workers;
      eT: .z.n; eS: getKBRead[ddisks];
      iostatH string[t], SEP, (SEP sv value fix[2; (eS-sS)%1000*tsToSec eT-sT]),"\n";
      } each first[alltest] except exclusetests;
    .qlog.info "All tests were executed. Sending exit message to workers.";
    if[not `debug in argvk;
      @[; "exit 0"; ::] each workers;
      exit 0];
  ];
  }

addWorker: {[addr; disk; tests]
  .qlog.info "adding tests from address ", addr, " using disk ", disk;
  alltest,: enlist tests;
  workers,: hsym `$addr;
  disks,: enlist disk;
  }


.z.ts: executeTest;
system "t 200";

exclusetests: `$" " vs getenv `EXCLUDETESTS

.qlog.info "controller started";
