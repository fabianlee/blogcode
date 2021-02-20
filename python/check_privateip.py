#!/usr/bin/env python
"""
 Example usage of sending tuple to String.startswith
 checks for IP addresses that start with private IPv4 ranges
"""
import argparse

# parse incoming argument
ap = argparse.ArgumentParser()
ap.add_argument('ip', help="IP Address")
args = ap.parse_args()

# list of word prefixes we want to try matching
private_ip_prefixes = ['192.','10.0.','172.16.']

# use tuple to 
if args.ip.startswith(tuple(private_ip_prefixes)):
  print("YES '{}' is a private IPv4 address starting with of one of these CIDR: {}".format(args.ip,private_ip_prefixes))
else:
  print("NO '{}' is not a private IPv4 address".format(args.ip))


