#!/bin/bash
#
# Test of file existence, size, and age
#
# blog: 
#

# test for existence and content
tempfile=/tmp/cached_file.html
[ -s $tempfile ] || echo "File $tempfile does not exist or is 0 bytes"

find $tempfile -mtime -1 -size +0b 2>/dev/null | grep .
if [ $? -ne 0 ]; then
  echo "$tempfile does not yet exist, going to download..."
  set -ex
  wget -q https://fabianlee.org/ -O $tempfile
  set +ex
  echo "DONE downloaded $tempfile"
else
  echo "$tempfile already exists, has content size, and was last modified in the last day"
fi

