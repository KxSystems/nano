STDOUT:-1
$[@[{x in key .comkxic.libs}; `qlog; 0b]; [
  id:.com_kx_log.init[`:fd://stdout; ()];
  .qlog: .com_kx_log.new[`nano; ()]]; [
  .qlog.info: {STDOUT ssr[-6_5_string .z.p; "D"; " "], " ", x;};
  .qlog.warn: {STDOUT ssr[-6_5_string .z.p; "D"; " "], " ", "\033[43;37m", x ,"\033[0m";};
  .qlog.error:{STDOUT ssr[-6_5_string .z.p; "D"; " "], " ", "\033[41;37m", x ,"\033[0m";}]];