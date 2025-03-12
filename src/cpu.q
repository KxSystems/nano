system "l src/common.q";

.cpu.smallPermute: {[]
  .qlog.info "starting permute small test";
  N:5000;
  sT: .z.n;
  do[N;0N?smallVec];  / so fast so do 5000 times
  eT: .z.n;
  writeRes["read write mem"; ".cpu.smallPermute|permute small"; "0N?"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.smallSort: {[]
  .qlog.info "starting sort small test";
  N:5000;
  sT: .z.n;
  do[N;asc smallVec];  / so fast so do 5000 times
  eT: .z.n;
  writeRes["read write mem"; ".cpu.smallSort|sort small"; "asc"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midPermute: {[]
  .qlog.info "starting permute mid test";
  sT: .z.n;
  0N?midVec;
  eT: .z.n;
  writeRes["read write mem"; ".cpu.midPermute|permute mid"; "0N?"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midDeltas: {[]
  .qlog.info "starting deltas mid test";
  N:10;
  sT: .z.n;
  do[N;deltas midVec];
  eT: .z.n;
  writeRes["read write mem"; ".cpu.midDeltas|deltas mid"; "deltas"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midModWhere: {[]
  .qlog.info "starting modulo-eq-where mid test";
  N:5;
  sT: .z.n;
  do[N;where 0=midVec mod 7];
  eT: .z.n;
  writeRes["read write mem"; ".cpu.midModWhere|where mod = mid"; "where 0=mod[;7]"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midSort: {[]
  .qlog.info "starting sort mid test";
  sT: .z.n;
  asc midVec;
  eT: .z.n;
  writeRes["read write mem"; ".cpu.midSort|sort mid"; "asc"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midRandSym: {[]
  .qlog.info "starting rand symbol mid test";
  sT: .z.n;
  MIDLENGTH?sym;
  eT: .z.n;
  writeRes["write mem"; ".cpu.midRandSym|roll mid"; enlist "?"; 1; MIDLENGTH; sT, eT; fix[2; getMBPerSec[MIDLENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.midRandFloat: {[]
  .qlog.info "starting rand float mid test";
  N:10;
  sT: .z.n;
  do[N;MIDLENGTH?100.];
  eT: .z.n;
  writeRes["write mem"; ".cpu.midRandFloat|roll mid"; enlist "?"; N; MIDLENGTH; sT, eT; fix[2; getMBPerSec[N*MIDLENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.group: {[]
  .qlog.info "starting group test";
  sT: .z.n;
  group midSymVec;
  eT: .z.n;
  writeRes["read write mem"; ".cpu.group|group mid"; "group"; 1; count midSymVec; sT, eT; fix[2; getMBPerSec[count midSymVec; eT-sT]]; "MB/sec\n"];
  }

sendTests[controller;DB;`.cpu]

.qlog.info "Ready for test execution";