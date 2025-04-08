system "l src/common.q";
system "l src/samplearrays.q";

.cpu.smallPermute: {[]
  .qlog.info "starting permute small test";
  N:5000;
  sT: .z.n;
  do[N;0N?smallVec];  / so fast so do 5000 times
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.smallPermute|permute small"; "0N?"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.smallSort: {[]
  .qlog.info "starting sort small test";
  N:5000;
  sT: .z.n;
  do[N;asc smallVec];  / so fast so do 5000 times
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.smallSort|sort small"; "asc"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midPermute: {[]
  .qlog.info "starting permute mid test";
  sT: .z.n;
  0N?midVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.midPermute|permute mid"; "0N?"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midSort: {[]
  .qlog.info "starting sort mid test";
  sT: .z.n;
  asc midVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.midSort|sort mid"; "asc"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.midDeltas: {[]
  .qlog.info "starting deltas mid test";
  N:10;
  sT: .z.n;
  do[N;deltas midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.midDeltas|deltas mid"; "deltas"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midModWhere: {[]
  .qlog.info "starting modulo-eq-where mid test";
  N:5;
  sT: .z.n;
  do[N;where 0=midVec mod 7];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.midModWhere|where mod = mid"; "where 0=mod[;7]"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midRandSym: {[]
  .qlog.info "starting rand symbol mid test";
  N:5;
  sT: .z.n;
  do[N;MIDLENGTH?sym];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.midRandSym|roll symbol mid"; enlist "?"; N; MIDLENGTH; sT, eT; fix[2; getMBPerSec[N*MIDLENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.midRandFloat: {[]
  .qlog.info "starting rand float mid test";
  N:10;
  sT: .z.n;
  do[N;MIDLENGTH?100.];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.midRandFloat|roll float mid"; enlist "?"; N; MIDLENGTH; sT, eT; fix[2; getMBPerSec[N*MIDLENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.group: {[]
  .qlog.info "starting group test";
  sT: .z.n;
  group midSymVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.group|group mid"; "group"; 1; count midSymVec; sT, eT; fix[2; getMBPerSec[count midSymVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.reciprocal: {[]
  .qlog.info "starting reciprocal test";
  N:10;
  sT: .z.n;
  do[N;reciprocal midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.reciprocal|reciprocal mid"; "reciprocal"; N; count midSymVec; sT, eT; fix[2; getMBPerSec[N*count midSymVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.xbar: {[]
  .qlog.info "starting xbar test";
  N:10;
  sT: .z.n;
  do[N;1117 xbar midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.xbar|xbar mid"; "xbar"; N; count midSymVec; sT, eT; fix[2; getMBPerSec[N*count midSymVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.maxInt: {[]
  .qlog.info "starting integer max test";
  N:50;
  sT: .z.n;
  do[N;max midVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxInt|max int mid"; "max"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.maxFloat: {[]
  .qlog.info "starting float max test";
  N:50;
  sT: .z.n;
  do[N;max midFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxFloat|max float mid"; "max"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.medInt: {[]
  .qlog.info "starting integer median test";
  sT: .z.n;
  med midVec;
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medInt|med int mid"; "med"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medFloat: {[]
  .qlog.info "starting float median test";
  sT: .z.n;
  med midFloatVec;
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medFloat|med float mid"; "med"; 1; count midFloatVec; sT, eT; fix[2; getMBPerSec[count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevInt: {[]
  .qlog.info "starting integer sdev test";
  N:10;
  sT: .z.n;
  do[N;sdev midVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevInt|sdev int mid"; "sdev"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevFloat: {[]
  .qlog.info "starting float sdev test";
  N:10;
  sT: .z.n;
  do[N;sdev midFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevFloat|sdev float mid"; "sdev"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.ceiling: {[]
  .qlog.info "starting ceiling test";
  N:10;
  sT: .z.n;
  do[N;ceiling midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.ceiling|ceiling mid"; "ceiling"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyInt: {[]
  .qlog.info "starting integer multiply test";
  N:50;
  sT: .z.n;
  do[N;midVec * 100];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyInt|mult int mid"; enlist "*"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyFloat: {[]
  .qlog.info "starting float multiply test";
  N:50;
  sT: .z.n;
  do[N;midFloatVec * 100.];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyFloat|mult float mid"; enlist  "*"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideInt: {[]
  .qlog.info "starting integer division test";
  N:10;
  sT: .z.n;
  do[N;midVec div 11];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideInt|div int mid"; "div"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideFloat: {[]
  .qlog.info "starting float division test";
  N:10;
  sT: .z.n;
  do[N;midFloatVec % 3.14];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideFloat|div float mid"; enlist  "%"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgInt: {[]
  .qlog.info "starting moving average integer test";
  N:5;
  sT: .z.n;
  do[N;100 mavg midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgInt|mavg int mid"; "mavg"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgFloat: {[]
  .qlog.info "starting moving average float test";
  N:5;
  sT: .z.n;
  do[N;100 mavg midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgFloat|mavg float mid"; "mavg"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.wavg: {[]
  .qlog.info "starting weighted average test";
  N:10;
  sT: .z.n;
  do[N;midVec wavg midFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.wavg|wavg mid"; "wavg"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[2*N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }


sendTests[controller;DB;`.cpu]

.qlog.info "Ready for test execution";