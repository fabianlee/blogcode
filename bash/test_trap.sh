#!/bin/bash
#
# Illustrates use of KILL and SIGINT capture in BASH
#

function pingtimeout_kill() {
  echo "KILLED. timeout from ping"
}

ctrl_c_count=0
function sigint_capture() {
  $((ctrl_c_count+=1))
  echo "CTRL-C sensed for $ctrl_c_count time"
  if [ $ctrl_c_count -gt 2 ]; then
    echo "stopping loop because CTRL-C pressed 3 times"
    continue_looping=0
  fi
}


########## MAIN #################

# trap 'SIGINT' <Ctrl>-C
#trap sigint_capture SIGINT

#continue_looping=1
#while [ $continue_looping -eq 1 ]; do
#  echo "Waiting for you to press <CTRL>-C 3 times..."
#  sleep 1
#done

timeout 5 sleep 1 && true
echo "exited short sleep ending in true with $? (expected 0)"

timeout 5 sleep 1 && false
echo "exited short sleep ending in false with $? (expected 1)"

timeout 2 sleep 10 && $(exit 3)
echo "exited long sleep ending in false with $? (expected 124 for timeout)"
timeout 2 sleep 10 && true
echo "exited long sleep ending in true with $? (expected 124 for timeout)"

# kill ping after 3 seconds and continue
echo ""
echo "ping will die after 3 seconds, then continue processing..."
timeout 3 ping 127.0.0.1
echo "exited ping with $? (expected 124 for timeout)"

# disable trap
#trap "" SIGKILL

# trap 'EXIT' signal (kill) for custom message
#trap pingtimeout_kill SIGINT

# kill after 3 seconds
echo ""
echo "ping will die after 3 seconds with custom message..."
timeout 3 ping 127.0.0.1
echo "exited with $?"

#echo ""
#for i in $(seq 1 3); do
#  echo "last $i"
#done
