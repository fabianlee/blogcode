#!/bin/bash
#
# Illustrates use of timeout to halt process after certain n seconds
# https://ss64.com/bash/timeout.html
#

echo ""
echo "--- 5 sec timeout not reached, normal exit code returned  ---"

timeout 5 sleep 1
echo "exited uniterrupted short sleep with $? (expected 0)"


echo ""
echo "--- 5 sec timeout reached (124=timeout,127=cmd not found) ---"

timeout 5 sleep 10
echo "exited long sleep ending in true with $? (expected 124)"


echo ""
echo ""
echo "---ping will die after 3 seconds ---"
timeout 3 ping 127.0.0.1
echo "exited ping with $? (expected 124 for timeout)"
