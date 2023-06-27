system "l src/common.q";

comm:{sx:string x;
  STDOUT"hclose hopen`",sx," ",msstring 0.001*value"\\t do[1000;hclose hopen`",sx,"]";
  H::hopen x;
  STDOUT"sync (key rand 100) ",msstring 0.00001*value"\\t do[50000;H\"key rand 100\"]";
  STDOUT"async (string 23);collect ",msstring 0.00001*value"\\t do[50000;(neg H)\"23\"];H\"23\"";
  STDOUT"sync (string 23) ",msstring 0.00001*value"\\t do[50000;H\"23\"]"
  }

