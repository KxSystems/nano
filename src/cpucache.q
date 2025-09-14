system "l src/common.q";
system "l src/samplearrays.q";

CPUREPEAT: 1^"I"$getenv `CPUREPEAT
NS:`.cpucache

testFactory["cpu read cpu cache"; .Q.dd[NS; `maxIntTiny];CPUREPEAT*2000000;max;"max";tinyVec;"max int tiny";1]
testFactory["cpu read cpu cache"; .Q.dd[NS; `medIntTiny];CPUREPEAT*200000;med;"med";tinyVec;"med int tiny";1]
testFactory["cpu read cpu cache"; .Q.dd[NS; `sdevIntTiny];CPUREPEAT*500000;sdev;"sdev";tinyVec;"sdev int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `permuteIntTiny];CPUREPEAT*100000;0N?;"0N?";tinyVec;"permute int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `sortIntTiny];CPUREPEAT*100000;asc;"asc";tinyVec;"sort int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `deltasIntTiny];CPUREPEAT*1000000;deltas;"deltas";tinyVec;"deltas int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `modWhereIntTiny];CPUREPEAT*100000;where 0=mod[;7]@;"where mod =";tinyVec;"where mod = int tiny";1]
testFactory["cpu write cpu cache"; .Q.dd[NS; `tilIntTiny];CPUREPEAT*1000000;til;"til";TINYLENGTH;"til int tiny";TINYLENGTH]
testFactory["cpu write cpu cache"; .Q.dd[NS; `randIntTiny];CPUREPEAT*100000;TINYLENGTH?;enlist "?";100;"roll int tiny";TINYLENGTH]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `xbarIntTiny];CPUREPEAT*200000;117 xbar;"xbar";tinyVec;"xbar int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `multiplyIntTiny];CPUREPEAT*2000000;100*;enlist "*";tinyVec;"mult int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `divideIntTiny];CPUREPEAT*200000;div[;11];"div";tinyVec;"div int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `mavgIntTiny];CPUREPEAT*100000;100 mavg;"mavg";tinyVec;"mavg int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `groupIntTiny];CPUREPEAT*100000;group;"group";tinyVec;"group int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `serializeIntTiny];CPUREPEAT*1000000;-9!-8!;"-9!-8!";tinyVec;"-9!-8! int tiny";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `compressIntTiny];CPUREPEAT*200000;-18!;"-18!";tinyVec;"-18! int tiny";1]


testFactory["cpu read cpu cache"; .Q.dd[NS; `maxIntSmall];CPUREPEAT*100000;max;"max";smallVec;"max int small";1]
testFactory["cpu read cpu cache"; .Q.dd[NS; `medIntSmall];CPUREPEAT*10000;med;"med";smallVec;"med int small";1]
testFactory["cpu read cpu cache"; .Q.dd[NS; `sdevIntSmall];CPUREPEAT*10000;sdev;"sdev";smallVec;"sdev int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `permuteIntSmall];CPUREPEAT*5000;0N?;"0N?";smallVec;"permute int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `sortIntSmall];CPUREPEAT*5000;asc;"asc";smallVec;"sort int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `deltasIntSmall];CPUREPEAT*20000;deltas;"deltas";smallVec;"deltas int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `modWhereIntSmall];CPUREPEAT*5000;where 0=mod[;7]@;"where mod =";smallVec;"where mod = int small";1]
testFactory["cpu write cpu cache"; .Q.dd[NS; `tilIntSmall];CPUREPEAT*50000;til;"til";SMALLLENGTH;"til int small";SMALLLENGTH]
testFactory["cpu write cpu cache"; .Q.dd[NS; `randIntSmall];CPUREPEAT*5000;SMALLLENGTH?;enlist "?";100;"roll int small";SMALLLENGTH]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `xbarIntSmall];CPUREPEAT*10000;117 xbar;"xbar";smallVec;"xbar int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `multiplyIntSmall];CPUREPEAT*50000;100*;enlist "*";smallVec;"mult int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `divideIntSmall];CPUREPEAT*10000;div[;11];"div";smallVec;"div int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `mavgIntSmall];CPUREPEAT*5000;100 mavg;"mavg";smallVec;"mavg int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `groupIntSmall];CPUREPEAT*5000;group;"group";smallVec;"group int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `serializeIntSmall];CPUREPEAT*20000;-9!-8!;"-9!-8!";smallVec;"-9!-8! int small";1]
testFactory["cpu read write cpu cache"; .Q.dd[NS; `compressIntSmall];CPUREPEAT*5000;-18!;"-18!";smallVec;"-18! int small";1]

sendTests[controller;DB;NS]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i