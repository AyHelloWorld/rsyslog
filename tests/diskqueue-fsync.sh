#!/bin/bash
# Test for disk-only queue mode (with fsync for queue files)
# This test checks if queue files can be correctly written
# and read back, but it does not test the transition from
# memory to disk mode for DA queues.
# added 2009-06-09 by Rgerhards
# This file is part of the rsyslog project, released  under GPLv3
# uncomment for debugging support:
echo \[diskqueue-fsync.sh\]: testing queue disk-only mode, fsync case

uname
if [ `uname` = "SunOS" ] ; then
   echo "This test currently does not work on all flavors of Solaris."
   exit 77
fi

. $srcdir/diag.sh init
startup diskqueue-fsync.conf
# 1000 messages should be enough - the disk fsync test is very slow!
. $srcdir/diag.sh injectmsg 0 1000
shutdown_when_empty # shut down rsyslogd when done processing messages
wait_shutdown
seq_check 0 999
exit_test
