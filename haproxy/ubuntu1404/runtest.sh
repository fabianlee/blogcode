#!/bin/bash 

if [ "$#" -ne 2 ]; then
  echo Usage: restart\|reload\|reload-socket timeDelay
  exit 1
fi

echo Going to $1 every $2 seconds...
while true; 
  do sleep $2
  service haproxy $1
  echo done with haproxy $1 using initv, again in $2 seconds... 
done
