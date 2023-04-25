ioq:"2.0"

STDOUT:-1

MEMUSAGERATE: 0.40;   // rate of the memory to be used, e.g. 40%
argvk:key argv:.Q.opt .z.x

threadcount:string `$first argv`threads
threadcount:"I"$threadcount
DB: first argv `db

tsToMsec: {floor (`long$x)%10 xexp 6}
fix:{.Q.fmt[x+1+count string floor y;x;y]}
msstring:{(string x)," ms"}

// for distributed file system with client side compression....don't use this


/ note that compression does not work with a "dot" in the filename
lrfile: hsym `$DB, "/readtest" / local read file
lwfile: hsym `$DB, "/writetest" / local write file

ffileo: hsym `$DB, "/fileopsto" / o of n local fileops test
ffile1: hsym `$DB, "/fileopst1" / 1 of n local fileops test
ffile2: hsym `$DB, "/fileopst2" / 2 of n local fileops test
ffile3: hsym `$DB, "/fileopst3" / 3 of n local fileops test
ffile4: hsym `$DB, "/fileopst4" / 4 of n local fileops test
ffile5: hsym `$DB, "/fileopst5" / 5 of n local fileops test
ffile6: hsym `$DB, "/fileopst6" / 6 of n local fileops test
ffile7: hsym `$DB, "/locktest"  / 7 of n local fileops test

k: 1024
M: k*k
SIZEOFLONG: 8

// threads are executed by multiple independent executions of io.q, via calling
// script. threadcount is used to figure out how big to make each file
// depending on the available memory
// we go high with most memory settings in cloud as this mimics customer systems
// and side-benefits by gaining more instance capability . so this is a lazy calc
//
ssm:"J"$(x where not null`$x:" "vs(system"free -b")[1])[3];
ssm:`long$(ssm-2 xexp 24)*MEMUSAGERATE;
ssm:`long$(ssm-(ssm mod 1024*1024))%threadcount;