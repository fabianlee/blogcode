#!/bin/bash
#
# Test multiple choices for value
# https://
#
#

myval="$1"
[ -n "$myval" ] || { echo "ERROR please provide a parameter at the command line"; exit 1; }
echo "myval = $myval"

# one liner
#[[ "$myval" == @("on"|"off") ]] || { echo "ERROR does not match"; exit 4; }

# if statement
#if [[ ! "$myval" == @("on"|"off") ]]; then
#  echo "ERROR value must either be 'on' or 'off'"; exit 3;
#fi

# use case statement
#case $myval in
#on|off)
#  ;;
#*)
#  echo "ERROR does not match"
#  exit 5;
#  ;;
#esac


echo "SUCCESS value was '$myval'"
