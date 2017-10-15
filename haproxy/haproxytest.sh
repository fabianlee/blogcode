#!/bin/bash 
#
# Purpose: restarts HAProxy service on sysV and Systemd on Ubuntu


if [ "$#" -ne 2 ]; then
  echo Usage: restart\|reload\|reload-socket timeDelay
  exit 1
fi

dist=`lsb_release -sc`
echo dist is $dist

echo Going to $1 every $2 seconds...
while true; 
  do sleep $2
  if [ "$dist" == "trusty" ]; then
    service haproxy $1
    echo done with haproxy $1 using sysv, again in $2 seconds... 
  elif [ "$dist" == "xenial" ]; then
    systemctl $1 haproxy
    echo done with haproxy $1 using systemd, again in $2 seconds... 
  else
    echo this script is meant for trusty/xenial to determine whether sysv or systemd is in place. Modify accordingly
  fi
done
