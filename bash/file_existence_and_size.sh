#!/bin/bash
#
# Test to make sure file exists and has size greater than 0 bytes
#
# blog: https://fabianlee.org/2022/03/27/bash-test-both-file-existence-and-size-to-avoid-signalling-success/
#

# test for existence and content
tempfile=$(mktemp)
[ -s $tempfile ] || echo "File $tempfile does not exist or is 0 bytes"

# now create, but it will have 0 bytes
touch $tempfile
[ -s $tempfile ] || echo "File $tempfile still does not pass test because it is 0 bytes"

echo testing > $tempfile
[ -s $tempfile ] || echo "This will not be invoked because file has content" && echo "File $tempfile passes test because it exists and has content"

# stat would error if file did not exist
filesize=$(stat -c%s $tempfile)
if [[ -f $tempfile && $filesize -gt 0 ]]; then
  echo "longer form of validating file existence and size of $tempfile at $filesize bytes"
fi

rm -f $tempfile
