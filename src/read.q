system "l src/common.q";

fsize:hcount fRead;

/ read whole file, no write
.qlog.info "Starting mmap read test";
sT:.z.n;
mapped: get fRead;
{-23!x;} mapped;
elapsed:tsToSec .z.n-sT;
resultH "read disk|read|get,-23!|", fix[2;fsize%M*elapsed], "|MiB/sec\n";

.qlog.info "Starting aggregate test";
sT:.z.n;
max mapped;
elapsed:tsToSec .z.n-sT;
resultH "read mem|aggregate|max|", fix[2;fsize%M*elapsed], "|MiB/sec\n";

.qlog.info "starting read binary test";
sT:.z.n;
read1 fReadBinary;
elapsed:tsToSec .z.n-sT;
resultH "read disk|read binary|read1|", fix[2;hcount[fReadBinary]%M*elapsed], "|MiB/sec\n";

if [not `debug in argvk; exit 0];