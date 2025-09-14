system "l src/common.q";
system "l src/samplearrays.q";

CPUREPEAT: 1^"I"$getenv `CPUREPEAT
NS:`.cpu

testFactory["cpu read mem"; .Q.dd[NS; `maxIntMedium];CPUREPEAT*10000;max;"max";mediumVec;"max int medium";1]
testFactory["cpu read mem"; .Q.dd[NS; `medIntMedium];CPUREPEAT*1000;med;"med";mediumVec;"med int medium";1]
testFactory["cpu read mem"; .Q.dd[NS; `sdevIntMedium];CPUREPEAT*1000;sdev;"sdev";mediumVec;"sdev int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `permuteIntMedium];CPUREPEAT*500;0N?;"0N?";mediumVec;"permute int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `sortIntMedium];CPUREPEAT*500;asc;"asc";mediumVec;"sort int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `deltasIntMedium];CPUREPEAT*1000;deltas;"deltas";mediumVec;"deltas int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `modWhereIntMedium];CPUREPEAT*500;where 0=mod[;7]@;"where mod =";mediumVec;"where mod = int medium";1]
testFactory["cpu write mem"; .Q.dd[NS; `tilIntMedium];CPUREPEAT*5000;til;"til";MEDIUMLENGTH;"til int medium";MEDIUMLENGTH]
testFactory["cpu write mem"; .Q.dd[NS; `randIntMedium];CPUREPEAT*500;MEDIUMLENGTH?;enlist "?";100;"roll int medium";MEDIUMLENGTH]
testFactory["cpu read write mem"; .Q.dd[NS; `xbarIntMedium];CPUREPEAT*1000;117 xbar;"xbar";mediumVec;"xbar int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `multiplyIntMedium];CPUREPEAT*5000;100*;enlist "*";mediumVec;"mult int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `divideIntMedium];CPUREPEAT*1000;div[;11];"div";mediumVec;"div int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `mavgIntMedium];CPUREPEAT*500;100 mavg;"mavg";mediumVec;"mavg int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `groupIntMedium];CPUREPEAT*500;group;"group";mediumVec;"group int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `serializeIntMedium];CPUREPEAT*2000;-9!-8!;"-9!-8!";mediumVec;"-9!-8! int medium";1]
testFactory["cpu read write mem"; .Q.dd[NS; `compressIntMedium];CPUREPEAT*500;-18!;"-18!";mediumVec;"-18! int medium";1]


testFactory["cpu read mem"; .Q.dd[NS; `maxIntLarge];CPUREPEAT*50;max;"max";largeVec;"max int large";1]
testFactory["cpu read mem"; .Q.dd[NS; `medIntLarge];CPUREPEAT*1;med;"med";largeVec;"med int large";1]
testFactory["cpu read mem"; .Q.dd[NS; `sdevIntLarge];CPUREPEAT*10;sdev;"sdev";largeVec;"sdev int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `permuteIntLarge];CPUREPEAT*1;0N?;"0N?";largeVec;"permute int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `sortIntLarge];CPUREPEAT*1;asc;"asc";largeVec;"sort int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `deltasIntLarge];CPUREPEAT*10;deltas;"deltas";largeVec;"deltas int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `modWhereIntLarge];CPUREPEAT*2;where 0=mod[;7]@;"where mod =";largeVec;"where mod = int large";1]
testFactory["cpu write mem"; .Q.dd[NS; `tilIntLarge];CPUREPEAT*100;til;"til";LARGELENGTH;"til int large";LARGELENGTH]
testFactory["cpu write mem"; .Q.dd[NS; `randIntLarge];CPUREPEAT*10;LARGELENGTH?;enlist "?";100;"roll int large";LARGELENGTH]
testFactory["cpu read write mem"; .Q.dd[NS; `xbarIntLarge];CPUREPEAT*10;117 xbar;"xbar";largeVec;"xbar int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `multiplyIntLarge];CPUREPEAT*50;100*;enlist "*";largeVec;"mult int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `divideIntLarge];CPUREPEAT*10;div[;11];"div";largeVec;"div int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `mavgIntLarge];CPUREPEAT*1;100 mavg;"mavg";largeVec;"mavg int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `groupIntLarge];CPUREPEAT*1;group;"group";largeVec;"group int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `serializeIntLarge];CPUREPEAT*50;-9!-8!;"-9!-8!";largeVec;"-9!-8! int large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `compressIntLarge];CPUREPEAT*5;-18!;"-18!";largeVec;"-18! int large";1]


testFactory["cpu read mem"; .Q.dd[NS; `maxFloatLarge];CPUREPEAT*50;max;"max";largeFloatVec;"max float large";1]
testFactory["cpu read mem"; .Q.dd[NS; `medFloatLarge];CPUREPEAT*1;med;"med";largeFloatVec;"med float large";1]
testFactory["cpu read mem"; .Q.dd[NS; `sdevFloatLarge];CPUREPEAT*10;sdev;"sdev";largeFloatVec;"sdev float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `permuteLarge];CPUREPEAT*1;0N?;"0N?";largeFloatVec;"permute float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `sortLarge];CPUREPEAT*1;asc;"asc";largeFloatVec;"sort float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `deltasLarge];CPUREPEAT*5;deltas;"deltas";largeFloatVec;"deltas float large";1]
testFactory["cpu write mem"; .Q.dd[NS; `randFloatLarge];CPUREPEAT*10;LARGELENGTH?;enlist "?";100.;"roll float large";LARGELENGTH]
testFactory["cpu read write mem"; .Q.dd[NS; `xbarLarge];CPUREPEAT*10;117. xbar;"xbar";largeFloatVec;"xbar float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `multiplyFloatLarge];CPUREPEAT*50;100.*;enlist "*";largeFloatVec;"mult float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `divideFloatLarge];CPUREPEAT*10;div[;11.];"div";largeFloatVec;"div float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `mavgFloatLarge];CPUREPEAT*1;100 mavg;"mavg";largeFloatVec;"mavg float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `groupFloatLarge];CPUREPEAT*1;group;"group";largeFloatVec;"group float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `serializeFloatLarge];CPUREPEAT*50;-9!-8!;"-9!-8!";largeFloatVec;"-9!-8! float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `compressFloatLarge];CPUREPEAT*5;-18!;"-18!";largeFloatVec;"-18! float large";1]

/ Float-only operations
testFactory["cpu read write mem"; .Q.dd[NS; `reciprocalFloatLarge];CPUREPEAT*50;reciprocal;"reciprocal";largeFloatVec;"reciprocal float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `ceilingFloatLarge];CPUREPEAT*20;ceiling;"ceiling";largeFloatVec;"ceiling float large";1]
testFactory["cpu read write mem"; .Q.dd[NS; `wavgFloatLarge];CPUREPEAT*20;wavg[largeVec];"wavg";largeFloatVec;"wavg float large";2]

sendTests[controller;DB;`.cpu]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i