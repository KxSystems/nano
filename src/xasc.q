system "l src/common.q";

COLLENTH: count get fSymCol
ALLCOLLSENGTH: COLLENTH * count cols KDBTBL // assuming column types have the same size

.xasc.xasc: {[]
  .qlog.info "Starting xasc test";
  sT:.z.n;
  `sym xasc KDBTBL;
  eT: .z.n;
  writeRes["read write disk";".xasc.xasc|disk sort";"xasc"; 1; ALLCOLLSENGTH; sT, eT; fix[2;getMBPerSec[ALLCOLLSENGTH; eT-sT]]; "MB/sec\n"];
  }

testFactory["write disk"; `.xasc.syncAfterSort;1;system;"system sync";"sync ",1_string KDBTBL;"sync table after sort";ALLCOLLSENGTH]; / assuming two columns 

.xasc.phash: {[]
  .qlog.info "Starting p# test";
  sT:.z.n;
  @[KDBTBL; `sym; `p#];
  eT: .z.n;
  writeRes["read mem write disk";".xasc.phash|add attribute";"@[; `sym; `p#]"; 1; COLLENTH; sT, eT; fix[2;getMBPerSec[COLLENTH; eT-sT]]; "MB/sec\n"];
  }

testFactory["write disk"; `.xasc.syncAfterPhash;1;system;"system sync";"sync ",1_string .Q.dd[KDBTBL;`sym];"sync table after phash";COLLENTH];

sendTests[controller;DB;`.xasc]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i