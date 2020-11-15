#!/bin/bash
#
# Allows you to view tmux session shared by someone else
#

myid="$1"
if [ -c $myid ]; then
  echo "ERROR you must supply the userid of the person whose tmux session you want to view"
  exit 3
fi

sharedSocket=/tmp/${myid}_tmux_shared
sudo chmod 777 $sharedSocket

echo "==SESSIONS=="
tmux -S $sharedSocket list-sessions

echo ""
echo "press <ENTER> to start viewing session, to detatch press CTRL-b d"
tmux -S $sharedSocket attach-session -t ${myid}_tmux_shared -r
