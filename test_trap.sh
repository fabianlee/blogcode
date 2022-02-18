#!/bin/bash
#
# Illustrates use of KILL and SIGINT capture in BASH
#

function pingtimeout_kill() {
  echo "EXITING.  timeout from ping"
}

function sigint_capture() {
  echo "CTRL-C sensed, setting 'continue_looping' variable off"
  continue_looping=0
}


########## MAIN #################

# trap 'SIGINT' <Ctrl>-C
trap sigint_capture SIGINT

# trap 'EXIT' signal (kill)
trap pingtimeout_kill EXIT

continue_looping=1
while [ $continue_looping -eq 1 ]; do
  echo "Waiting for you to press <CTRL>-C..."
  sleep 1
done


# kill after 3 seconds
echo ""
echo "ping will die after 3 seconds..."
timeout 3 ping 127.0.0.1
