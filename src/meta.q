system "l src/common.q";

/ this is to allow any 3rd party performance monotoring tools to see a time gap
system"sleep 5";


$[OBJSTORE;
  .qlog.info"Skipping hopen/append/symlink/enum extend meta tests"; [
  .meta.openclose: {[]
    .qlog.info "starting close open test";
    sT:.z.n;
    do[N; hclose hopen fOpenClose];
    eT: .z.n;
    writeRes["meta";".meta.openclose|close open";"hopen,hclose"; N; 0Nj; sT, eT; fix[4;1000 * tsToSec[eT-sT]%N];"ms\n"];
  };

  .meta.link: {[]
    .qlog.info"symbolic link test...";
    system"rm -f ", DB, "/fileopstest.sym";
    system"ln -s ", DB, fHmmapFileName, " ", DB, "/fileopstest.sym";
	/ go in hard
    .qlog.info"hard link test...";
    system"rm -f ", DB, "/fileops.hard";
    system"ln ", DB, fHmmapFileName, " ", DB, "/fileops.hard";
    };

  .meta.lock: {[]
    .qlog.info "starting lock test";
    sT:.z.n;
    do[N; flock?`aaa`bbb`ccc`ddd`eee];
    eT: .z.n;
    writeRes["meta";".meta.lock|lock";"enum extend"; N; 4; sT, eT; fix[4;1000 * tsToSec[eT-sT]%N];"ms\n"]
    }]];

.meta.size: {[]
  .qlog.info "starting size test";
  sT:.z.n;
  do[N; hcount fhcount];
  eT: .z.n;
  writeRes["meta";".meta.size|size";"hcount"; N; hcount fhcount; sT, eT; fix[4;1000 * tsToSec[eT-sT]%N];"ms\n"];
  }

.meta.get: {[]
  .qlog.info "starting mmap test";
  sT:.z.n;
  do[N; get fmmap];
  eT: .z.n;
  writeRes["read disk";".meta.get|mmap";"get"; N; count get fmmap; sT, eT; fix[4;1000 * tsToSec[eT-sT]%N];"ms\n"];
  }

controller (`addWorker; address[]; getDisk[]; getTests[`.meta]);
