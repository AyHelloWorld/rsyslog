#!/bin/bash
# added 2014-01-17 by rgerhards
# This file is part of the rsyslog project, released under ASL 2.0
echo ===============================================================================
echo \[rscript_le.sh\]: testing rainerscript LE statement
. $srcdir/diag.sh init
startup rscript_le.conf
. $srcdir/diag.sh injectmsg  0 8000
echo doing shutdown
shutdown_when_empty
echo wait on shutdown
wait_shutdown 
seq_check  0 5000
exit_test
