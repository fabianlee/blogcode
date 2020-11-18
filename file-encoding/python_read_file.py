#!/usr/bin/env python
import sys

# read file line by line
with open(sys.argv[1],"r") as file:
    for line in file:
        print(type(line))

