system "l src/common.q";

.xasc.xasc: {[]
  .qlog.info "Starting xasc test";
  sT:.z.n;
  `sym xasc KDBTBL;
  eT: .z.n;
  totallistlength: count[cols KDBTBL] * count get KDBTBL; // assuming only 8 byte columns
  writeRes["read write disk";".xasc.xasc|disk sort";"xasc"; 1; totallistlength; sT, eT; fix[2;getMBPerSec[totallistlength; eT-sT]]; "MB/sec\n"];
  }

.xasc.phash: {[]
  .qlog.info "Starting p# test";
  sT:.z.n;
  @[KDBTBL; `sym; `p#];
  eT: .z.n;
  writeRes["read write disk";".xasc.phash|add attribute";"@[; `sym; `p#]"; 1; count get KDBTBL; sT, eT; fix[2;getMBPerSec[count get KDBTBL; eT-sT]]; "MB/sec\n"];
  }

controller (`addWorker; address[]; getDisk[]; getTests[`.xasc])