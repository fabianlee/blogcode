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
ls -l $sharedSocket
if [[ ! -r $sharedSocket || ! -w $sharedSocket || ! -x $sharedSocket ]]; then
  echo "Need full permission to $sharedSocket to use tmux sharing. Request that $myid runs:"
  echo "chmod 777 $sharedSocket"
  exit 9
fi

echo "==SESSIONS=="
tmux -S $sharedSocket list-sessions

echo ""
read -p "press <ENTER> to start viewing session, to detatch press CTRL-b d" dummy
tmux -S $sharedSocket attach-session -t ${myid}_tmux_shared -r
