#!/usr/bin/env python
"""
 Example of different ways to check if supplied string starts with list of values

 implementations:
   * tuple support of str.startswith
   * regex
   * list comprehension with filter
   * lambda filter
"""
import argparse
import re
import json
import sys

# simplified list of CIDR prefixes defined as private in RFC1918
PRIVATE_IP_LIST = ['10.','172.16.','192.168.']


###### MAIN #####################################

# parse incoming argument
ap = argparse.ArgumentParser()
ap.add_argument('ip', help="IP Address")
args = ap.parse_args()


print("**** TEST USING TUPLE SUPPORT IN str.startswith() *******")
if args.ip.startswith(tuple(PRIVATE_IP_LIST)):
  print("YES '{}' is a private IPv4 address".format(args.ip))
else:
  print("NO '{}' is not a private IPv4 address".format(args.ip))


print("**** TEST WITH REGEX *******")
myregex = "^" + "|^".join(PRIVATE_IP_LIST)
testmatch = re.match(myregex,args.ip)
if testmatch:
  print("YES '{}' is a private IPv4 address".format(args.ip))
else:
  print("NO '{}' is not a private IPv4 address".format(args.ip))


print("**** TEST WITH LIST COMPREHENSION FILTER *******")
cidr_matches = [ cidr for cidr in PRIVATE_IP_LIST if args.ip.startswith(cidr) ]
if len(cidr_matches)>0:
  print("YES '{}' is a private IPv4 address starting with this range: {}".format(args.ip,cidr_matches))
else:
  print("NO '{}' is not a private IPv4 address".format(args.ip))


print("**** TEST WITH LAMBDA FILTER *******")
cidr_matches = filter(lambda s: args.ip.startswith(s),PRIVATE_IP_LIST)
if len(cidr_matches)>0:
  print("YES '{}' is a private IPv4 address starting with this range: {}".format(args.ip,cidr_matches))
else:
  print("NO '{}' is not a private IPv4 address".format(args.ip))
