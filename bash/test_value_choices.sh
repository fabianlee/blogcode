#!/bin/bash
#
# Test multiple choices for value
# https://
#
#

myval="$1"
[ -n "$myval" ] || { echo "ERROR please provide a parameter at the command line"; exit 1; }
echo "myval = $myval"

# if statement
#if [[ ! "$myval" == @("on"|"off") ]]; then
#  echo "ERROR value must either be 'on' or 'off'"; exit 2;
#fi

# one liner
[[ "$myval" == @("on"|"off") ]] || { echo "ERROR does not match"; exit 2; }


echo "SUCCESS value was '$myval'"
