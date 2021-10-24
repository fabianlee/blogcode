#!/usr/bin/env python
# originally from https://techtldr.com/convert-json-to-dot-notation-with-python/
#
# Takes json and produces dot notation paths
#
# If you need to convert YAML to json use 'yq eval - -o=json -P'

import json
import sys

def getKeys(val, old=""):
    if isinstance(val, dict):
        for k in val.keys():
            getKeys(val[k], old + "." + str(k))
    elif isinstance(val, list):
        for i,k in enumerate(val):
            getKeys(k, old + "." + str(i))
    else:
        print("{} : {}".format(old,str(val)))

data=json.load(sys.stdin)
getKeys(data)
