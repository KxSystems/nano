system "l src/log.q";

workerNr: system "s" // We assume that each worker has its own thread

`alltest set ();
`workers set ();

executeTest: {[dontcare]
  if[workerNr = count workers;
    if[ any 1_differ alltest; .qlog.error "Not all tests are the same!"; exit 1];
    {[t]
      .qlog.info "Executing test ", string t;
      @[; (t; ::)] peach workers} each first alltest;
    .qlog.info "All tests were executed. Sending exit message to workers.";
    @[; "exit 0"; ::] each workers;
    exit 0;
  ];
  }

addWorker: {[tests]
  .qlog.info "adding tests from handle ", string .z.w;
  alltest,: enlist tests;
  workers,: .z.w;
  }


.z.ts: executeTest;
system "t 200";

.qlog.info "controller started";