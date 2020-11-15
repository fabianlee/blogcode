#!/bin/bash
#
# Creates a new tmux session capable of being shared
#

myid=$(whoami)
sharedSocket=/tmp/${myid}_tmux_shared

# create tmux session
tmux -S $sharedSocket new-session -s ${myid}_tmux_shared
