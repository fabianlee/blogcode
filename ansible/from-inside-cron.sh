#!/bin/bash
#
# Place at /tmp so it can be run by cron
#

# should be owned and writable by root (cron user)
logfile=/tmp/from-inside-cron.log
if [ ! -f $logfile ]; then
  touch $logfile
fi

echo "*********************** $(date) ***************************" >> $logfile

# show environment variables where not all uppercase
env | grep "^[A-Za-z][a-z]" >> $logfile

