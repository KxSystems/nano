SIZEOFLONG: 8

k: 1024
M: k*k

tsToSec: {(`long$x)%10 xexp 9}
fix:{.Q.fmt[x+1+count string floor y;x;y]}
getMBPerSec: {[length; elapsed] SIZEOFLONG*length*1000%`long$elapsed}  // same as SIZEOFLONG*length%M*tsToSec elapsed