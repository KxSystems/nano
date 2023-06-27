system "l src/common.q";

/ this is to allow any 3rd party performance monotoring tools to see a time gap
system"sleep 5";


fileopslink:{[];
	/ go in symbolically
    .qlog.info"symbolic link test...";
    system"rm -f ", DB, "/fileopstest.sym";
    system"ln -s ", DB, fHmmapFileName, " ", DB, "/fileopstest.sym";
	/ go in hard
    .qlog.info"hard link test...";
    system"rm -f ", DB, "/fileops.hard";
    system"ln ", DB, fHmmapFileName, " ", DB, "/fileops.hard";
    }

$[OBJSTORE;
  .qlog.info"Skipping hopen/append/symlink/enum extend meta tests"; [
  .qlog.info "starting close open test";
  sT:.z.n;
  do[N; hclose hopen fOpenClose];
  elapsed:tsToSec .z.n-sT;
  resultH "meta|close open|hopen,hclose|", fix[4;1000 * elapsed%N], "|ms\n";

  fileopslink[];

  .qlog.info "starting lock test";
  sT:.z.n;
  do[N; flock?`aaa`bbb`ccc`ddd`eee];
  elapsed:tsToSec .z.n-sT;
  resultH "meta|lock|enum extend|", fix[4;1000 * elapsed%N], "|ms\n"]];

.qlog.info "starting size test";
sT:.z.n;
do[N; hcount fhcount];
elapsed:tsToSec .z.n-sT;
resultH "meta|size|hcount|", fix[4;1000 * elapsed%N], "|ms\n";

.qlog.info "starting mmap test";
sT:.z.n;
do[N; get fmmap];
elapsed:tsToSec .z.n-sT;
resultH "read disk|mmap|get|", fix[4;1000 * elapsed%N], "|ms\n";


if [not `debug in argvk; exit 0];