#!/bin/bash
#
# Test values on same line using regex capture group
#

# lines are similar to kubectl output checking deployment desired replica count and true ready count
# when 2nd and 3rd column match, the deployment is fully healthy
# name,numberScheduled,numberReady
read -r -d '' csvlines <<EOF
largedeployment,32,27
otherdeployment,2,2
lastfailingone,2,0
EOF
echo "==CONTENT"
echo "$csvlines"
echo "==CONTENT"

# test each deployment to see if number desired equals number ready (col2==col3)
echo ""
for line in $csvlines ; do
  if [[ ! $(echo $line | grep -Po '.*,(\d+),\1') ]] ; then
    echo "FAIL $line"
  fi
done

