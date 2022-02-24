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

# kill ping after 3 seconds and continue
echo ""
echo "ping will die after 3 seconds, then continue processing..."
timeout 3 ping 127.0.0.1

# disable trap
#trap "" SIGKILL

# trap 'EXIT' signal (kill) for custom message
trap pingtimeout_kill SIGEXIT

# kill after 3 seconds
echo ""
echo "ping will die after 3 seconds with custom message..."
timeout --signal=SIGEXIT 3 ping 127.0.0.1

echo ""
for i in $(seq 1 3); do
  echo "last $i"
done
