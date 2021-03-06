#!/bin/bash
# This file is part of the rsyslog project, released under GPLv3
echo ===============================================================================
echo \[failover-basic.sh\]: basic test for failover functionality
. $srcdir/diag.sh init
startup failover-basic.conf
. $srcdir/diag.sh injectmsg  0 5000
echo doing shutdown
shutdown_when_empty
echo wait on shutdown
wait_shutdown 
seq_check  0 4999
exit_test
