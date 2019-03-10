#!/usr/bin/python
#
# WARNING!!!! this is a destructive operation
# Deletes host definitions from Zabbix entirely
# Searches based on wildcard, so you will get multiple hits if you only type the first few chars
#
# Prompts user manually before each deletion
#
# PREREQ:
#   sudo pip install py-zabbix --proxy http://<squid>:3128/
# OR preferred virtualenv
#   virtualenv py-zabbix
#   source py-zabbix/bin/activate
#   pip install py-zabbix
#

import logging
import sys
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

from zabbix.api import ZabbixAPI


# argument check
if len(sys.argv)<4:
  print("Expecting 4 arguments, only got {}".format( len(sys.argv) ))
  print "USAGE: zabbixURL user pass zabbixHostname"
  print "EXAMPLE: https://127.0.0.1/zabbix myid P4ssword myHostname"
  sys.exit(1)

# simple parse for arguments
url = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
zhost = sys.argv[4]
print "Going to connect to {} as {}".format(url,user)
print ("Will try to delete zabbix host {}".format(zhost))


# Create ZabbixAPI class instance
use_older_authenticate_method = False
zapi = ZabbixAPI(url, use_older_authenticate_method, user, password)

zversion = zapi.do_request('apiinfo.version')
print "Zabbix API version: {}".format(zversion['result'])

# Get host
print "----------------------------"
enabledhosts = zapi.do_request('host.get',
                          {
                              'search': {  'host': [zhost], 'searchWildcardsEnabled': 1   }
                          })
hostnames = [host['host'] for host in enabledhosts['result']]
print("Found candidate hosts for deletion: {}".format(hostnames))
print("")
print("")

# only want single host operations
if len(hostnames)==0:
  print("No hosts match that criteria, no deletions made")
  exit(1)


for host in enabledhosts['result']:
   answer = raw_input("delete {} with id {} [y/n]".format(host['host'],host['hostid']))
   if answer == "y":
     deleteRes = zapi.do_request('host.delete',
                          [
                              host['hostid']
                          ])
     print deleteRes
     print("deleted {} with id {}".format(host['host'],host['hostid']))
   else:
     print("skipped {}".format(host['hostid']))



