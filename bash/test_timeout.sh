#!/bin/bash
#
# Illustrates use of timeout to halt process after certain n seconds
# https://ss64.com/bash/timeout.html
#

echo ""
echo "--- Examples where timeout is not reached, so normal exit code returned  ---"

timeout 5 sleep 1 && true
echo "exited short sleep ending in true with $? (expected 0)"

timeout 5 sleep 1 && false
echo "exited short sleep ending in false with $? (expected 1)"

echo ""
echo "--- Examples where timeout is reached (124=timeout per man page) ---"

timeout 2 sleep 10 && true
echo "exited long sleep ending in true with $? (expected 124)"

timeout 2 sleep 10 && false
echo "exited long sleep ending in false with $? (expected 124)"


echo ""
echo ""
echo "---ping will die after 3 seconds ---"
timeout 3 ping 127.0.0.1
echo "exited ping with $? (expected 124 for timeout)"
