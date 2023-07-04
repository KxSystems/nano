system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x

if[not `db in argvk;
  .qlog.error "parameter db is missing";
  exit 6];
DB: argv `db
OBJSTORE: any DB like/: ("s3://*"; "gs://*"; "ms://*");
if[OBJSTORE & not @[{x in key .comkxic.libs}; `objstor; 0b];
    .qlog.error "kdb Insights is required for object storage support";
    exit 7];

if[ not `result in argvk;
  .qlog.error "parameter result is missing";
  exit 8];
resultH: hopen ":", argv `result;

controller: hopen "J"$argv `controller;

tsToSec: {(`long$x)%10 xexp 9}
fix:{.Q.fmt[x+1+count string floor y;x;y]}
msstring:{(string x)," ms"}

// for distributed file system with client side compression....don't use this


/ note that compression does not work with a "dot" in the filename
fRead: hsym `$DB, fReadFileName: "/seqread";
fRandomRead: hsym `$DB, fRandomReadFileName: "/randomread";

fOpenClose: hsym `$DB, fOpenCloseFileName: "/openclose";
fhcount: hsym `$DB, fHCountFileName: "/fhcount";
fReadBinary: hsym `$DB, fHReadBinaryFileName: "/readbinary";
fmmap: hsym `$DB, fHmmapFileName: "/mmap";
flock: hsym `$DB, "/locktest";

k: 1024
M: k*k
SIZEOFLONG: 8
MEMRATIOMODIFIERS: `full`small`tiny!1 0.2 0.05
MODIFIER: 1f^MEMRATIOMODIFIERS `$getenv `DBSIZE

// Repeat number of some meta and write tests
N: `long$MODIFIER*50*1000;
