#!/bin/bash
# 
# Tests whether script was invoked as source
# blog: https://fabianlee.org/2022/05/07/bash-test-whether-script-is-invoked-directly-or-sourced/
#

# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced -eq 0 ]; then
  echo "ERROR, this script is meant to be sourced.  Try 'source ./is_script_sourced.sh'"
  exit 1
fi

export FOO=bar
echo "'FOO' env var exported"
