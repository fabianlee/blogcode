#!/bin/bash
#
# Test of file existence, size, and age
#
# blog: https://fabianlee.org/2023/05/10/bash-testing-if-a-file-exists-has-content-and-is-recently-modified/
#

# test for existence and content
cachefile=/tmp/cached_file.html
[ -s $cachefile ] || echo "File $cachefile does not exist or is 0 bytes"

find $cachefile -mtime -1 -size +0b 2>/dev/null | grep .
if [ $? -ne 0 ]; then
  echo "$cachefile needs to be downloaded"
  wget -q https://fabianlee.org/ -O $cachefile
  echo "DONE downloaded $cachefile"
else
  echo "$cachefile already exists, has content size, and was last modified in the last day"
fi

