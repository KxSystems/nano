ioq:"1.15"
/ Copyright Kx Systems 2017
/ q io.q [-read] [-meta] [-reread] [-random1m] [-random1m-u] [-random64k] [-random64k-u] [-prepare] [-cleanup] [-compress] [-threads] / hardware timings 
STDOUT:-1
if[0=count .z.x;STDOUT">q ",(string .z.f)," -prepare -read -meta -reread -random1m|-random64k|-random64k-u|random1m-u -compress -cleanup -threads N -rl remotelocation";exit 1]
argvk:key argv:.Q.opt .z.x
PREPARE:`prepare in argvk
CLEANUP:`cleanup in argvk
FLUSH:`flush in argvk
COMPRESS:`compress in argvk
THREADS:`threads in argvk
RUNREAD:`read in argvk
REREAD:`reread in argvk
RUNMETA:`meta in argvk
RANDOMREAD1M:`random1m in argvk
RANDOMREAD1MU:`random1mu in argvk
RANDOMREAD64K:`random64k in argvk
RANDOMREAD64KU:`random64ku in argvk
ffileo:`:fileopsto / o of n local fileops test
ffile1:`:fileopst1 / 1 of n local fileops test
ffile2:`:fileopst2 / 2 of n local fileops test
ffile3:`:fileopst3 / 3 of n local fileops test
ffile4:`:fileopst4 / 4 of n local fileops test
ffile5:`:fileopst5 / 5 of n local fileops test
ffile6:`:fileopst6 / 6 of n local fileops test
ffile7:`:locktest / 7 of n local fileops test

/ note that compression does not work with a "dot" in the filename
lrfile:`:readtest / local read file
lwfile:`:writetest / local write file
threadcount:string `$first argv`threads
threadcount:"I"$threadcount
msstring:{(string x)," ms"}

// threads are executed by multiple independent executions of io.q, via calling
// script. threadcount is used to figure out how big to make each file
// depending on the available memory
// we go high with most memory settings in cloud as this mimics customer systems
// and side-benefits by gaining more instance capability . so this is a lazy calc
//
ssm:"J"$(x where not null`$x:" "vs(system"free -b")[1])[3];
ssm:(ssm-2 xexp 21)*0.40;
ssm:`long$(ssm-(ssm mod 1024*1024))%threadcount;
/ 8 bytes in a word (64bit version of kdb+ only)
SAMPLESIZE:`long$ssm%8
WSAMPLESIZE:`long$ssm%16
random:71777214294589695;

/ throw a list of longs into shared mem prior to the prep phase write out
/ mixed data. so that some compression testing going on

read:{[file]
    fsize:hcount file;
    STDOUT"filesize ",(string fsize%(1024*1024))," MiB";
    sT:.z.n;
    STDOUT("Start thread -23! mapped read ",string sT); 
    mapped:get [file];
    {-23!x;} mapped;
    milly:(floor (`long$.z.n-sT)%10 xexp 6);
    STDOUT("End thread -23! mapped read ",string milly); 
    sT:.z.n;
    STDOUT("Start thread walklist",string sT); 
    max mapped;
    milly:(floor (`long$.z.n-sT)%10 xexp 6);
    STDOUT("End thread walklist ",string milly); 
    }
reread:{[file]
    sT:.z.n;
    STDOUT("Start thread -23! mapped reread ",string sT); 
    mapped:get [file];
    {-23!x;} mapped;
    milly:(floor (`long$.z.n-sT)%10 xexp 6);
    STDOUT("End thread -23! mapped reread ",string milly); 
    }
   
/ hopefully we flushed before this...

randomread1m:{[file]
     STDOUT(string .z.P);
     {x y+z;}[v;til 1048576]each 100?-1048576+count v:value `:readtest ;
     STDOUT(string .z.P);
    }
randomread64k:{[file]
    {x y+z;}[v;til 65536]each 1600?-65536+count v:value `:readtest ;
    }
randomread1mu:{[file]
    {value[`:readtest]y+x}[til 1048576]each 100?-1048576+hcount[`:readtest]div 8 ;
    }
randomread64ku:{[file]
    {value[`:readtest]y+x}[til 65536]each 1600?-65536+hcount[`:readtest]div 8 ;
    }

// for distributed file system with client side compression....don't use this 
if[COMPRESS;
    .z.zd:(18;1;0); ]


/  this is deprecated... 
write:{[file]
    / this is to allow any 3rd party performance monotoring tools to see a time gap
    system"sleep 5";
    STDOUT(string .z.p);
    STDOUT"write `",(string file)," - ",(string floor 0.5+(ssm%(2 xexp 20))%0.001*value "\\t `",(string file)," 1:WSAMPLESIZE#key 11+rand 111")," MiB/sec";hdel file; 
    STDOUT(string .z.p);
    }

fileopso:{[file]
    STDOUT"hclose hopen ",msstring 0.001*value"\\t do[1000;hclose hopen`",(string file),"]";
    }
fileops1:{[file]
    STDOUT" ();,;2 3] ",msstring 0.001*value"\\t do[1000;.[`",(string file),";();,;2 3]]";
    }
fileops2:{sx:string x;
    STDOUT" ();:;2 3] ",msstring 0.001*value"\\t do[1000;.[`",sx,";();:;2 3]]";
    }
fileops3:{sx:string x;
    H::hopen x;N:1000;
    STDOUT"append (2 3) to handle ",msstring (1%N)*value"\\t do[",string[N],";H(2 3)]";
    }
fileops4:{sx:string x;
    H::hopen x;N:1000;
    STDOUT"hcount ",msstring (1%N)*value"\\t do[",string[N],";hcount`",sx,"]";
    }
fileops5:{sx:string x;
    H::hopen x;N:1000;
    STDOUT"read1 ",msstring (1%N)*value"\\t do[",string[N],";read1`",sx,"]";
    }
fileops6:{sx:string x;
    H::hopen x;N:1000;
    STDOUT"value ",msstring (1%N)*value"\\t do[",string[N],";value`",sx,"]";
    }
fileopslink:{sx:string x;
	/ go in symbolically
     STDOUT"symbolic link test...";
     system"rm -f fileopstest.sym";
     system"ln -s fileopst1 fileopstest.sym";
	/ go in hard
    STDOUT"hard link test...";
    system"rm -f fileops.hard";
    system"ln fileopst1 fileops.hard";
    system"rm -f fileopstest.sym";
    system"rm -f fileops.hard";
    }
fileopslock:{sx:string x;
    H::hopen x;N:1000;
    STDOUT"lock time...",msstring (1%N)*value "\\t do[",string[N],";`:filelock?`aaa`bbb`ccc`ddd`eee]";
    }

comm:{sx:string x;
    STDOUT"hclose hopen`",sx," ",msstring 0.001*value"\\t do[1000;hclose hopen`",sx,"]";
    H::hopen x;
    STDOUT"sync (key rand 100) ",msstring 0.00001*value"\\t do[50000;H\"key rand 100\"]";
    STDOUT"async (string 23);collect ",msstring 0.00001*value"\\t do[50000;(neg H)\"23\"];H\"23\"";
    STDOUT"sync (string 23) ",msstring 0.00001*value"\\t do[50000;H\"23\"]"}

if[PREPARE;
    / give a high level sense of cpu fill to memory list speed...
    STDOUT"v",ioq;
    STDOUT"list creation...";
    sT:.z.n;
    privmem:random+til SAMPLESIZE;
    milly:(floor (`long$.z.n-sT)%10 xexp 6);
    STDOUT"create list"," - ",(string floor 0.5+(ssm%(2 xexp 20))%0.001*milly)," MiB/sec";
    sT:.z.n;
    lrfile set privmem;
    milly:(floor (`long$.z.n-sT)%10 xexp 6);
    STDOUT"async write rate: "," - ",(string floor 0.5+(ssm%(2 xexp 20))%0.001*milly)," MiB/sec";
    system"sleep 5";
    fileopsmem:`long$til `long$(2 xexp 14);
    ffileo set fileopsmem;
    ffile1 set fileopsmem;
    ffile2 set fileopsmem;
    ffile3 set fileopsmem;
    ffile4 set fileopsmem;
    ffile5 set fileopsmem;
    ffile6 set fileopsmem;
    ]

if[RUNREAD;
    STDOUT"v",ioq;
    STDOUT(string .z.p)," - ",(string `date$.z.p)," ",(string `minute$.z.p)," ",(string .z.h)," - times in ms for single execution";
    / read whole file, no write
    read[lrfile];
    STDOUT"Clearing Heap....";
    .Q.gc[];
 ]

if[REREAD; 
    STDOUT"v",ioq;
    STDOUT(string .z.p)," - ",(string `date$.z.p)," ",(string `minute$.z.p)," ",(string .z.h)," - times in ms for single execution";
    reread[lrfile];
 ]

if[RUNMETA;
    STDOUT"v",ioq;
    / this is to allow any 3rd party performance monotoring tools to see a time gap
    system"sleep 5";
    STDOUT"* begin fileops...";
    STDOUT(string .z.p);
    fileopso[ffileo];
    fileops1[ffile1];
    fileops2[ffile2];
    fileops3[ffile3];
    fileops4[ffile4];
    fileops5[ffile5];
    fileops6[ffile6];
    fileopslink[ffile6];
    fileopslock[ffile7];
 ] 

if[RANDOMREAD1M;
    randomread1m[lrfile];
    ]
if[RANDOMREAD1MU;
    randomread1mu[lrfile];
    ]
if[RANDOMREAD64K;
    randomread64k[lrfile];
    ]
if[RANDOMREAD64KU;
    randomread64ku[lrfile];
    ]

if[CLEANUP;
    @[hdel;lrfile;()];@[hdel;ffile1;()];
    @[hdel;ffile2;()];@[hdel;ffile3;()];
    @[hdel;ffile4;()];@[hdel;ffile5;()];
    @[hdel;ffile6;()];@[hdel;ffile7;()];
    ]
\\
