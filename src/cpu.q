system "l src/common.q";
system "l src/samplearrays.q";

CPUREPEAT: 1^"I"$getenv `CPUREPEAT
NS:`.cpu

testFactory[writeRes["cpu read mem";;"max"]; .Q.dd[NS; `maxIntMedium];CPUREPEAT*10000;(max;mediumVec;::);"max int medium";1]
testFactory[writeRes["cpu read mem";;"med"]; .Q.dd[NS; `medIntMedium];CPUREPEAT*1000;(med;mediumVec;::);"med int medium";1]
testFactory[writeRes["cpu read mem";;"sdev"]; .Q.dd[NS; `sdevIntMedium];CPUREPEAT*1000;(sdev;mediumVec;::);"sdev int medium";1]
testFactory[writeRes["cpu read write mem";;"0N?"]; .Q.dd[NS; `permuteIntMedium];CPUREPEAT*500;(0N?;mediumVec;::);"permute int medium";1]
testFactory[writeRes["cpu read write mem";;"asc"]; .Q.dd[NS; `sortIntMedium];CPUREPEAT*500;(asc;mediumVec;::);"sort int medium";1]
testFactory[writeRes["cpu read write mem";;"deltas"]; .Q.dd[NS; `deltasIntMedium];CPUREPEAT*1000;(deltas;mediumVec;::);"deltas int medium";1]
testFactory[writeRes["cpu read write mem";;"where mod ="]; .Q.dd[NS; `modWhereIntMedium];CPUREPEAT*500;(where 0=mod[;7]@;mediumVec;::);"where mod = int medium";1]
testFactory[writeRes["cpu write mem";;"til"]; .Q.dd[NS; `tilIntMedium];CPUREPEAT*5000;(til;MEDIUMLENGTH;::);"til int medium";MEDIUMLENGTH]
testFactory[writeRes["cpu write mem";;enlist "?"]; .Q.dd[NS; `randIntMedium];CPUREPEAT*500;(MEDIUMLENGTH?;100;::);"roll int medium";MEDIUMLENGTH]
testFactory[writeRes["cpu read write mem";;"xbar"]; .Q.dd[NS; `xbarIntMedium];CPUREPEAT*1000;(117 xbar;mediumVec;::);"xbar int medium";1]
testFactory[writeRes["cpu read write mem";;enlist "*"]; .Q.dd[NS; `multiplyIntMedium];CPUREPEAT*5000;(100*;mediumVec;::);"mult int medium";1]
testFactory[writeRes["cpu read write mem";;"div"]; .Q.dd[NS; `divideIntMedium];CPUREPEAT*1000;(div[;11];mediumVec;::);"div int medium";1]
testFactory[writeRes["cpu read write mem";;"mavg"]; .Q.dd[NS; `mavgIntMedium];CPUREPEAT*500;(100 mavg;mediumVec;::);"mavg int medium";1]
testFactory[writeRes["cpu read write mem";;"group"]; .Q.dd[NS; `groupIntMedium];CPUREPEAT*500;(group;mediumVec;::);"group int medium";1]
testFactory[writeRes["cpu read write mem";;"-9!-8!"]; .Q.dd[NS; `serializeIntMedium];CPUREPEAT*2000;(-9!-8!;mediumVec;::);"-9!-8! int medium";1]
testFactory[writeRes["cpu read write mem";;"-18!"]; .Q.dd[NS; `compressIntMedium];CPUREPEAT*500;(-18!;mediumVec;::);"-18! int medium";1]


testFactory[writeRes["cpu read mem";;"max"]; .Q.dd[NS; `maxIntLarge];CPUREPEAT*50;(max;largeVec;::);"max int large";1]
testFactory[writeRes["cpu read mem";;"med"]; .Q.dd[NS; `medIntLarge];CPUREPEAT*1;(med;largeVec;::);"med int large";1]
testFactory[writeRes["cpu read mem";;"sdev"]; .Q.dd[NS; `sdevIntLarge];CPUREPEAT*10;(sdev;largeVec;::);"sdev int large";1]
testFactory[writeRes["cpu read write mem";;"0N?"]; .Q.dd[NS; `permuteIntLarge];CPUREPEAT*1;(0N?;largeVec;::);"permute int large";1]
testFactory[writeRes["cpu read write mem";;"asc"]; .Q.dd[NS; `sortIntLarge];CPUREPEAT*1;(asc;largeVec;::);"sort int large";1]
testFactory[writeRes["cpu read write mem";;"deltas"]; .Q.dd[NS; `deltasIntLarge];CPUREPEAT*10;(deltas;largeVec;::);"deltas int large";1]
testFactory[writeRes["cpu read write mem";;"where mod ="]; .Q.dd[NS; `modWhereIntLarge];CPUREPEAT*2;(where 0=mod[;7]@;largeVec;::);"where mod = int large";1]
testFactory[writeRes["cpu write mem";;"til"]; .Q.dd[NS; `tilIntLarge];CPUREPEAT*100;(til;LARGELENGTH;::);"til int large";LARGELENGTH]
testFactory[writeRes["cpu write mem";;enlist "?"]; .Q.dd[NS; `randIntLarge];CPUREPEAT*10;(LARGELENGTH?;100;::);"roll int large";LARGELENGTH]
testFactory[writeRes["cpu read write mem";;"xbar"]; .Q.dd[NS; `xbarIntLarge];CPUREPEAT*10;(117 xbar;largeVec;::);"xbar int large";1]
testFactory[writeRes["cpu read write mem";;enlist "*"]; .Q.dd[NS; `multiplyIntLarge];CPUREPEAT*50;(100*;largeVec;::);"mult int large";1]
testFactory[writeRes["cpu read write mem";;"div"]; .Q.dd[NS; `divideIntLarge];CPUREPEAT*10;(div[;11];largeVec;::);"div int large";1]
testFactory[writeRes["cpu read write mem";;"mavg"]; .Q.dd[NS; `mavgIntLarge];CPUREPEAT*1;(100 mavg;largeVec;::);"mavg int large";1]
testFactory[writeRes["cpu read write mem";;"group"]; .Q.dd[NS; `groupIntLarge];CPUREPEAT*1;(group;largeVec;::);"group int large";1]
testFactory[writeRes["cpu read write mem";;"-9!-8!"]; .Q.dd[NS; `serializeIntLarge];CPUREPEAT*50;(-9!-8!;largeVec;::);"-9!-8! int large";1]
testFactory[writeRes["cpu read write mem";;"-18!"]; .Q.dd[NS; `compressIntLarge];CPUREPEAT*5;(-18!;largeVec;::);"-18! int large";1]


testFactory[writeRes["cpu read mem";;"max"]; .Q.dd[NS; `maxFloatLarge];CPUREPEAT*50;(max;largeFloatVec;::);"max float large";1]
testFactory[writeRes["cpu read mem";;"med"]; .Q.dd[NS; `medFloatLarge];CPUREPEAT*1;(med;largeFloatVec;::);"med float large";1]
testFactory[writeRes["cpu read mem";;"sdev"]; .Q.dd[NS; `sdevFloatLarge];CPUREPEAT*10;(sdev;largeFloatVec;::);"sdev float large";1]
testFactory[writeRes["cpu read write mem";;"0N?"]; .Q.dd[NS; `permuteLarge];CPUREPEAT*1;(0N?;largeFloatVec;::);"permute float large";1]
testFactory[writeRes["cpu read write mem";;"asc"]; .Q.dd[NS; `sortLarge];CPUREPEAT*1;(asc;largeFloatVec;::);"sort float large";1]
testFactory[writeRes["cpu read write mem";;"deltas"]; .Q.dd[NS; `deltasLarge];CPUREPEAT*5;(deltas;largeFloatVec;::);"deltas float large";1]
testFactory[writeRes["cpu write mem";;enlist "?"]; .Q.dd[NS; `randFloatLarge];CPUREPEAT*10;(LARGELENGTH?;100.;::);"roll float large";LARGELENGTH]
testFactory[writeRes["cpu read write mem";;"xbar"]; .Q.dd[NS; `xbarLarge];CPUREPEAT*10;(117. xbar;largeFloatVec;::);"xbar float large";1]
testFactory[writeRes["cpu read write mem";;enlist "*";]; .Q.dd[NS; `multiplyFloatLarge];CPUREPEAT*50;(100.*;largeFloatVec;::);"mult float large";1]
testFactory[writeRes["cpu read write mem";;"div"]; .Q.dd[NS; `divideFloatLarge];CPUREPEAT*10;(div[;11.];largeFloatVec;::);"div float large";1]
testFactory[writeRes["cpu read write mem";;"mavg"]; .Q.dd[NS; `mavgFloatLarge];CPUREPEAT*1;(100 mavg;largeFloatVec;::);"mavg float large";1]
testFactory[writeRes["cpu read write mem";;"group"]; .Q.dd[NS; `groupFloatLarge];CPUREPEAT*1;(group;largeFloatVec;::);"group float large";1]
testFactory[writeRes["cpu read write mem";;"-9!-8!"]; .Q.dd[NS; `serializeFloatLarge];CPUREPEAT*50;(-9!-8!;largeFloatVec;::);"-9!-8! float large";1]
testFactory[writeRes["cpu read write mem";;"-18!"]; .Q.dd[NS; `compressFloatLarge];CPUREPEAT*5;(-18!;largeFloatVec;::);"-18! float large";1]

/ Float-only operations
testFactory[writeRes["cpu read write mem";;"reciprocal"]; .Q.dd[NS; `reciprocalFloatLarge];CPUREPEAT*50;(reciprocal;largeFloatVec;::);"reciprocal float large";1]
testFactory[writeRes["cpu read write mem";;"ceiling"]; .Q.dd[NS; `ceilingFloatLarge];CPUREPEAT*20;(ceiling;largeFloatVec;::);"ceiling float large";1]
testFactory[writeRes["cpu read write mem";;"wavg"]; .Q.dd[NS; `wavgFloatLarge];CPUREPEAT*20;(wavg[largeVec];largeFloatVec;::);"wavg float large";2]

sendTests[controller;DB;`.cpu]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i