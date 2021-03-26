#!/bin/bash
#
# Using logic expressions as shortcut control statements
#
# blog: https://fabianlee.org/2020/10/14/bash-using-logic-expressions-as-a-shorthand-for-if-then-else-control
#

[ 1 -eq 1 ] && echo "correct, 1 does indeed equal 1" || echo "impossible!"
[ 1 -eq 0 ] && echo "impossible!" || echo "correct, 1 does not equal 0"

# if expression false, runs only third expression
[ 1 -eq 1 ] && { echo "1 does indeed equal 1";false; } || echo "1 does not equal 1 !!!"



# for assertions (file existence, variable population, etc)
[ 1 -eq 1 ] || { echo "ERROR this test should have been true"; exit 3; }


