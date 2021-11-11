#!/usr/bin/env python
#
# How to get the latest modified file in a directory matching a pattern
#
import os
import glob

# get list of files that matches pattern
pattern="/tmp/*"
files = list(filter(os.path.isfile, glob.glob(pattern)))

# sort by modified time
files.sort(key=lambda x: os.path.getmtime(x))

# get last item in list
lastfile = files[-1]

print("Most recent file matching {}: {}".format(pattern,lastfile))
