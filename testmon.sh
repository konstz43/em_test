#!/bin/bash

# Script to monitoring a process named "test"
 
# Minimal needed curl version is 7.33.0
 
MON_SERV_URI="https://test.com/monitoring/test/api"
# MON_SERV_URI="https://google.com" # for debug
LOG_FILE_NAME="monitoring"
PROC_NAME="test"

# If the process "$PROC_NAME" is running check responce of $MON_SERV_URI (by https)
if PID_OF_TEST=$(pidof $PROC_NAME); then

    echo "PID of "$PROC_NAME":" $PID_OF_TEST    # for debug

    if [ ! -f /tmp/$PROC_NAME.pid ]; then echo $PID_OF_TEST > /tmp/$PROC_NAME.pid; fi # initialize .pid file

    # --connect-timeout option ensures that the time it takes to receive a responce from the server
    # will be limited, and thus the script execution time will be less than the interval between its launches.
    SERV_RESPONCE=$(curl -so /dev/null -w '%{response_code}' --proto =https --connect-timeout 30 $MON_SERV_URI)

    # Write to log if $MON_SERV_URI is not available
    if [ $? -ne 0 -o $SERV_RESPONCE -ge 400 ]; then
        echo "Server responce:" $SERV_RESPONCE  # for debug
        echo "$(date): Server $MON_SERV_URI is not reachable" >> /var/log/$LOG_FILE_NAME.log
    else    # for debug
        echo "Server responce:" $SERV_RESPONCE - it is Ok   # for debug
    fi

# If the process "$PROC_NAME" has been restarted, write to log /var/log/monitoring.log
    if [ ! $(cat /tmp/$PROC_NAME.pid) -eq $PID_OF_TEST ]; then
        echo "$(date): Process $PROC_NAME has been restarted" >> /var/log/$LOG_FILE_NAME.log
        echo $PID_OF_TEST > /tmp/$PROC_NAME.pid  # refresh stored pid
    fi

else    # for debug
# если процесс не запущен, то ничего не делать    # for debug
    echo "Nothing to do"    # for debug

fi
