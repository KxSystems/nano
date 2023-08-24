// util.q - utility functions
// Copyright (c) 2023 Kx Systems Inc
//
// @overview
// Simple utility functions used throughout the project
//
// @category     Utilities
// @end

SIZEOFLONG: 8

k: 1024
M: k*k

SEP: "|"

// @desc timespan to seconds
//
tsToSec:{(`long$x)%10 xexp 9}

// @desc number string formatting with given number of decimals
//
fix:{.Q.fmt[x+1+count string floor y; x; y]}'

// @desc gets Mbyte/sec from list length and elapsed time
//
getMBPerSec:{[length; elapsed] SIZEOFLONG*length*1000%`long$elapsed}  / Same as SIZEOFLONG*length%M*tsToSec elapsed