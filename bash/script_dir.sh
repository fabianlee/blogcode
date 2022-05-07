#!/bin/bash
# 
# Evaluates script directory
#
SCRIPT_DIR_REL=$(dirname ${BASH_SOURCE[0]})
SCRIPT_DIR_ABS=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "Relative script is located at: $SCRIPT_DIR_REL"
echo "Absolute script is located at: $SCRIPT_DIR_ABS"


echo ""
SCRIPT_NAME=$(basename $0)
echo "Script name: $SCRIPT_NAME"


echo ""
echo "Testing location using relative and absolute paths"
set -x
ls -l $SCRIPT_DIR_REL/$SCRIPT_NAME
ls -l $SCRIPT_DIR_ABS/$SCRIPT_NAME
