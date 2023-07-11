system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x

workerNr: system "s" // We assume that each worker has its own thread

`alltest set ();
`workers set ();

executeTest: {[dontcare]
  if[workerNr = count workers;
    system "t 0";
    if[ any 1_differ alltest; .qlog.error "Not all tests are the same!"; exit 1];
    {[t]
      .qlog.info "Executing test ", string t;
      @[; (t; ::)] peach workers} each first alltest;
    .qlog.info "All tests were executed. Sending exit message to workers.";
    if[not `debug in argvk;
      @[; "exit 0"; ::] each workers;
      exit 0];
  ];
  }

addWorker: {[addr; tests]
  .qlog.info "adding tests from address ", addr;
  alltest,: enlist tests;
  workers,: hsym `$addr;
  }


.z.ts: executeTest;
system "t 200";

.qlog.info "controller started";