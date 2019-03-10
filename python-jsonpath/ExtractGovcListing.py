#
# Parses output of "govc ls -l -json <vmpath>"
# and extracts basic information on cpu,mem,disk,network
#
# PREREQUISITES:
#   jsonpath-rw and jsonpath-rw-ext modules
#
#   virtualenv jsonpath
#   source jsonpath/bin/activate
#   pip install jsonpath-rw jsonpath-rw-ext
#

import sys
import os.path
import json

from jsonpath_rw import jsonpath
#from jsonpath_rw import parse
# override parse for more capabilities
from jsonpath_rw_ext import parse

import jsonpath_rw_ext as jp

# credit for this function goes to Dave
# https://stackoverflow.com/questions/33750233/convert-cidr-to-subnet-mask-in-python#43904598
#
def cidr_to_netmask(cidr):
  cidr = int(cidr)
  mask = (0xffffffff >> (32 - cidr)) << (32 - cidr)
  return (str( (0xff000000 & mask) >> 24) + '.' +
          str( (0x00ff0000 & mask) >> 16) + '.' +
          str( (0x0000ff00 & mask) >> 8)  + '.' +
          str( (0x000000ff & mask)))

# quick test to see if string is IPv4 or IPv6
def isIPv4(str):
  return str.count(".")==3


####### MAIN ##########################################################3

# argument check
if len(sys.argv)<=1:
  print("Expected 1 arguments, found {}".format(len(sys.argv)-1))
  print("USAGE: govcJSONFile")
  print("EXAMPLE: myvm.json")
  exit(1)
filename = sys.argv[1]

# validate file existence
if not os.path.isfile(filename):
  print("ERROR could not find json file with govc output {}".format(filename))
  exit(2)

# read file from disk
json_file = open(filename)
json_data=json.load(json_file)

# name of VM
print("name: {}".format( jp.match1("elements[*].Object.Config.Name",json_data) ))
print("State: {}".format( jp.match1("elements[*].Object.Runtime.PowerState",json_data) ) )
print("OS: {}".format( jp.match1("elements[*].Object.Summary.Config.GuestFullName",json_data) ))

# get path to vm, break apart
fullPath=jp.match1("elements[*].Path",json_data)
fullPath=fullPath[0:fullPath.rfind("/")]
pathsplit=fullPath.split("/")
print("Full path: {}".format( fullPath ))
print("Parent Folder: {}".format( pathsplit[len(pathsplit)-1] ))

# show IP address and cidr/netmask
print("Default IpAddress: {}".format( jp.match1("elements[*].Object.Guest.IpAddress",json_data) ) )

hasNet=jp.match1("elements[*].Object.Guest.Net",json_data)
if hasNet:
  for IpAddress in jp.match("elements[*].Object.Guest.Net[*].IpConfig.IpAddress[*]",json_data):
    cidr=IpAddress['PrefixLength'] 
    if isIPv4(IpAddress['IpAddress']):
      print("  IPv4 {}/{} netmask {}".format( IpAddress['IpAddress'],cidr,cidr_to_netmask(cidr)  ))
    else:
      print(" IPv6 {}/{}".format( IpAddress['IpAddress'],cidr ) )

else:
  print("There are no network elements in Guest, VM might be powered off")

# memory/cpu
#print("MaxMemoryUsage: {}".format( jp.match1("elements[*].Object.Runtime.MaxMemoryUsage",json_data) ) )
print("MemorySizeMB: {}".format( jp.match1("elements[*].Object.Summary.Config.MemorySizeMB",json_data) ) )
print("CPU: {}".format( jp.match1("elements[*].Object.Summary.Config.NumCpu",json_data) ) )

# disks
for disk in jp.match("elements[*].Object.Config.Hardware.Device[?CapacityInKB>0]",json_data):
  capacityGB = (disk['CapacityInKB']/1024/1024)
  filestore = disk['Backing']['FileName'].split(' ')
  print("DISK capacity is {}Gb on {}".format( capacityGB,filestore[0] ))


