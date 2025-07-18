system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x
system "l src/util.q";

workerNr: system "s" // We assume that each worker has its own thread
iostatH: hopen ":", argv `iostatfile

Alltest:Workers:Devices: ();

iostatError: `kB_read`kB_wrtn`kB_sum!3#0Nj
Start: 0Np

getKBReadMac: {[devices]
  if[devices ~ enlist ""; :iostatError];
  iostatcmd: "iostat -d -I ", (" " sv devices), " 2>&1"; // -I returns the MB read as last column
  r: @[system; iostatcmd; .qlog.error];
  if[not 0h ~ type r; :iostatError];
  @[iostatError;`kB_sum;:;1000*`long$"F"$l last where not "" ~/: l:" " vs last r]
  }

getKBReadLinux: {[devices]
  iostatcmd: "iostat -dk -o JSON ", (" " sv devices), " 2>&1";
  r: @[system; iostatcmd; .qlog.error];
  :$[0h ~ type r; [
  	iostats: @[; `disk] first @[; `statistics] first first first value flip value .j.k raze r;
  	$[count iostats; [m:exec `long$sum kB_read, `long$sum kB_wrtn from iostats;m,([kB_sum: sum m])]; iostatError]];
	iostatError]
  }

getKBRead: $["false" ~ lower getenv `IOSTAT; {[x] iostatError}; .z.o ~ `m64; getKBReadMac; getKBReadLinux]

finish: {[x:`j]
  .qlog.info "Sending exit message to workers";
  @[; "exit ", string x; ::] each Workers;
  exit x
  }

TIMEOUT: 0D00:01
executeTest: {[dontcare]
  if[TIMEOUT < .z.p - Start;
    .qlog.error "Waiting for workers timed out.";
    finish 3];
  if[workerNr = count Workers;
    system "t 0";
    if[ any 1_differ Alltest; .qlog.error "Not all tests are the same!"; finish 1];
    tests: first[Alltest] where not any first[Alltest] like/: exclusetests;
    .qlog.info "Starting executing ", string[count tests], " tests one-by-one";
    {[t]
      .qlog.info "Executing test ", string t;
      ddevices: distinct Devices;
      sS: getKBRead[ddevices]; sT: .z.n;
      @[; (t; ::); {.qlog.info "Error during test execution ", x; finish 4}] peach Workers;
      eT: .z.n; eS: getKBRead[ddevices];
      iostatH string[t], SEP, (SEP sv value fix[2; (eS-sS)%1000*tsToSec eT-sT]),"\n";
      @[; (.Q.gc; ::)] peach Workers;
      } each tests;
    .qlog.info "All tests were executed.";
    if[not `debug in argvk; finish 0];
  ];
  }

handleToIP: (`int$())!()

.z.po: {
  handleToIP[x]:"." sv string "i"$0x0 vs .z.a;
  .qlog.info "Connection mapping to ", handleToIP[x], " was added";
  }
.z.pc: {handleToIP:: handleToIP cut x}

addWorker: {[port:`i; device:`C; tests:`S]
  addr:handleToIP[.z.w],":",string port;
  .qlog.info "adding tests from address ", addr, " using device ", device;
  if[0=count Workers; Start:: .z.p];
  Alltest,: enlist tests;
  Workers,: hsym `$addr;
  Devices,: enlist device;
  }


.z.ts: executeTest;
system "t 200";

exclusetests: " " vs getenv `EXCLUDETESTS

.qlog.info "controller started with pid ", string .z.i
