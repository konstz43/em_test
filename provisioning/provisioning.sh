#!/bin/bash

# Script to install the monitoring script and set it up as a systemd service with a timer
# Usage: sudo ./provisioning.sh [target_directory/]
# Default target_directory is /usr/local/
# The script must be run as root

set -e

if [ $(id -u) -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

TARGET_DIR=/usr/local/
if [ $1 ]; then
    TARGET_DIR=$1
fi
if [ ! -d $TARGET_DIR ]; then
    mkdir $TARGET_DIR
fi

cp -f ../testmon.sh $TARGET_DIR

cp -f testmon.service /etc/systemd/system/
cp -f testmon.timer /etc/systemd/system/

sed -i "s|^ExecStart=.*|ExecStart=$TARGET_DIR/testmon.sh|" /etc/systemd/system/testmon.service
chmod 644 /etc/systemd/system/testmon.service
chmod 644 /etc/systemd/system/testmon.timer

systemctl daemon-reload
systemctl enable --now testmon.service
systemctl enable --now testmon.timer

cp -f monitoring /etc/logrotate.d/monitoring
chmod 644 /etc/logrotate.d/monitoring

echo "Provisioning completed. Monitoring script installed to $TARGET_DIR"
echo "Service and timer units installed to /etc/systemd/system/"
echo "Logrotate configuration installed to /etc/logrotate.d/monitoring"
echo "You can check the status of the service with: systemctl status testmon.service"
echo "You can check the status of the timer with: systemctl status testmon.timer"
echo "Make sure to adjust the MON_SERV_URI and PROC_NAME variables in $TARGET_DIR/testmon.sh as needed."
echo "You can check the log file with: tail -f /var/log/monitoring.log"
