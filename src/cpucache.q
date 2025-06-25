system "l src/cpucommon.q";

NS:`.cpucache

cpuTestFactory["cpu read cpu cache"; .Q.dd[NS; `maxIntTiny];2000000;max;"max";tinyVec;"max int tiny";1]
cpuTestFactory["cpu read cpu cache"; .Q.dd[NS; `medIntTiny];200000;med;"med";tinyVec;"med int tiny";1]
cpuTestFactory["cpu read cpu cache"; .Q.dd[NS; `sdevIntTiny];500000;sdev;"sdev";tinyVec;"sdev int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `permuteIntTiny];100000;0N?;"0N?";tinyVec;"permute int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `sortIntTiny];100000;asc;"asc";tinyVec;"sort int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `deltasIntTiny];1000000;deltas;"deltas";tinyVec;"deltas int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `modWhereIntTiny];100000;where 0=mod[;7]@;"where mod =";tinyVec;"where mod = int tiny";1]
cpuTestFactory["cpu write cpu cache"; .Q.dd[NS; `randIntTiny];100000;TINYLENGTH?;enlist "?";100;"roll int tiny";TINYLENGTH]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `xbarIntTiny];200000;117 xbar;"xbar";tinyVec;"xbar int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `multiplyIntTiny];2000000;100*;enlist "*";tinyVec;"mult int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `divideIntTiny];200000;div[;11];"div";tinyVec;"div int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `mavgIntTiny];100000;100 mavg;"mavg";tinyVec;"mavg int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `groupIntTiny];100000;group;"group";tinyVec;"group int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `serializeIntTiny];1000000;-9!-8!;"-9!-8!";tinyVec;"-9!-8! int tiny";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `compressIntTiny];200000;-18!;"-18!";tinyVec;"-18! int tiny";1]


cpuTestFactory["cpu read cpu cache"; .Q.dd[NS; `maxIntSmall];100000;max;"max";smallVec;"max int small";1]
cpuTestFactory["cpu read cpu cache"; .Q.dd[NS; `medIntSmall];10000;med;"med";smallVec;"med int small";1]
cpuTestFactory["cpu read cpu cache"; .Q.dd[NS; `sdevIntSmall];10000;sdev;"sdev";smallVec;"sdev int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `permuteIntSmall];5000;0N?;"0N?";smallVec;"permute int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `sortIntSmall];5000;asc;"asc";smallVec;"sort int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `deltasIntSmall];20000;deltas;"deltas";smallVec;"deltas int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `modWhereIntSmall];5000;where 0=mod[;7]@;"where mod =";smallVec;"where mod = int small";1]
cpuTestFactory["cpu write cpu cache"; .Q.dd[NS; `randIntSmall];5000;SMALLLENGTH?;enlist "?";100;"roll int small";SMALLLENGTH]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `xbarIntSmall];10000;117 xbar;"xbar";smallVec;"xbar int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `multiplyIntSmall];50000;100*;enlist "*";smallVec;"mult int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `divideIntSmall];10000;div[;11];"div";smallVec;"div int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `mavgIntSmall];5000;100 mavg;"mavg";smallVec;"mavg int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `groupIntSmall];5000;group;"group";smallVec;"group int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `serializeIntSmall];20000;-9!-8!;"-9!-8!";smallVec;"-9!-8! int small";1]
cpuTestFactory["cpu read write cpu cache"; .Q.dd[NS; `compressIntSmall];5000;-18!;"-18!";smallVec;"-18! int small";1]

sendTests[controller;DB;NS]

.qlog.info "Worker is ready for test execution. Pid: ", string .z.i