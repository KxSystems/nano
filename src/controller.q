system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x
system "l src/util.q";

workerNr: system "s" // We assume that each worker has its own thread
iostatH: hopen ":", argv `iostatfile

Alltest:Workers:Decives: ();

iostatError: `kB_read`kB_wrtn!2#0Nj
Start: 0Np

getKBReadMac: {[x] iostatError}
getKBReadLinux: {[devices]
  iostatcmd: "iostat -dk -o JSON ", (" " sv devices), " 2>&1";
  r: @[system; iostatcmd; .qlog.error];
  :$[0h ~ type r; [
  	iostats: @[; `disk] first @[; `statistics] first first first value flip value .j.k raze r;
  	$[count iostats; exec `long$sum kB_read, `long$sum kB_wrtn from iostats; iostatError]];
	iostatError]
  }

getKBRead: $[.z.o ~ `m64; getKBReadMac; getKBReadLinux]

finish: {[x]
  .qlog.info "Sending exit message to workers";
  @[; "exit 0"; ::] each Workers;
  exit x
  }

TIMEOUT: 0D00:01
executeTest: {[dontcare]
  if[TIMEOUT < .z.p - Start;
    .qlog.error "Waiting for workers timed out.";
    finish 3];
  if[workerNr = count Workers;
    system "t 0";
    if[ any 1_differ Alltest; .qlog.error "Not all tests are the same!"; exit 1];
    {[t]
      .qlog.info "Executing test ", string t;
      ddevices: distinct Decives;
      sS: getKBRead[ddevices]; sT: .z.n;
      @[; (t; ::)] peach Workers;
      eT: .z.n; eS: getKBRead[ddevices];
      iostatH string[t], SEP, (SEP sv value fix[2; (eS-sS)%1000*tsToSec eT-sT]),"\n";
      } each first[Alltest] except exclusetests;
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

addWorker: {[port; decive; tests]
  addr:handleToIP[.z.w],":",string port;
  .qlog.info "adding tests from address ", addr, " using decive ", decive;
  if[0=count Workers; Start:: .z.p];
  Alltest,: enlist tests;
  Workers,: hsym `$addr;
  Decives,: enlist decive;
  }


.z.ts: executeTest;
system "t 200";

exclusetests: `$" " vs getenv `EXCLUDETESTS

.qlog.info "controller started";
