system "l src/common.q";
system "l src/samplearrays.q";


cpuTestFactory: {[testtype:`C;testid:`s;N:`j;fn;qexpr;param;test:`C;mult:`j]
  writerFn: writeRes[testtype;;qexpr];
  testid set {[writerFn;testid;N;fn;param;test;mult;dontcare] / the namespaced testID is the function name
    .qlog.info "starting test ", test;
    sT: .z.n;
    do[CPUREPEAT*N;fn param];
    eT: .z.n;
    writerFn[testid,"|",test; N; count param; sT, eT; fix[2; getMBPerSec[mult*CPUREPEAT*N*count param; eT-sT]]; "MB/sec\n"];
    }[writerFn;string testid;N;fn;param;test;mult];
  }
