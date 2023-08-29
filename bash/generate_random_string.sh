#!/bin/bash
#
# generates random string of alpha, num, special chars
#
# https://tecadmin.net/how-to-generate-random-string-in-bash/
# https://stackoverflow.com/questions/61590006/generate-random-string-where-it-must-have-a-special-character-in-shell-script

nchars=40
cat /dev/urandom | tr -dc 'a-zA-Z0-9!"#$%&'\''()*+' | fold -w $nchars | head -n1
