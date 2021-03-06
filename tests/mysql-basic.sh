#!/bin/bash
# This file is part of the rsyslog project, released under GPLv3
echo ===============================================================================
echo \[mysql-basic.sh\]: basic test for mysql-basic functionality
. $srcdir/diag.sh init
mysql --user=rsyslog --password=testbench < testsuites/mysql-truncate.sql
startup mysql-basic.conf
. $srcdir/diag.sh injectmsg  0 5000
shutdown_when_empty
wait_shutdown 
# note "-s" is requried to suppress the select "field header"
mysql -s --user=rsyslog --password=testbench < testsuites/mysql-select-msg.sql > rsyslog.out.log
seq_check  0 4999
exit_test
