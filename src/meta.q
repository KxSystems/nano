include: {
  curFile: value[{}][6];
  system "l ", sublist[1+last where curFile = "/"; curFile], x;
  }

include "common.q";

STDOUT"v",ioq;
/ this is to allow any 3rd party performance monotoring tools to see a time gap
system"sleep 5";


fileopslink:{[];
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

STDOUT"begin fileops...";
STDOUT string .z.p;

N:1000;
SN: string N;

STDOUT"hclose hopen ",msstring (1%N)*value"\\t do[",SN,"; hclose hopen`",(string ffileo),"]";

STDOUT".[;();,;2 3] ",msstring (1%N)*value"\\t do[",SN,"; .[`",(string ffile1),";();,;2 3]]";

STDOUT".[;();:;2 3] ",msstring (1%N)*value"\\t do[",SN,"; .[`",(string ffile2),";();:;2 3]]";

H:hopen ffile3;
STDOUT"append (2 3) to handle ",msstring (1%N)*value"\\t do[",string[N],";H 2 3]";
hclose H;

STDOUT"hcount ",msstring (1%N)*value"\\t do[",string[N],";hcount`",(string ffile4),"]";
STDOUT"read1 ",msstring (1%N)*value"\\t do[",string[N],";read1`",(string ffile5),"]";
STDOUT"get ",msstring (1%N)*value"\\t do[",string[N],";value`",(string ffile6),"]";

fileopslink[];

STDOUT"lock time...",msstring (1%N)*value "\\t do[",string[N],";`",(string ffile7), "?`aaa`bbb`ccc`ddd`eee]";

if [not `debug in argvk; exit 0];