// these are also generated by tests but it is better to minimize side-effect of a test
smallVec: 0N?`long$til 16*k
MIDLENGTH: `long$MODIFIER*32*M
midVec: 0N?`long$til MIDLENGTH

SYMNR: "J"$getenv `SYMNR
sym: `u#neg[SYMNR]?`4;
midSymVec: MIDLENGTH?sym;

midFloatVec:MIDLENGTH?100.;
midFloatVec: %[;100] `int$100*midFloatVec / round up a bit to have some duplication