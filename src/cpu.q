system "l src/common.q";
system "l src/samplearrays.q";


cpuTestFactory: {[testtype:`C;testID:`s;N:`j;fn;qexpr;param;test:`C;mult:`j]
  testid: .Q.dd[`.cpu; testID];
  writerFn: writeRes[testtype;;qexpr];
  testid set {[writerFn;testid;N;fn;param;test;mult;dontcare] / the namespaced testID is the function name
    .qlog.info "starting test ", test;
    sT: .z.n;
    do[N;fn param];
    eT: .z.n;
    writerFn[testid,"|",test; N; count param; sT, eT; fix[2; getMBPerSec[mult*N*count param; eT-sT]]; "MB/sec\n"];
    }[writerFn;string testid;N;fn;param;test;mult];
  }


///////////// Tiny vector Tests

cpuTestFactory["cpu read mem"; `maxIntTiny;2000000;max;"max";tinyVec;"max int tiny";1]
cpuTestFactory["cpu read mem"; `medIntTiny;200000;med;"med";tinyVec;"med int tiny";1]
cpuTestFactory["cpu read mem"; `sdevIntTiny;500000;sdev;"sdev";tinyVec;"sdev int tiny";1]
cpuTestFactory["cpu read write mem"; `permuteIntTiny;100000;0N?;"0N?";tinyVec;"permute int tiny";1]
cpuTestFactory["cpu read write mem"; `sortIntTiny;100000;asc;"asc";tinyVec;"sort int tiny";1]
cpuTestFactory["cpu read write mem"; `deltasIntTiny;1000000;deltas;"deltas";tinyVec;"deltas int tiny";1]
cpuTestFactory["cpu read write mem"; `modWhereIntTiny;100000;where 0=mod[;7]@;"where mod =";tinyVec;"where mod = int tiny";1]
cpuTestFactory["cpu write mem"; `randIntTiny;100000;TINYLENGTH?;enlist "?";100;"roll int tiny";TINYLENGTH]
cpuTestFactory["cpu read write mem"; `xbarIntTiny;200000;117 xbar;"xbar";tinyVec;"xbar int tiny";1]
cpuTestFactory["cpu read write mem"; `multiplyIntTiny;2000000;100*;enlist "*";tinyVec;"mult int tiny";1]
cpuTestFactory["cpu read write mem"; `divideIntTiny;200000;div[;11];"div";tinyVec;"div int tiny";1]
cpuTestFactory["cpu read write mem"; `mavgIntTiny;100000;100 mavg;"mavg";tinyVec;"mavg int tiny";1]
cpuTestFactory["cpu read write mem"; `groupIntTiny;100000;group;"group";tinyVec;"group int tiny";1]
cpuTestFactory["cpu read write mem"; `serializeIntTiny;1000000;-9!-8!;"-9!-8!";tinyVec;"-9!-8! int tiny";1]
cpuTestFactory["cpu read write mem"; `compressIntTiny;200000;-18!;"-18!";tinyVec;"-18! int tiny";1]


cpuTestFactory["cpu read mem"; `maxIntSmall;100000;max;"max";smallVec;"max int small";1]
cpuTestFactory["cpu read mem"; `medIntSmall;10000;med;"med";smallVec;"med int small";1]
cpuTestFactory["cpu read mem"; `sdevIntSmall;10000;sdev;"sdev";smallVec;"sdev int small";1]
cpuTestFactory["cpu read write mem"; `permuteIntSmall;5000;0N?;"0N?";smallVec;"permute int small";1]
cpuTestFactory["cpu read write mem"; `sortIntSmall;5000;asc;"asc";smallVec;"sort int small";1]
cpuTestFactory["cpu read write mem"; `deltasIntSmall;20000;deltas;"deltas";smallVec;"deltas int small";1]
cpuTestFactory["cpu read write mem"; `modWhereIntSmall;5000;where 0=mod[;7]@;"where mod =";smallVec;"where mod = int small";1]
cpuTestFactory["cpu write mem"; `randIntSmall;5000;SMALLLENGTH?;enlist "?";100;"roll int small";SMALLLENGTH]
cpuTestFactory["cpu read write mem"; `xbarIntSmall;10000;117 xbar;"xbar";smallVec;"xbar int small";1]
cpuTestFactory["cpu read write mem"; `multiplyIntSmall;50000;100*;enlist "*";smallVec;"mult int small";1]
cpuTestFactory["cpu read write mem"; `divideIntSmall;10000;div[;11];"div";smallVec;"div int small";1]
cpuTestFactory["cpu read write mem"; `mavgIntSmall;5000;100 mavg;"mavg";smallVec;"mavg int small";1]
cpuTestFactory["cpu read write mem"; `groupIntSmall;5000;group;"group";smallVec;"group int small";1]
cpuTestFactory["cpu read write mem"; `serializeIntSmall;20000;-9!-8!;"-9!-8!";smallVec;"-9!-8! int small";1]
cpuTestFactory["cpu read write mem"; `compressIntSmall;5000;-18!;"-18!";smallVec;"-18! int small";1]


cpuTestFactory["cpu read mem"; `maxIntMedium;10000;max;"max";mediumVec;"max int medium";1]
cpuTestFactory["cpu read mem"; `medIntMedium;1000;med;"med";mediumVec;"med int medium";1]
cpuTestFactory["cpu read mem"; `sdevIntMedium;1000;sdev;"sdev";mediumVec;"sdev int medium";1]
cpuTestFactory["cpu read write mem"; `permuteIntMedium;500;0N?;"0N?";mediumVec;"permute int medium";1]
cpuTestFactory["cpu read write mem"; `sortIntMedium;500;asc;"asc";mediumVec;"sort int medium";1]
cpuTestFactory["cpu read write mem"; `deltasIntMedium;1000;deltas;"deltas";mediumVec;"deltas int medium";1]
cpuTestFactory["cpu read write mem"; `modWhereIntMedium;500;where 0=mod[;7]@;"where mod =";mediumVec;"where mod = int medium";1]
cpuTestFactory["cpu write mem"; `randIntMedium;500;MEDIUMLENGTH?;enlist "?";100;"roll int medium";MEDIUMLENGTH]
cpuTestFactory["cpu read write mem"; `xbarIntMedium;1000;117 xbar;"xbar";mediumVec;"xbar int medium";1]
cpuTestFactory["cpu read write mem"; `multiplyIntMedium;5000;100*;enlist "*";mediumVec;"mult int medium";1]
cpuTestFactory["cpu read write mem"; `divideIntMedium;1000;div[;11];"div";mediumVec;"div int medium";1]
cpuTestFactory["cpu read write mem"; `mavgIntMedium;500;100 mavg;"mavg";mediumVec;"mavg int medium";1]
cpuTestFactory["cpu read write mem"; `groupIntMedium;500;group;"group";mediumVec;"group int medium";1]
cpuTestFactory["cpu read write mem"; `serializeIntMedium;2000;-9!-8!;"-9!-8!";mediumVec;"-9!-8! int medium";1]
cpuTestFactory["cpu read write mem"; `compressIntMedium;500;-18!;"-18!";mediumVec;"-18! int medium";1]


cpuTestFactory["cpu read mem"; `maxIntLarge;50;max;"max";largeVec;"max int large";1]
cpuTestFactory["cpu read mem"; `medIntLarge;1;med;"med";largeVec;"med int large";1]
cpuTestFactory["cpu read mem"; `sdevIntLarge;10;sdev;"sdev";largeVec;"sdev int large";1]
cpuTestFactory["cpu read write mem"; `permuteIntLarge;1;0N?;"0N?";largeVec;"permute int large";1]
cpuTestFactory["cpu read write mem"; `sortIntLarge;1;asc;"asc";largeVec;"sort int large";1]
cpuTestFactory["cpu read write mem"; `deltasIntLarge;10;deltas;"deltas";largeVec;"deltas int large";1]
cpuTestFactory["cpu read write mem"; `modWhereIntLarge;2;where 0=mod[;7]@;"where mod =";largeVec;"where mod = int large";1]
cpuTestFactory["cpu write mem"; `randIntLarge;10;LARGELENGTH?;enlist "?";100;"roll int large";LARGELENGTH]
cpuTestFactory["cpu read write mem"; `xbarIntLarge;10;117 xbar;"xbar";largeVec;"xbar int large";1]
cpuTestFactory["cpu read write mem"; `multiplyIntLarge;50;100*;enlist "*";largeVec;"mult int large";1]
cpuTestFactory["cpu read write mem"; `divideIntLarge;10;div[;11];"div";largeVec;"div int large";1]
cpuTestFactory["cpu read write mem"; `mavgIntLarge;1;100 mavg;"mavg";largeVec;"mavg int large";1]
cpuTestFactory["cpu read write mem"; `groupIntLarge;1;group;"group";largeVec;"group int large";1]
cpuTestFactory["cpu read write mem"; `serializeIntLarge;50;-9!-8!;"-9!-8!";largeVec;"-9!-8! int large";1]
cpuTestFactory["cpu read write mem"; `compressIntLarge;5;-18!;"-18!";largeVec;"-18! int large";1]


cpuTestFactory["cpu read mem"; `maxFloatLarge;50;max;"max";largeFloatVec;"max float large";1]
cpuTestFactory["cpu read mem"; `medFloatLarge;1;med;"med";largeFloatVec;"med float large";1]
cpuTestFactory["cpu read mem"; `sdevFloatLarge;10;sdev;"sdev";largeFloatVec;"sdev float large";1]
cpuTestFactory["cpu read write mem"; `permuteLarge;1;0N?;"0N?";largeFloatVec;"permute float large";1]
cpuTestFactory["cpu read write mem"; `sortLarge;1;asc;"asc";largeFloatVec;"sort float large";1]
cpuTestFactory["cpu read write mem"; `deltasLarge;5;deltas;"deltas";largeFloatVec;"deltas float large";1]
cpuTestFactory["cpu write mem"; `randFloatLarge;10;LARGELENGTH?;enlist "?";100.;"roll float large";LARGELENGTH]
cpuTestFactory["cpu read write mem"; `xbarLarge;10;117. xbar;"xbar";largeFloatVec;"xbar float large";1]
cpuTestFactory["cpu read write mem"; `multiplyFloatLarge;50;100.*;enlist "*";largeFloatVec;"mult float large";1]
cpuTestFactory["cpu read write mem"; `divideFloatLarge;10;div[;11.];"div";largeFloatVec;"div float large";1]
cpuTestFactory["cpu read write mem"; `mavgFloatLarge;1;100 mavg;"mavg";largeFloatVec;"mavg float large";1]
cpuTestFactory["cpu read write mem"; `groupFloatLarge;1;group;"group";largeFloatVec;"group float large";1]
cpuTestFactory["cpu read write mem"; `serializeFloatLarge;50;-9!-8!;"-9!-8!";largeFloatVec;"-9!-8! float large";1]
cpuTestFactory["cpu read write mem"; `compressFloatLarge;5;-18!;"-18!";largeFloatVec;"-18! float large";1]

/ Float-only operations
cpuTestFactory["cpu read write mem"; `reciprocalFloatLarge;50;reciprocal;"reciprocal";largeFloatVec;"reciprocal float large";1]
cpuTestFactory["cpu read write mem"; `ceilingFloatLarge;20;ceiling;"ceiling";largeFloatVec;"ceiling float large";1]
cpuTestFactory["cpu read write mem"; `wavgFloatLarge;20;wavg[largeVec];"wavg";largeFloatVec;"wavg float large";2]

sendTests[controller;DB;`.cpu]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i