#!/bin/bash
# addd 2016-05-13 by RGerhards, released under ASL 2.0

. $srcdir/diag.sh init
generate_conf
add_conf '
$MaxMessageSize 128
global(processInternalMessages="on")
module(load="../plugins/imtcp/.libs/imtcp")
input(type="imtcp" port="13514" ruleset="ruleset1")

template(name="templ1" type="string" string="%rawmsg%\n")
ruleset(name="ruleset1") {
	action(type="omfile" file="rsyslog.out.log" template="templ1")
}
'
startup
. $srcdir/diag.sh tcpflood -m2 -M "\"41 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"214000000000 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"41 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"214000000000 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"41 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"2000000010 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"4000000000 <120> 2011-03-01T11:22:12Z host msgnum:1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"0 <120> 2011-03-01T11:22:12Z host msgnum:1\""
shutdown_when_empty
wait_shutdown

echo '<120> 2011-03-01T11:22:12Z host msgnum:1
<120> 2011-03-01T11:22:12Z host msgnum:1
214000000000<120> 2011-03-01T11:22:12Z host msgnum:1
<120> 2011-03-01T11:22:12Z host msgnum:1
214000000000<120> 2011-03-01T11:22:12Z host msgnum:1
<120> 2011-03-01T11:22:12Z host msgnum:1
2000000010<120> 2011-03-01T11:22:12Z host msgnum:1
4000000000<120> 2011-03-01T11:22:12Z host msgnum:1
<120> 2011-03-01T11:22:12Z host msgnum:1' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  error_exit  1
fi;

exit_test
