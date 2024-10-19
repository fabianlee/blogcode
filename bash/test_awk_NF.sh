#!/bin/bash
#
# Example of using awk NF conditional to avoid error
# blog: https://fabianlee.org/2024/10/18/bash-resolving-awk-run-time-error-negative-field-index/
#


read -r -d '' myheredoc1 <<EOF
/a/b/c/file1-abc.txt
# comment
/file2-abc.txt
EOF
echo "$myheredoc1"

echo ""
echo ""
echo "$myheredoc1" | awk -F/ '{printf "last 2 dir paths = %d %s/%s\n",NF,(NF>2 ? $(NF-2):"None"),(NF>1 ? $(NF-1):"None") }'

echo ""
echo ""
echo "$myheredoc1" | awk -F/ '{printf "last 2 dir paths = %d %s/%s\n",NF,$(NF-2),$(NF-1) }'

