#!/bin/bash
# test many concurrent tcp connections
# addd 2016-01-12 by RGerhards, released under ASL 2.0
# requires faketime
echo \[now_family_utc\]: test \$NOW family of system properties
. $srcdir/diag.sh init

. $srcdir/faketime_common.sh

export TZ=TEST+06:30

FAKETIME='2016-01-01 01:00:00' startup now_family_utc.conf
# what we send actually is irrelevant, as we just use system properties.
# but we need to send one message in order to gain output!
. $srcdir/diag.sh tcpflood -m1
shutdown_when_empty
wait_shutdown
echo "01:00,07:30" | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid timestamps generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  exit 1
fi;


exit_test
