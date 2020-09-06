#!/bin/bash
# 
# example showing how to:
#   show all the lines before a regex match
#   show all the lines after a regex match
#

read -r -d '' lines <<EOF
ape swings
frog jumps logs
dog barks at squirrels
bear roars
zebra grazes
EOF
echo "Here are all the lines in total"
echo "$lines"
echo ""

echo "Here are all the lines after dog regex"
echo "$lines" | sed '0,/^dog.*/d'
echo ""
echo "Here are all the lines before dog regex"
echo "$lines" | sed '/^dog.*/q' | head -n -1
#| head -n -1


