system "l src/common.q";
system "l src/samplearrays.q";

CPUREPEAT: 1.^"F"$getenv `CPUREPEAT
NS:`.cpu

testFactory[writeRes["cpu read mem";;"max"]; .Q.dd[NS; `maxIntMedium];floor CPUREPEAT*10000;(max;mediumVec;::);"max int medium";1]
testFactory[writeRes["cpu read mem";;"med"]; .Q.dd[NS; `medIntMedium];floor CPUREPEAT*1000;(med;mediumVec;::);"med int medium";1]
testFactory[writeRes["cpu read mem";;"sdev"]; .Q.dd[NS; `sdevIntMedium];floor CPUREPEAT*1000;(sdev;mediumVec;::);"sdev int medium";1]
testFactory[writeRes["cpu read write mem";;"0N?"]; .Q.dd[NS; `permuteIntMedium];floor CPUREPEAT*500;(0N?;mediumVec;::);"permute int medium";1]
testFactory[writeRes["cpu read write mem";;"asc"]; .Q.dd[NS; `sortIntMedium];floor CPUREPEAT*500;(asc;mediumVec;::);"sort int medium";1]
testFactory[writeRes["cpu read write mem";;"deltas"]; .Q.dd[NS; `deltasIntMedium];floor CPUREPEAT*1000;(deltas;mediumVec;::);"deltas int medium";1]
testFactory[writeRes["cpu read write mem";;"where mod ="]; .Q.dd[NS; `modWhereIntMedium];floor CPUREPEAT*500;(where 0=mod[;7]@;mediumVec;::);"where mod = int medium";1]
testFactory[writeRes["cpu write mem";;"til"]; .Q.dd[NS; `tilIntMedium];floor CPUREPEAT*5000;(til;MEDIUMLENGTH;::);"til int medium";MEDIUMLENGTH]
testFactory[writeRes["cpu write mem";;enlist "?"]; .Q.dd[NS; `randIntMedium];floor CPUREPEAT*500;(MEDIUMLENGTH?;100;::);"roll int medium";MEDIUMLENGTH]
testFactory[writeRes["cpu read write mem";;"xbar"]; .Q.dd[NS; `xbarIntMedium];floor CPUREPEAT*1000;(117 xbar;mediumVec;::);"xbar int medium";1]
testFactory[writeRes["cpu read write mem";;enlist "*"]; .Q.dd[NS; `multiplyIntMedium];floor CPUREPEAT*5000;(100*;mediumVec;::);"mult int medium";1]
testFactory[writeRes["cpu read write mem";;"div"]; .Q.dd[NS; `divideIntMedium];floor CPUREPEAT*1000;(div[;11];mediumVec;::);"div int medium";1]
testFactory[writeRes["cpu read write mem";;"mavg"]; .Q.dd[NS; `mavgIntMedium];floor CPUREPEAT*500;(100 mavg;mediumVec;::);"mavg int medium";1]
testFactory[writeRes["cpu read write mem";;"group"]; .Q.dd[NS; `groupIntMedium];floor CPUREPEAT*500;(group;mediumVec;::);"group int medium";1]
testFactory[writeRes["cpu read write mem";;"-9!-8!"]; .Q.dd[NS; `serializeIntMedium];floor CPUREPEAT*2000;(-9!-8!;mediumVec;::);"-9!-8! int medium";1]
testFactory[writeRes["cpu read write mem";;"-18!"]; .Q.dd[NS; `compressIntMedium];floor CPUREPEAT*500;(-18!;mediumVec;::);"-18! int medium";1]


testFactory[writeRes["cpu read mem";;"max"]; .Q.dd[NS; `maxIntLarge];floor CPUREPEAT*50;(max;largeVec;::);"max int large";1]
testFactory[writeRes["cpu read mem";;"med"]; .Q.dd[NS; `medIntLarge];floor CPUREPEAT*1;(med;largeVec;::);"med int large";1]
testFactory[writeRes["cpu read mem";;"sdev"]; .Q.dd[NS; `sdevIntLarge];floor CPUREPEAT*10;(sdev;largeVec;::);"sdev int large";1]
testFactory[writeRes["cpu read write mem";;"0N?"]; .Q.dd[NS; `permuteIntLarge];floor CPUREPEAT*1;(0N?;largeVec;::);"permute int large";1]
testFactory[writeRes["cpu read write mem";;"asc"]; .Q.dd[NS; `sortIntLarge];floor CPUREPEAT*1;(asc;largeVec;::);"sort int large";1]
testFactory[writeRes["cpu read write mem";;"deltas"]; .Q.dd[NS; `deltasIntLarge];floor CPUREPEAT*10;(deltas;largeVec;::);"deltas int large";1]
testFactory[writeRes["cpu read write mem";;"where mod ="]; .Q.dd[NS; `modWhereIntLarge];floor CPUREPEAT*2;(where 0=mod[;7]@;largeVec;::);"where mod = int large";1]
testFactory[writeRes["cpu write mem";;"til"]; .Q.dd[NS; `tilIntLarge];floor CPUREPEAT*100;(til;LARGELENGTH;::);"til int large";LARGELENGTH]
testFactory[writeRes["cpu write mem";;enlist "?"]; .Q.dd[NS; `randIntLarge];floor CPUREPEAT*10;(LARGELENGTH?;100;::);"roll int large";LARGELENGTH]
testFactory[writeRes["cpu read write mem";;"xbar"]; .Q.dd[NS; `xbarIntLarge];floor CPUREPEAT*10;(117 xbar;largeVec;::);"xbar int large";1]
testFactory[writeRes["cpu read write mem";;enlist "*"]; .Q.dd[NS; `multiplyIntLarge];floor CPUREPEAT*50;(100*;largeVec;::);"mult int large";1]
testFactory[writeRes["cpu read write mem";;"div"]; .Q.dd[NS; `divideIntLarge];floor CPUREPEAT*10;(div[;11];largeVec;::);"div int large";1]
testFactory[writeRes["cpu read write mem";;"mavg"]; .Q.dd[NS; `mavgIntLarge];floor CPUREPEAT*1;(100 mavg;largeVec;::);"mavg int large";1]
testFactory[writeRes["cpu read write mem";;"group"]; .Q.dd[NS; `groupIntLarge];floor CPUREPEAT*1;(group;largeVec;::);"group int large";1]
testFactory[writeRes["cpu read write mem";;"-9!-8!"]; .Q.dd[NS; `serializeIntLarge];floor CPUREPEAT*50;(-9!-8!;largeVec;::);"-9!-8! int large";1]
testFactory[writeRes["cpu read write mem";;"-18!"]; .Q.dd[NS; `compressIntLarge];floor CPUREPEAT*5;(-18!;largeVec;::);"-18! int large";1]


testFactory[writeRes["cpu read mem";;"max"]; .Q.dd[NS; `maxFloatLarge];floor CPUREPEAT*50;(max;largeFloatVec;::);"max float large";1]
testFactory[writeRes["cpu read mem";;"med"]; .Q.dd[NS; `medFloatLarge];floor CPUREPEAT*1;(med;largeFloatVec;::);"med float large";1]
testFactory[writeRes["cpu read mem";;"sdev"]; .Q.dd[NS; `sdevFloatLarge];floor CPUREPEAT*10;(sdev;largeFloatVec;::);"sdev float large";1]
testFactory[writeRes["cpu read write mem";;"0N?"]; .Q.dd[NS; `permuteLarge];floor CPUREPEAT*1;(0N?;largeFloatVec;::);"permute float large";1]
testFactory[writeRes["cpu read write mem";;"asc"]; .Q.dd[NS; `sortLarge];floor CPUREPEAT*1;(asc;largeFloatVec;::);"sort float large";1]
testFactory[writeRes["cpu read write mem";;"deltas"]; .Q.dd[NS; `deltasLarge];floor CPUREPEAT*5;(deltas;largeFloatVec;::);"deltas float large";1]
testFactory[writeRes["cpu write mem";;enlist "?"]; .Q.dd[NS; `randFloatLarge];floor CPUREPEAT*10;(LARGELENGTH?;100.;::);"roll float large";LARGELENGTH]
testFactory[writeRes["cpu read write mem";;"xbar"]; .Q.dd[NS; `xbarLarge];floor CPUREPEAT*10;(117. xbar;largeFloatVec;::);"xbar float large";1]
testFactory[writeRes["cpu read write mem";;enlist "*";]; .Q.dd[NS; `multiplyFloatLarge];floor CPUREPEAT*50;(100.*;largeFloatVec;::);"mult float large";1]
testFactory[writeRes["cpu read write mem";;"div"]; .Q.dd[NS; `divideFloatLarge];floor CPUREPEAT*10;(div[;11.];largeFloatVec;::);"div float large";1]
testFactory[writeRes["cpu read write mem";;"mavg"]; .Q.dd[NS; `mavgFloatLarge];floor CPUREPEAT*1;(100 mavg;largeFloatVec;::);"mavg float large";1]
testFactory[writeRes["cpu read write mem";;"group"]; .Q.dd[NS; `groupFloatLarge];floor CPUREPEAT*1;(group;largeFloatVec;::);"group float large";1]
testFactory[writeRes["cpu read write mem";;"-9!-8!"]; .Q.dd[NS; `serializeFloatLarge];floor CPUREPEAT*50;(-9!-8!;largeFloatVec;::);"-9!-8! float large";1]
testFactory[writeRes["cpu read write mem";;"-18!"]; .Q.dd[NS; `compressFloatLarge];floor CPUREPEAT*5;(-18!;largeFloatVec;::);"-18! float large";1]

/ Float-only operations
testFactory[writeRes["cpu read write mem";;"reciprocal"]; .Q.dd[NS; `reciprocalFloatLarge];floor CPUREPEAT*50;(reciprocal;largeFloatVec;::);"reciprocal float large";1]
testFactory[writeRes["cpu read write mem";;"ceiling"]; .Q.dd[NS; `ceilingFloatLarge];floor CPUREPEAT*20;(ceiling;largeFloatVec;::);"ceiling float large";1]
testFactory[writeRes["cpu read write mem";;"wavg"]; .Q.dd[NS; `wavgFloatLarge];floor CPUREPEAT*20;(wavg[largeVec];largeFloatVec;::);"wavg float large";2]

sendTests[controller;DB;`.cpu]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i