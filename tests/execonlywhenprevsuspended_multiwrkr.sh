#!/bin/bash
# rgerhards, 2013-12-05
echo =====================================================================================
echo \[execonlywhenprevsuspended_multiwrkr.sh\]: test execonly...suspended functionality multiworker case
. $srcdir/diag.sh init
startup execonlywhenprevsuspended_multiwrkr.conf
# we initially send only 10 messages. It has shown that if we send more,
# we cannot really control which are the first two messages imdiag sees,
# and so we do not know for sure which numbers are skipped. So we inject
# those 10 to get past that point.
. $srcdir/diag.sh injectmsg 0 10
./msleep 500
. $srcdir/diag.sh injectmsg 10 990
shutdown_when_empty
wait_shutdown
seq_check 1 999
exit_test
