system "l src/cpucommon.q";

NS:`.cpu

cpuTestFactory["cpu read mem"; .Q.dd[NS; `maxIntMedium];10000;max;"max";mediumVec;"max int medium";1]
cpuTestFactory["cpu read mem"; .Q.dd[NS; `medIntMedium];1000;med;"med";mediumVec;"med int medium";1]
cpuTestFactory["cpu read mem"; .Q.dd[NS; `sdevIntMedium];1000;sdev;"sdev";mediumVec;"sdev int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `permuteIntMedium];500;0N?;"0N?";mediumVec;"permute int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `sortIntMedium];500;asc;"asc";mediumVec;"sort int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `deltasIntMedium];1000;deltas;"deltas";mediumVec;"deltas int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `modWhereIntMedium];500;where 0=mod[;7]@;"where mod =";mediumVec;"where mod = int medium";1]
cpuTestFactory["cpu write mem"; .Q.dd[NS; `randIntMedium];500;MEDIUMLENGTH?;enlist "?";100;"roll int medium";MEDIUMLENGTH]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `xbarIntMedium];1000;117 xbar;"xbar";mediumVec;"xbar int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `multiplyIntMedium];5000;100*;enlist "*";mediumVec;"mult int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `divideIntMedium];1000;div[;11];"div";mediumVec;"div int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `mavgIntMedium];500;100 mavg;"mavg";mediumVec;"mavg int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `groupIntMedium];500;group;"group";mediumVec;"group int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `serializeIntMedium];2000;-9!-8!;"-9!-8!";mediumVec;"-9!-8! int medium";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `compressIntMedium];500;-18!;"-18!";mediumVec;"-18! int medium";1]


cpuTestFactory["cpu read mem"; .Q.dd[NS; `maxIntLarge];50;max;"max";largeVec;"max int large";1]
cpuTestFactory["cpu read mem"; .Q.dd[NS; `medIntLarge];1;med;"med";largeVec;"med int large";1]
cpuTestFactory["cpu read mem"; .Q.dd[NS; `sdevIntLarge];10;sdev;"sdev";largeVec;"sdev int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `permuteIntLarge];1;0N?;"0N?";largeVec;"permute int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `sortIntLarge];1;asc;"asc";largeVec;"sort int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `deltasIntLarge];10;deltas;"deltas";largeVec;"deltas int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `modWhereIntLarge];2;where 0=mod[;7]@;"where mod =";largeVec;"where mod = int large";1]
cpuTestFactory["cpu write mem"; .Q.dd[NS; `randIntLarge];10;LARGELENGTH?;enlist "?";100;"roll int large";LARGELENGTH]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `xbarIntLarge];10;117 xbar;"xbar";largeVec;"xbar int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `multiplyIntLarge];50;100*;enlist "*";largeVec;"mult int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `divideIntLarge];10;div[;11];"div";largeVec;"div int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `mavgIntLarge];1;100 mavg;"mavg";largeVec;"mavg int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `groupIntLarge];1;group;"group";largeVec;"group int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `serializeIntLarge];50;-9!-8!;"-9!-8!";largeVec;"-9!-8! int large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `compressIntLarge];5;-18!;"-18!";largeVec;"-18! int large";1]


cpuTestFactory["cpu read mem"; .Q.dd[NS; `maxFloatLarge];50;max;"max";largeFloatVec;"max float large";1]
cpuTestFactory["cpu read mem"; .Q.dd[NS; `medFloatLarge];1;med;"med";largeFloatVec;"med float large";1]
cpuTestFactory["cpu read mem"; .Q.dd[NS; `sdevFloatLarge];10;sdev;"sdev";largeFloatVec;"sdev float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `permuteLarge];1;0N?;"0N?";largeFloatVec;"permute float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `sortLarge];1;asc;"asc";largeFloatVec;"sort float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `deltasLarge];5;deltas;"deltas";largeFloatVec;"deltas float large";1]
cpuTestFactory["cpu write mem"; .Q.dd[NS; `randFloatLarge];10;LARGELENGTH?;enlist "?";100.;"roll float large";LARGELENGTH]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `xbarLarge];10;117. xbar;"xbar";largeFloatVec;"xbar float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `multiplyFloatLarge];50;100.*;enlist "*";largeFloatVec;"mult float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `divideFloatLarge];10;div[;11.];"div";largeFloatVec;"div float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `mavgFloatLarge];1;100 mavg;"mavg";largeFloatVec;"mavg float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `groupFloatLarge];1;group;"group";largeFloatVec;"group float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `serializeFloatLarge];50;-9!-8!;"-9!-8!";largeFloatVec;"-9!-8! float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `compressFloatLarge];5;-18!;"-18!";largeFloatVec;"-18! float large";1]

/ Float-only operations
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `reciprocalFloatLarge];50;reciprocal;"reciprocal";largeFloatVec;"reciprocal float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `ceilingFloatLarge];20;ceiling;"ceiling";largeFloatVec;"ceiling float large";1]
cpuTestFactory["cpu read write mem"; .Q.dd[NS; `wavgFloatLarge];20;wavg[largeVec];"wavg";largeFloatVec;"wavg float large";2]

sendTests[controller;DB;`.cpu]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i