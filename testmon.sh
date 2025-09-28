#!/bin/bash

# Script to monitoring a process named "test"
 
# Minimal needed curl version is 7.33.0
 
MON_SERV_URI="https://test.com/monitoring/test/api"
LOG_FILE_NAME="monitoring"
PROC_NAME="test"

# If the process "$PROC_NAME" is running check responce of $MON_SERV_URI (by https)
if PID_OF_TEST=$(pidof $PROC_NAME); then

    if [ ! -f /tmp/$PROC_NAME.pid ]; then echo $PID_OF_TEST > /tmp/$PROC_NAME.pid; fi # initialize .pid file

    # Write to log if the process "$PROC_NAME" has been restarted
    if [ ! $(cat /tmp/$PROC_NAME.pid) -eq $PID_OF_TEST ]; then
        echo "$(date): Process $PROC_NAME has been restarted" >> /var/log/$LOG_FILE_NAME.log
        echo $PID_OF_TEST > /tmp/$PROC_NAME.pid  # refresh stored pid
    fi

    # --connect-timeout option ensures that the time it takes to receive a responce from the server
    # will be limited, and thus the script execution time will be less than the interval between its launches.
    SERV_RESPONCE=$(curl -so /dev/null -w '%{response_code}' --proto =https --connect-timeout 30 $MON_SERV_URI)

    # Write to log if $MON_SERV_URI is not available
    if [ $? -ne 0 -o $SERV_RESPONCE -ge 400 ]; then
        echo "$(date): Server $MON_SERV_URI is not reachable" >> /var/log/$LOG_FILE_NAME.log
    fi

fi
