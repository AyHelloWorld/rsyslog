#!/bin/bash
# add 2016-11-22 by Pascal Withopf, released under ASL 2.0
. $srcdir/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imtcp/.libs/imtcp")
module(load="../plugins/mmnormalize/.libs/mmnormalize")

input(type="imtcp" port="13514" ruleset="norm")

template(name="outfmt" type="string" string="%hostname% %syslogtag%\n")

ruleset(name="norm") {
	action(type="mmnormalize" rule=["rule=: no longer listening on %ip:ipv4%#%port:number%", "rule=: is sending messages on %ip:ipv4%", "rule=: apfelkuchen"])
	action(type="omfile" file="rsyslog.out.log" template="outfmt")
}
'
startup
. $srcdir/diag.sh tcpflood -m1 -M "\"<167>Mar 6 16:57:54 ubuntu tag1: no longer listening on 127.168.0.1#10514\""
. $srcdir/diag.sh tcpflood -m1 -M "\"<167>Mar 6 16:57:54 debian tag2: is sending messages on 127.168.0.1\""
. $srcdir/diag.sh tcpflood -m1 -M "\"<167>Mar 6 16:57:54 centos tag3: apfelkuchen\""
shutdown_when_empty
wait_shutdown
echo 'ubuntu tag1:
debian tag2:
centos tag3:' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  error_exit  1
fi;

exit_test
