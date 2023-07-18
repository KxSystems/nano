system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x
system "l src/util.q";

workerNr: system "s" // We assume that each worker has its own thread
iostatH: hopen ":", argv `iostatfile

`alltest set ();
`workers set ();
`disks set ();

getKBRead: {[disks]
  iostatcmd: "iostat -dk -o JSON ", " " sv disks;
  r: raze system iostatcmd;
  :exec `long$sum kB_read from @[; `disk] first @[; `statistics] first first first value flip value .j.k r
  }

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
      iostatH string[t], "|", fix[2; (eS-sS)%k*tsToSec eT-sT],"\n";
      } each first alltest;
    .qlog.info "All tests were executed. Sending exit message to workers.";
    if[not `debug in argvk;
      @[; "exit 0"; ::] each workers;
      exit 0];
  ];
  }

addWorker: {[addr; disk; tests]
  .qlog.info "adding tests from address ", addr;
  alltest,: enlist tests;
  workers,: hsym `$addr;
  disks,: enlist disk;
  }


.z.ts: executeTest;
system "t 200";

.qlog.info "controller started";