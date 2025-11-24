system "l src/common.q";
system "l src/samplearrays.q";

CPUREPEAT: 1.^"F"$getenv `CPUREPEAT
NS:`.cpucache

testFactory[writeRes["cpu read cpu cache";;"max"]; .Q.dd[NS; `maxIntTiny];floor CPUREPEAT*2000000;(max;tinyVec;::);"max int tiny";1]
testFactory[writeRes["cpu read cpu cache";;"med"]; .Q.dd[NS; `medIntTiny];floor CPUREPEAT*200000;(med;tinyVec;::);"med int tiny";1]
testFactory[writeRes["cpu read cpu cache";;"sdev"]; .Q.dd[NS; `sdevIntTiny];floor CPUREPEAT*500000;(sdev;tinyVec;::);"sdev int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"0N?"]; .Q.dd[NS; `permuteIntTiny];floor CPUREPEAT*100000;(0N?;tinyVec;::);"permute int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"asc"]; .Q.dd[NS; `sortIntTiny];floor CPUREPEAT*100000;(asc;tinyVec;::);"sort int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"deltas"]; .Q.dd[NS; `deltasIntTiny];floor CPUREPEAT*1000000;(deltas;tinyVec;::);"deltas int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"where mod ="]; .Q.dd[NS; `modWhereIntTiny];floor CPUREPEAT*100000;(where 0=mod[;7]@;tinyVec;::);"where mod = int tiny";1]
testFactory[writeRes["cpu write cpu cache";;"til"]; .Q.dd[NS; `tilIntTiny];floor CPUREPEAT*1000000;(til;TINYLENGTH;::);"til int tiny";TINYLENGTH]
testFactory[writeRes["cpu write cpu cache";;enlist "?"]; .Q.dd[NS; `randIntTiny];floor CPUREPEAT*100000;(TINYLENGTH?;100;::);"roll int tiny";TINYLENGTH]
testFactory[writeRes["cpu read write cpu cache";;"xbar"]; .Q.dd[NS; `xbarIntTiny];floor CPUREPEAT*200000;(117 xbar;tinyVec;::);"xbar int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;enlist "*"]; .Q.dd[NS; `multiplyIntTiny];floor CPUREPEAT*2000000;(100*;tinyVec;::);"mult int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"div"]; .Q.dd[NS; `divideIntTiny];floor CPUREPEAT*200000;(div[;11];tinyVec;::);"div int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"mavg"]; .Q.dd[NS; `mavgIntTiny];floor CPUREPEAT*100000;(100 mavg;tinyVec;::);"mavg int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"group"]; .Q.dd[NS; `groupIntTiny];floor CPUREPEAT*100000;(group;tinyVec;::);"group int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"-9!-8!"]; .Q.dd[NS; `serializeIntTiny];floor CPUREPEAT*1000000;(-9!-8!;tinyVec;::);"-9!-8! int tiny";1]
testFactory[writeRes["cpu read write cpu cache";;"-18!"]; .Q.dd[NS; `compressIntTiny];floor CPUREPEAT*200000;(-18!;tinyVec;::);"-18! int tiny";1]


testFactory[writeRes["cpu read cpu cache";;"max"]; .Q.dd[NS; `maxIntSmall];floor CPUREPEAT*100000;(max;smallVec;::);"max int small";1]
testFactory[writeRes["cpu read cpu cache";;"med"]; .Q.dd[NS; `medIntSmall];floor CPUREPEAT*10000;(med;smallVec;::);"med int small";1]
testFactory[writeRes["cpu read cpu cache";;"sdev"]; .Q.dd[NS; `sdevIntSmall];floor CPUREPEAT*10000;(sdev;smallVec;::);"sdev int small";1]
testFactory[writeRes["cpu read write cpu cache";;"0N?"]; .Q.dd[NS; `permuteIntSmall];floor CPUREPEAT*5000;(0N?;smallVec;::);"permute int small";1]
testFactory[writeRes["cpu read write cpu cache";;"asc"]; .Q.dd[NS; `sortIntSmall];floor CPUREPEAT*5000;(asc;smallVec;::);"sort int small";1]
testFactory[writeRes["cpu read write cpu cache";;"deltas"]; .Q.dd[NS; `deltasIntSmall];floor CPUREPEAT*20000;(deltas;smallVec;::);"deltas int small";1]
testFactory[writeRes["cpu read write cpu cache";;"where mod ="]; .Q.dd[NS; `modWhereIntSmall];floor CPUREPEAT*5000;(where 0=mod[;7]@;smallVec;::);"where mod = int small";1]
testFactory[writeRes["cpu write cpu cache";;"til"]; .Q.dd[NS; `tilIntSmall];floor CPUREPEAT*50000;(til;SMALLLENGTH;::);"til int small";SMALLLENGTH]
testFactory[writeRes["cpu write cpu cache";;enlist "?"]; .Q.dd[NS; `randIntSmall];floor CPUREPEAT*5000;(SMALLLENGTH?;100;::);"roll int small";SMALLLENGTH]
testFactory[writeRes["cpu read write cpu cache";;"xbar"]; .Q.dd[NS; `xbarIntSmall];floor CPUREPEAT*10000;(117 xbar;smallVec;::);"xbar int small";1]
testFactory[writeRes["cpu read write cpu cache";;enlist "*"]; .Q.dd[NS; `multiplyIntSmall];floor CPUREPEAT*50000;(100*;smallVec;::);"mult int small";1]
testFactory[writeRes["cpu read write cpu cache";;"div"]; .Q.dd[NS; `divideIntSmall];floor CPUREPEAT*10000;(div[;11];smallVec;::);"div int small";1]
testFactory[writeRes["cpu read write cpu cache";;"mavg"]; .Q.dd[NS; `mavgIntSmall];floor CPUREPEAT*5000;(100 mavg;smallVec;::);"mavg int small";1]
testFactory[writeRes["cpu read write cpu cache";;"group"]; .Q.dd[NS; `groupIntSmall];floor CPUREPEAT*5000;(group;smallVec;::);"group int small";1]
testFactory[writeRes["cpu read write cpu cache";;"-9!-8!"]; .Q.dd[NS; `serializeIntSmall];floor CPUREPEAT*20000;(-9!-8!;smallVec;::);"-9!-8! int small";1]
testFactory[writeRes["cpu read write cpu cache";;"-18!"]; .Q.dd[NS; `compressIntSmall];floor CPUREPEAT*5000;(-18!;smallVec;::);"-18! int small";1]

sendTests[controller;DB;NS]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i