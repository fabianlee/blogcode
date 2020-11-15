#!/bin/bash
#
# Creates a new tmux session capable of being shared
#

myid=$(whoami)
sharedSocket=/tmp/${myid}_tmux_shared

echo "===IMPORTANT==="
echo "Be sure to open permissions to this socket for others when you get into your tmux session"
echo ""
echo "chmod 777 $sharedSocket"
echo ""
read -p "Press <ENTER> to continue" $dummy

# create tmux session
tmux -S $sharedSocket new-session -s ${myid}_tmux_shared
