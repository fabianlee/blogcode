#!/bin/bash
#
# Illustrates use of SIGINT, SIGUSR1, SIGEXIT capture in BASH
#

# custom user signal
sigusr1_count=0
function sigusr1_capture() {
  ((sigusr1_count+=1))
  echo "SIGUSR1 called $sigusr1_count times"
}

# Ctrl-C signal
ctrl_c_count=0
function sigint_capture() {
  ((ctrl_c_count+=1))
  echo "SIGINT CTRL-C sensed for $ctrl_c_count time"
  if [ $ctrl_c_count -gt 2 ]; then
    echo "SIGINT Ctrl-C pressed 3 times, flipping flag"
    continue_looping=0
  fi
}

# signal on exit of main process
function sigexit_capture() {
  echo ""
  echo "== FINAL EXIT COUNTS ==="
  echo "SIGUSR1 called $sigusr1_count times"
  echo "SIGINT CTRL-C sensed for $ctrl_c_count time"
}


########## MAIN #################

# trap signals to functions
trap sigint_capture SIGINT
trap sigusr1_capture USR1
trap sigexit_capture EXIT

# send signals to self as test
echo "current pid is $$ $BASHPID"
kill -s SIGINT $$
kill -s SIGUSR1 $$


continue_looping=1
while [ $continue_looping -eq 1 ]; do
  echo "Waiting for you to press <CTRL>-C 3 times..."

  # send SIGUSR1 every second
  kill -s SIGUSR1 $$
  sleep 1
done

