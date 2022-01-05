#!/bin/bash
#
# use awk to create single aggregated yaml
# use environment variable substitution
#
# blog: 
#


# declare variables
export first="1"
export animal="dog"

awk 'FNR==1 {print "---" "\n# source:" FILENAME }{print $0}' yamlfiles/*.yaml | envsubst '$first $animal'

