#!/usr/bin/env python
#
# minor modifications to make python3 safe
# https://stackoverflow.com/questions/33489209/print-unique-json-keys-in-dot-notation-using-python

import json
import sys

json_data = json.load(sys.stdin)

def walk_keys(obj, path = ""):
    if isinstance(obj, dict):
        for k, v in obj.items(): # iteritems is py2 only
            for r in walk_keys(v, path + "." + k if path else k):
                yield r
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            s = ""
            for r in walk_keys(v, path if path else s):
                yield r
    else:
        yield path

all_keys = list(set(walk_keys(json_data)))

print('\n'.join([str(x) for x in sorted(all_keys)]))

