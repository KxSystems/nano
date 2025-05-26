system "l src/common.q";
system "l src/samplearrays.q";

///////////// Tiny vector Tests

.cpu.maxIntTiny: {[]
  .qlog.info "starting integer max tiny test";
  N:2000000;
  sT: .z.n;
  do[N;max tinyVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxIntTiny|max int tiny"; "max"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medIntTiny: {[]
  .qlog.info "starting integer median tiny test";
  N:200000;
  sT: .z.n;
  do[N;med tinyVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medIntTiny|med int tiny"; "med"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevIntTiny: {[]
  .qlog.info "starting integer sdev tiny test";
  N:500000;
  sT: .z.n;
  do[N;sdev tinyVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevIntTiny|sdev int tiny"; "sdev"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.permuteTiny: {[]
  .qlog.info "starting permute tiny test";
  N:100000;
  sT: .z.n;
  do[N;0N?tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.permuteTiny|permute int tiny"; "0N?"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sortTiny: {[]
  .qlog.info "starting sort tiny test";
  N:200000;
  sT: .z.n;
  do[N;asc tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.sortTiny|sort int tiny"; "asc"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.deltasTiny: {[]
  .qlog.info "starting deltas tiny test";
  N:1000000;
  sT: .z.n;
  do[N;deltas tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.deltasTiny|deltas int tiny"; "deltas"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.modWhereTiny: {[]
  .qlog.info "starting modulo-eq-where tiny test";
  N:100000;
  sT: .z.n;
  do[N;where 0=tinyVec mod 7];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.modWhereTiny|where mod = int tiny"; "where 0=mod[;7]"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.xbarTiny: {[]
  .qlog.info "starting xbar tiny test";
  N:200000;
  sT: .z.n;
  do[N;117 xbar tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.xbarTiny|xbar int tiny"; "xbar"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyIntTiny: {[]
  .qlog.info "starting integer multiply tiny test";
  N:2000000;
  sT: .z.n;
  do[N;tinyVec * 100];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyIntTiny|mult int tiny"; enlist "*"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideIntTiny: {[]
  .qlog.info "starting integer division tiny test";
  N:200000;
  sT: .z.n;
  do[N;tinyVec div 11];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideIntTiny|div int tiny"; "div"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgIntTiny: {[]
  .qlog.info "starting moving average integer tiny test";
  N:100000;
  sT: .z.n;
  do[N;100 mavg tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgIntTiny|mavg int tiny"; "mavg"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeIntTiny: {[]
  .qlog.info "starting serialize integer tiny test";
  N:1000000;
  sT: .z.n;
  do[N;-9!-8!tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeIntTiny|-9!-8! int tiny"; "-9!-8!"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressIntTiny: {[]
  .qlog.info "starting compress integer tiny test";
  N:200000;
  sT: .z.n;
  do[N;-18!tinyVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressIntTiny|-18! int tiny"; "-18!"; N; count tinyVec; sT, eT; fix[2; getMBPerSec[N*count tinyVec; eT-sT]]; "MB/sec\n"];
  }

///////////// Small vector Tests

.cpu.maxIntSmall: {[]
  .qlog.info "starting integer max small test";
  N:100000;
  sT: .z.n;
  do[N;max smallVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxIntSmall|max int small"; "max"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medIntSmall: {[]
  .qlog.info "starting integer median small test";
  N:10000;
  sT: .z.n;
  do[N;med smallVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medIntSmall|med int small"; "med"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevIntSmall: {[]
  .qlog.info "starting integer sdev small test";
  N:10000;
  sT: .z.n;
  do[N;sdev smallVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevIntSmall|sdev int small"; "sdev"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.permuteSmall: {[]
  .qlog.info "starting permute small test";
  N:5000;
  sT: .z.n;
  do[N;0N?smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.permuteSmall|permute int small"; "0N?"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sortSmall: {[]
  .qlog.info "starting sort small test";
  N:5000;
  sT: .z.n;
  do[N;asc smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.sortSmall|sort int small"; "asc"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.deltasSmall: {[]
  .qlog.info "starting deltas small test";
  N:10000;
  sT: .z.n;
  do[N;deltas smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.deltasSmall|deltas int small"; "deltas"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.modWhereSmall: {[]
  .qlog.info "starting modulo-eq-where small test";
  N:5000;
  sT: .z.n;
  do[N;where 0=smallVec mod 7];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.modWhereSmall|where mod = int small"; "where 0=mod[;7]"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.xbarSmall: {[]
  .qlog.info "starting xbar small test";
  N:10000;
  sT: .z.n;
  do[N;117 xbar smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.xbarSmall|xbar int small"; "xbar"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyIntSmall: {[]
  .qlog.info "starting integer multiply small test";
  N:50000;
  sT: .z.n;
  do[N;smallVec * 100];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyIntSmall|mult int small"; enlist "*"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideIntSmall: {[]
  .qlog.info "starting integer division small test";
  N:10000;
  sT: .z.n;
  do[N;smallVec div 11];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideIntSmall|div int small"; "div"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgIntSmall: {[]
  .qlog.info "starting moving average integer small test";
  N:5000;
  sT: .z.n;
  do[N;100 mavg smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgIntSmall|mavg int small"; "mavg"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeIntSmall: {[]
  .qlog.info "starting serialize integer small test";
  N:20000;
  sT: .z.n;
  do[N;-9!-8!smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeIntSmall|-9!-8! int small"; "-9!-8!"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressIntSmall: {[]
  .qlog.info "starting compress integer small test";
  N:5000;
  sT: .z.n;
  do[N;-18!smallVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressIntSmall|-18! int small"; "-18!"; N; count smallVec; sT, eT; fix[2; getMBPerSec[N*count smallVec; eT-sT]]; "MB/sec\n"];
  }


///////////////// Mid vector Tests
.cpu.maxIntMid: {[]
  .qlog.info "starting integer max test";
  N:100;
  sT: .z.n;
  do[N;max midVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxIntMid|max int mid"; "max"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.maxFloatMid: {[]
  .qlog.info "starting float max test";
  N:50;
  sT: .z.n;
  do[N;max midFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxFloatMid|max float mid"; "max"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medIntMid: {[]
  .qlog.info "starting integer median test";
  sT: .z.n;
  med midVec;
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medIntMid|med int mid"; "med"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medFloatMid: {[]
  .qlog.info "starting float median test";
  sT: .z.n;
  med midFloatVec;
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medFloatMid|med float mid"; "med"; 1; count midFloatVec; sT, eT; fix[2; getMBPerSec[count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevIntMid: {[]
  .qlog.info "starting integer sdev test";
  N:10;
  sT: .z.n;
  do[N;sdev midVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevIntMid|sdev int mid"; "sdev"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevFloatMid: {[]
  .qlog.info "starting float sdev test";
  N:10;
  sT: .z.n;
  do[N;sdev midFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevFloatMid|sdev float mid"; "sdev"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.permuteMid: {[]
  .qlog.info "starting permute mid test";
  sT: .z.n;
  0N?midVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.permuteMid|permute int mid"; "0N?"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sortMid: {[]
  .qlog.info "starting sort mid test";
  sT: .z.n;
  asc midVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.sortMid|sort int mid"; "asc"; 1; count midVec; sT, eT; fix[2; getMBPerSec[count midVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.deltasMid: {[]
  .qlog.info "starting deltas mid test";
  N:10;
  sT: .z.n;
  do[N;deltas midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.deltasMid|deltas int mid"; "deltas"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.modWhereMid: {[]
  .qlog.info "starting modulo-eq-where mid test";
  N:5;
  sT: .z.n;
  do[N;where 0=midVec mod 7];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.modWhereMid|where mod = int mid"; "where 0=mod[;7]"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.midRandSym: {[]
  .qlog.info "starting rand symbol mid test";
  N:5;
  sT: .z.n;
  do[N;MIDLENGTH?sym];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.midRandSym|roll symbol mid"; enlist "?"; N; MIDLENGTH; sT, eT; fix[2; getMBPerSec[N*MIDLENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.randFloatMid: {[]
  .qlog.info "starting rand float mid test";
  N:10;
  sT: .z.n;
  do[N;MIDLENGTH?100.];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randFloatMid|roll float mid"; enlist "?"; N; MIDLENGTH; sT, eT; fix[2; getMBPerSec[N*MIDLENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.groupMid: {[]
  .qlog.info "starting group test";
  sT: .z.n;
  group midSymVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.groupMid|group symbol mid"; "group"; 1; count midSymVec; sT, eT; fix[2; getMBPerSec[count midSymVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.reciprocalMid: {[]
  .qlog.info "starting reciprocal test";
  N:10;
  sT: .z.n;
  do[N;reciprocal midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.reciprocalMid|reciprocal float mid"; "reciprocal"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.xbarMid: {[]
  .qlog.info "starting xbar test";
  N:10;
  sT: .z.n;
  do[N;117 xbar midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.xbarMid|xbar int mid"; "xbar"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.ceilingMid: {[]
  .qlog.info "starting ceiling test";
  N:10;
  sT: .z.n;
  do[N;ceiling midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.ceilingMid|ceiling float mid"; "ceiling"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyIntMid: {[]
  .qlog.info "starting integer multiply test";
  N:50;
  sT: .z.n;
  do[N;midVec * 100];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyIntMid|mult int mid"; enlist "*"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyFloatMid: {[]
  .qlog.info "starting float multiply test";
  N:50;
  sT: .z.n;
  do[N;midFloatVec * 100.];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyFloatMid|mult float mid"; enlist  "*"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideIntMid: {[]
  .qlog.info "starting integer division test";
  N:10;
  sT: .z.n;
  do[N;midVec div 11];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideIntMid|div int mid"; "div"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideFloatMid: {[]
  .qlog.info "starting float division test";
  N:10;
  sT: .z.n;
  do[N;midFloatVec % 3.14];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideFloatMid|div float mid"; enlist  "%"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgIntMid: {[]
  .qlog.info "starting moving average integer test";
  N:5;
  sT: .z.n;
  do[N;100 mavg midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgIntMid|mavg int mid"; "mavg"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgFloatMid: {[]
  .qlog.info "starting moving average float test";
  N:5;
  sT: .z.n;
  do[N;100 mavg midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgFloatMid|mavg float mid"; "mavg"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.wavgMid: {[]
  .qlog.info "starting weighted average test";
  N:20;
  sT: .z.n;
  do[N;midVec wavg midFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.wavgMid|wavg float mid"; "wavg"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[2*N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeIntMid: {[]
  .qlog.info "starting serialize integer mid test";
  N:100;
  sT: .z.n;
  do[N;-9!-8!midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeIntMid|-9!-8! int mid"; "-9!-8!"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeFloatMid: {[]
  .qlog.info "starting serialize float mid test";
  N:100;
  sT: .z.n;
  do[N;-9!-8!midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeFloatMid|-9!-8! float mid"; "-9!-8!"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressIntMid: {[]
  .qlog.info "starting compress integer mid test";
  N:5;
  sT: .z.n;
  do[N;-18!midVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressIntMid|-18! int mid"; "-18!"; N; count midVec; sT, eT; fix[2; getMBPerSec[N*count midVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressFloatMid: {[]
  .qlog.info "starting compress float mid test";
  N:5;
  sT: .z.n;
  do[N;-18!midFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressFloatMid|-18! float mid"; "-18!"; N; count midFloatVec; sT, eT; fix[2; getMBPerSec[N*count midFloatVec; eT-sT]]; "MB/sec\n"];
  }

sendTests[controller;DB;`.cpu]

.qlog.info "Ready for test execution";