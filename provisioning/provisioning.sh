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
systemctl start testmon.service
systemctl enable testmon.service
systemctl start testmon.timer
systemctl enable testmon.timer
