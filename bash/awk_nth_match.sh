#!/bin/bash
#
# Uses awk to pull content after Nth match
#
# blog: https://fabianlee.org/2023/01/05/bash-awk-to-extract-nth-match-from-file-based-on-line-separator/
#

# create multiline string
read -r -d '' herecontent <<EOF
---
1 the quick brown fox
---
2  fox jumped and the fox jumped again
---
3 he could not jump the dog
---
the end
---
EOF

echo "==ALL CONTENT=="
echo "$herecontent"

echo ""
echo ""
echo "==2nd occurence of '---' till EOF=="
echo "$herecontent" | awk '/---/&&++k==2,/FOOBAR/'

echo ""
echo ""
echo "==2nd occurence of '---' till another '---' found" 
echo "$herecontent" | awk '/---/&&++k==2,/FOOBAR/' | tail -n+2 | awk '//&&++k==1,/---/'

echo ""
echo ""
echo "==3rd occurence of '---' till another '---' found" 
echo "$herecontent" | awk '/---/&&++k==3,/FOOBAR/' | tail -n+2 | awk '//&&++k==1,/---/'
