#!/bin/bash
# This file is part of the rsyslog project, released under ASL 2.0

# This test tests omprog with the confirmMessages=on and useTransactions=on
# parameters, with the external program returning an error on certain
# transaction commits.

. $srcdir/diag.sh init

uname
if [ `uname` = "SunOS" ] ; then
    # On Solaris, this test causes rsyslog to hang. This is presumably due
    # to issue #2356 in the rsyslog core, which doesn't seem completely
    # corrected. TODO: re-enable this test when the issue is corrected.
    echo "Solaris: FIX ME"
    exit 77
fi

startup omprog-transactions-failed-commits.conf
. $srcdir/diag.sh wait-startup
. $srcdir/diag.sh injectmsg 0 10
. $srcdir/diag.sh wait-queueempty
shutdown_when_empty
wait_shutdown

# Since the transaction boundaries are not deterministic, we cannot check for
# an exact expected output. We must check the output programmatically.

transaction_state="NONE"
status_expected=true
messages_to_commit=()
messages_processed=()
line_num=1
error=

while IFS= read -r line; do
    if [[ $status_expected == true ]]; then
        case "$transaction_state" in
        "NONE")
            if [[ "$line" != "<= OK" ]]; then
                error="expecting an OK status from script"
                break
            fi
            ;;
        "STARTED")
            if [[ "$line" != "<= OK" ]]; then
                error="expecting an OK status from script"
                break
            fi
            transaction_state="ACTIVE"
            ;;
        "ACTIVE")
            if [[ "$line" != "<= DEFER_COMMIT" ]]; then
                error="expecting a DEFER_COMMIT status from script"
                break
            fi
            ;;
        "COMMITTED")
            if [[ "$line" == "<= Error: could not commit transaction" ]]; then
                messages_to_commit=()
                transaction_state="NONE"
            else
                if [[ "$line" != "<= OK" ]]; then
                    error="expecting an OK status from script"
                    break
                fi
                messages_processed+=("${messages_to_commit[@]}")
                messages_to_commit=()
                transaction_state="NONE"
            fi
            ;;
        esac
        status_expected=false;
    else
        if [[ "$line" == "=> BEGIN TRANSACTION" ]]; then
            if [[ "$transaction_state" != "NONE" ]]; then
                error="unexpected transaction start"
                break
            fi
            transaction_state="STARTED"
        elif [[ "$line" == "=> COMMIT TRANSACTION" ]]; then
            if [[ "$transaction_state" != "ACTIVE" ]]; then
                error="unexpected transaction commit"
                break
            fi
            transaction_state="COMMITTED"
        else
            if [[ "$transaction_state" != "ACTIVE" ]]; then
                error="unexpected message outside a transaction"
                break
            fi
            if [[ "$line" != "=> msgnum:"* ]]; then
                error="unexpected message contents"
                break
            fi
            prefix_to_remove="=> "
            messages_to_commit+=("${line#$prefix_to_remove}")
        fi
        status_expected=true;
    fi
    let "line_num++"
done < rsyslog.out.log

if [[ -z "$error" && "$transaction_state" != "NONE" ]]; then
    error="unexpected end of file (transaction state: $transaction_state)"
fi

if [[ -n "$error" ]]; then
    echo "rsyslog.out.log: line $line_num: $error"
    cat rsyslog.out.log
    error_exit 1
fi

# Since the order in which failed messages are retried by rsyslog is not
# deterministic, we sort the processed messages before checking them.
IFS=$'\n' messages_sorted=($(sort <<<"${messages_processed[*]}"))
unset IFS

expected_messages=(
    "msgnum:00000000:"
    "msgnum:00000001:"
    "msgnum:00000002:"
    "msgnum:00000003:"
    "msgnum:00000004:"
    "msgnum:00000005:"
    "msgnum:00000006:"
    "msgnum:00000007:"
    "msgnum:00000008:"
    "msgnum:00000009:"
)
if [[ "${messages_sorted[*]}" != "${expected_messages[*]}" ]]; then
    echo "unexpected set of processed messages:"
    printf '%s\n' "${messages_processed[@]}"
    echo "contents of rsyslog.out.log:"
    cat rsyslog.out.log
    error_exit 1
fi

exit_test
