system "l src/log.q";
argvk:key argv:first each .Q.opt .z.x
system "l src/util.q";

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
writeRes: {[testtype:`C; test:`C; qexpression:`C; repeat:`j; length:`j; times:`N; result:`C; unit:`C]
  resultH SEP sv (string system "s";string .z.o;testtype; test; qexpression; string repeat; string length; string first times; string last times; result; unit);
  }

controller: `$"::",argv `controller;

msstring:{(string x)," ms"}
// df returns partition like /dev/nvme0n1p1
getFilesystem: {[db:`C] first " " vs last system "df ", db}

getDeviceOSX:{
  $[1 = count system "diskutil list|grep physical";
    first[system "iostat -d"] except " "; [
    .qlog.warm "multi-disk systems are not supported";
    ""]]
  }

getDevice:{[db:`C]
  if[.z.o=`m64;:getDeviceOSX[]];

  fs: getFilesystem[db];
  if["overlay" ~ fs; :fs];   / Inside Docker, NYI
  if["disk" ~ last system "lsblk -o type ", fs; :fs];
  p: ssr[;"/dev/";""] fs;
  // disk is looked up from partition by e.g. /sys/class/block/nvme0n1p1
  if[not (`$p) in key `$":/sys/class/block";
    .qlog.warn "Unable to map partition ", p, " to a device";
    :""];
  l:first system "readlink /sys/class/block/", p;
  "/dev",deltas[-2#l ss "/"] sublist l
  }

getTests: {[ns:`s] .Q.dd[ns;] each except[; `] key ns}

fRead: hsym `$DB, fReadFileName: "/seqread"
KDBDB: hsym `$DB, "/kdbdb"
KDBTBL: .Q.dd[KDBDB; `tbl]
fSymCol: .Q.dd[KDBTBL; `sym]
fFloatCol: .Q.dd[KDBTBL; `floatcol]

FILENRPERWORKER: "I"$getenv `FILENRPERWORKER

fsRandomRead: hsym `$DB,/: "/randomread",/: string til FILENRPERWORKER
fOpenClose: hsym `$DB, fOpenCloseFileName: "/openclose"
fhcount: hsym `$DB, fHCountFileName: "/fhcount"
fReadBinary: hsym `$DB, fHReadBinaryFileName: "/readbinary"
fmmap: hsym `$DB, fHmmapFileName: "/mmap"
flock: hsym `$DB, "/locktest"

MEMRATIOMODIFIERS: `double`full`small`tiny!2 1 0.2 0.05
MODIFIER: 1f^MEMRATIOMODIFIERS `$lower getenv `DBSIZE

// Repeat number of some meta and write tests
N: `long$MODIFIER*50*1000

processcount: "I"$string `$argv `processes

TASKSENDTIMEOUT:0D00:01
sendTests:{[c:`s;db:`C;nm:`s]
  .qlog.info "Sending tests to the controller";
  s:.z.p;
  while[not (::)~@[c; (`addWorker; system "p"; getDevice[db]; getTests[nm]); 
      {.qlog.debug "Unable to send tests to the controller: ", x, ". Waiting a second before retry.";0b}];
    if[.z.p > s+TASKSENDTIMEOUT; .qlog.error "Timeout sending tests to the controller"; exit 1];
    system "sleep 1"];
    .qlog.info "Tests were successfully sent to the controller";
  }

.z.exit: {
  .qlog.info "exiting worker";
  if[`exitcustom in key `.; exitcustom[]]
  };
