#!/bin/bash
# added 2016-01-20 by singh.janmejay
# This file is part of the rsyslog project, released under ASL 2.0

uname
if [ `uname` = "FreeBSD" ] ; then
   echo "This test currently does not work on FreeBSD."
   exit 77
fi

echo ===============================================================================
echo \[multiple_lookup_table-vg.sh\]: test for multiple lookup-table and HUP based reloading of it
. $srcdir/diag.sh init
cp -f $srcdir/testsuites/xlate.lkp_tbl xlate.lkp_tbl
cp -f $srcdir/testsuites/xlate.lkp_tbl xlate_1.lkp_tbl
startup_vg multiple_lookup_tables.conf
. $srcdir/diag.sh injectmsg  0 3
. $srcdir/diag.sh wait-queueempty
. $srcdir/diag.sh content-check "msgnum:00000000: 0_foo_old 1_foo_old"
. $srcdir/diag.sh content-check "msgnum:00000001: 0_bar_old 1_bar_old"
. $srcdir/diag.sh assert-content-missing "baz"
cp -f $srcdir/testsuites/xlate_more.lkp_tbl xlate.lkp_tbl
. $srcdir/diag.sh issue-HUP
. $srcdir/diag.sh await-lookup-table-reload
. $srcdir/diag.sh injectmsg  0 3
. $srcdir/diag.sh wait-queueempty
. $srcdir/diag.sh content-check "msgnum:00000000: 0_foo_new 1_foo_old"
. $srcdir/diag.sh content-check "msgnum:00000001: 0_bar_new 1_bar_old"
. $srcdir/diag.sh content-check "msgnum:00000002: 0_baz"
. $srcdir/diag.sh assert-content-missing "1_baz"
cp -f $srcdir/testsuites/xlate_more.lkp_tbl xlate_1.lkp_tbl
. $srcdir/diag.sh issue-HUP
. $srcdir/diag.sh await-lookup-table-reload
. $srcdir/diag.sh injectmsg  0 3
echo doing shutdown
shutdown_when_empty
echo wait on shutdown
wait_shutdown_vg
. $srcdir/diag.sh check-exit-vg
. $srcdir/diag.sh content-check "msgnum:00000000: 0_foo_new 1_foo_new"
. $srcdir/diag.sh content-check "msgnum:00000001: 0_bar_new 1_bar_new"
. $srcdir/diag.sh content-check "msgnum:00000002: 0_baz 1_baz"
exit_test
