k: 1024
M: k*k

tsToSec: {(`long$x)%10 xexp 9}
fix:{.Q.fmt[x+1+count string floor y;x;y]}