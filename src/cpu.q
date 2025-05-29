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

.cpu.randTiny: {[]
  .qlog.info "starting rand int tiny test";
  N:200000;
  sT: .z.n;
  do[N;TINYLENGTH?100];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randTiny|roll int tiny"; enlist "?"; N; TINYLENGTH; sT, eT; fix[2; getMBPerSec[N*TINYLENGTH; eT-sT]]; "MB/sec\n"];
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
  N:20000;
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

.cpu.randSmall: {[]
  .qlog.info "starting rand int small test";
  N:5000;
  sT: .z.n;
  do[N;SMALLLENGTH?100];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randSmall|roll int small"; enlist "?"; N; SMALLLENGTH; sT, eT; fix[2; getMBPerSec[N*SMALLLENGTH; eT-sT]]; "MB/sec\n"];
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

///////////// MEdium vector Tests

.cpu.maxIntMedium: {[]
  .qlog.info "starting integer max medium test";
  N:10000;
  sT: .z.n;
  do[N;max mediumVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxIntMedium|max int medium"; "max"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medIntMedium: {[]
  .qlog.info "starting integer median medium test";
  N:1000;
  sT: .z.n;
  do[N;med mediumVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medIntMedium|med int medium"; "med"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevIntMedium: {[]
  .qlog.info "starting integer sdev medium test";
  N:1000;
  sT: .z.n;
  do[N;sdev mediumVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevIntMedium|sdev int medium"; "sdev"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.permuteMedium: {[]
  .qlog.info "starting permute medium test";
  N:500;
  sT: .z.n;
  do[N;0N?mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.permuteMedium|permute int medium"; "0N?"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sortMedium: {[]
  .qlog.info "starting sort medium test";
  N:500;
  sT: .z.n;
  do[N;asc mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.sortMedium|sort int medium"; "asc"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.deltasMedium: {[]
  .qlog.info "starting deltas medium test";
  N:1000;
  sT: .z.n;
  do[N;deltas mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.deltasMedium|deltas int medium"; "deltas"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.modWhereMedium: {[]
  .qlog.info "starting modulo-eq-where medium test";
  N:500;
  sT: .z.n;
  do[N;where 0=mediumVec mod 7];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.modWhereMedium|where mod = int medium"; "where 0=mod[;7]"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.randMedium: {[]
  .qlog.info "starting rand int medium test";
  N:500;
  sT: .z.n;
  do[N;MEDIUMLENGTH?100];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randMedium|roll int medium"; enlist "?"; N; MEDIUMLENGTH; sT, eT; fix[2; getMBPerSec[N*MEDIUMLENGTH; eT-sT]]; "MB/sec\n"];
  }


.cpu.xbarMedium: {[]
  .qlog.info "starting xbar medium test";
  N:1000;
  sT: .z.n;
  do[N;117 xbar mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.xbarMedium|xbar int medium"; "xbar"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyIntMedium: {[]
  .qlog.info "starting integer multiply medium test";
  N:5000;
  sT: .z.n;
  do[N;mediumVec * 100];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyIntMedium|mult int medium"; enlist "*"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideIntMedium: {[]
  .qlog.info "starting integer division medium test";
  N:1000;
  sT: .z.n;
  do[N;mediumVec div 11];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideIntMedium|div int medium"; "div"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgIntMedium: {[]
  .qlog.info "starting moving average integer medium test";
  N:500;
  sT: .z.n;
  do[N;100 mavg mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgIntMedium|mavg int medium"; "mavg"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeIntMedium: {[]
  .qlog.info "starting serialize integer medium test";
  N:2000;
  sT: .z.n;
  do[N;-9!-8!mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeIntMedium|-9!-8! int medium"; "-9!-8!"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressIntMedium: {[]
  .qlog.info "starting compress integer medium test";
  N:500;
  sT: .z.n;
  do[N;-18!mediumVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressIntMedium|-18! int medium"; "-18!"; N; count mediumVec; sT, eT; fix[2; getMBPerSec[N*count mediumVec; eT-sT]]; "MB/sec\n"];
  }

///////////////// Large vector Tests
.cpu.maxIntLarge: {[]
  .qlog.info "starting integer max test";
  N:50;
  sT: .z.n;
  do[N;max largeVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxIntLarge|max int large"; "max"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.maxFloatLarge: {[]
  .qlog.info "starting float max test";
  N:50;
  sT: .z.n;
  do[N;max largeFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.maxFloatLarge|max float large"; "max"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medIntLarge: {[]
  .qlog.info "starting integer median test";
  sT: .z.n;
  med largeVec;
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medIntLarge|med int large"; "med"; 1; count largeVec; sT, eT; fix[2; getMBPerSec[count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.medFloatLarge: {[]
  .qlog.info "starting float median test";
  sT: .z.n;
  med largeFloatVec;
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.medFloatLarge|med float large"; "med"; 1; count largeFloatVec; sT, eT; fix[2; getMBPerSec[count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevIntLarge: {[]
  .qlog.info "starting integer sdev test";
  N:10;
  sT: .z.n;
  do[N;sdev largeVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevIntLarge|sdev int large"; "sdev"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sdevFloatLarge: {[]
  .qlog.info "starting float sdev test";
  N:10;
  sT: .z.n;
  do[N;sdev largeFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.sdevFloatLarge|sdev float large"; "sdev"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.permuteLarge: {[]
  .qlog.info "starting permute large test";
  sT: .z.n;
  0N?largeVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.permuteLarge|permute int large"; "0N?"; 1; count largeVec; sT, eT; fix[2; getMBPerSec[count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.sortLarge: {[]
  .qlog.info "starting sort large test";
  sT: .z.n;
  asc largeVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.sortLarge|sort int large"; "asc"; 1; count largeVec; sT, eT; fix[2; getMBPerSec[count largeVec; eT-sT]]; "MB/sec\n"];
  }


.cpu.deltasLarge: {[]
  .qlog.info "starting deltas large test";
  N:5;
  sT: .z.n;
  do[N;deltas largeVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.deltasLarge|deltas int large"; "deltas"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.modWhereLarge: {[]
  .qlog.info "starting modulo-eq-where large test";
  N:2;
  sT: .z.n;
  do[N;where 0=largeVec mod 7];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.modWhereLarge|where mod = int large"; "where 0=mod[;7]"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.randSymLarge: {[]
  .qlog.info "starting rand symbol large test";
  N:5;
  sT: .z.n;
  do[N;LARGELENGTH?sym];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randSymLarge|roll symbol large"; enlist "?"; N; LARGELENGTH; sT, eT; fix[2; getMBPerSec[N*LARGELENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.randFloatLarge: {[]
  .qlog.info "starting rand float large test";
  N:10;
  sT: .z.n;
  do[N;LARGELENGTH?100.];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randFloatLarge|roll float large"; enlist "?"; N; LARGELENGTH; sT, eT; fix[2; getMBPerSec[N*LARGELENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.randLarge: {[]
  .qlog.info "starting rand int large test";
  N:10;
  sT: .z.n;
  do[N;LARGELENGTH?100];
  eT: .z.n;
  writeRes["cpu write mem"; ".cpu.randLarge|roll int large"; enlist "?"; N; LARGELENGTH; sT, eT; fix[2; getMBPerSec[N*LARGELENGTH; eT-sT]]; "MB/sec\n"];
  }

.cpu.groupLarge: {[]
  .qlog.info "starting group test";
  sT: .z.n;
  group largeSymVec;
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.groupLarge|group symbol large"; "group"; 1; count largeSymVec; sT, eT; fix[2; getMBPerSec[count largeSymVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.reciprocalLarge: {[]
  .qlog.info "starting reciprocal test";
  N:10;
  sT: .z.n;
  do[N;reciprocal largeFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.reciprocalLarge|reciprocal float large"; "reciprocal"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.xbarLarge: {[]
  .qlog.info "starting xbar test";
  N:10;
  sT: .z.n;
  do[N;117 xbar largeVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.xbarLarge|xbar int large"; "xbar"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.ceilingLarge: {[]
  .qlog.info "starting ceiling test";
  N:10;
  sT: .z.n;
  do[N;ceiling largeFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.ceilingLarge|ceiling float large"; "ceiling"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyIntLarge: {[]
  .qlog.info "starting integer multiply test";
  N:50;
  sT: .z.n;
  do[N;largeVec * 100];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyIntLarge|mult int large"; enlist "*"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.multiplyFloatLarge: {[]
  .qlog.info "starting float multiply test";
  N:50;
  sT: .z.n;
  do[N;largeFloatVec * 100.];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.multiplyFloatLarge|mult float large"; enlist  "*"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideIntLarge: {[]
  .qlog.info "starting integer division test";
  N:10;
  sT: .z.n;
  do[N;largeVec div 11];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideIntLarge|div int large"; "div"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.divideFloatLarge: {[]
  .qlog.info "starting float division test";
  N:10;
  sT: .z.n;
  do[N;largeFloatVec % 3.14];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.divideFloatLarge|div float large"; enlist  "%"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgIntLarge: {[]
  .qlog.info "starting moving average integer test";
  N:1;
  sT: .z.n;
  do[N;100 mavg largeVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgIntLarge|mavg int large"; "mavg"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.mavgFloatLarge: {[]
  .qlog.info "starting moving average float test";
  N:1;
  sT: .z.n;
  do[N;100 mavg largeFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.mavgFloatLarge|mavg float large"; "mavg"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.wavgLarge: {[]
  .qlog.info "starting weighted average test";
  N:20;
  sT: .z.n;
  do[N;largeVec wavg largeFloatVec];
  eT: .z.n;
  writeRes["cpu read mem"; ".cpu.wavgLarge|wavg float large"; "wavg"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[2*N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeIntLarge: {[]
  .qlog.info "starting serialize integer large test";
  N:50;
  sT: .z.n;
  do[N;-9!-8!largeVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeIntLarge|-9!-8! int large"; "-9!-8!"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.serializeFloatLarge: {[]
  .qlog.info "starting serialize float large test";
  N:50;
  sT: .z.n;
  do[N;-9!-8!largeFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.serializeFloatLarge|-9!-8! float large"; "-9!-8!"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressIntLarge: {[]
  .qlog.info "starting compress integer large test";
  N:5;
  sT: .z.n;
  do[N;-18!largeVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressIntLarge|-18! int large"; "-18!"; N; count largeVec; sT, eT; fix[2; getMBPerSec[N*count largeVec; eT-sT]]; "MB/sec\n"];
  }

.cpu.compressFloatLarge: {[]
  .qlog.info "starting compress float large test";
  N:2;
  sT: .z.n;
  do[N;-18!largeFloatVec];
  eT: .z.n;
  writeRes["cpu read write mem"; ".cpu.compressFloatLarge|-18! float large"; "-18!"; N; count largeFloatVec; sT, eT; fix[2; getMBPerSec[N*count largeFloatVec; eT-sT]]; "MB/sec\n"];
  }

sendTests[controller;DB;`.cpu]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i