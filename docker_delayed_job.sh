#!/bin/bash
set -e
PROCESS_NAME=$(basename "$(pwd)")
PID_FOLDER="tmp/delayed_pids"
PID_NAME="$PROCESS_NAME.pid"
PID_FULL_PATH="$PID_FOLDER/$PID_NAME"
cd /home/app/cypress
mkdir -p $PID_FOLDER
touch $PID_FULL_PATH
exec /sbin/setuser app bundle exec rake jobs:work >>log/$PROCESS_NAME.log 2>&1
rm $PID_FULL_PATH
