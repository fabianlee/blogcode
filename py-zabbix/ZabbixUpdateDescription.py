#!/usr/bin/python
#
# Updates the description of a host in zabbix
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
if len(sys.argv)<5:
  print("Expecting 5 arguments, only got {}".format( len(sys.argv) ))
  print "USAGE: zabbixURL user pass host newDescrip"
  print "EXAMPLE: http://127.0.0.1/zabbix myid P4ssword myHostname 'new-visible-name'"
  sys.exit(1)

# simple parse for arguments
url = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
zhost = sys.argv[4]
name = sys.argv[5]
print "Going to connect to {} as {}".format(url,user)
print ("Will try to update zabbix host {} with a visible name of {}".format(zhost,name))


# Create ZabbixAPI class instance
use_older_authenticate_method = False
zapi = ZabbixAPI(url, use_older_authenticate_method, user, password)

zversion = zapi.do_request('apiinfo.version')
print "Zabbix API version: {}".format(zversion['result'])

# Get host
print "----------------------------"
enabledhosts = zapi.do_request('host.get',
                          {
                              'filter': {'host': zhost}
                          })
print enabledhosts
print ("==========")
hostnames = [host['host'] for host in enabledhosts['result']]
print "Found hosts: {}".format(hostnames)

# only want single host operations
if len(hostnames)>1:
  print("This name update is only meant for single hosts.")
  exit(1)
elif len(hostnames)==0:
  print("No hosts match that criteria, no updates made")
  exit(1)


for host in enabledhosts['result']:
   print("About to update {} with visible name {}".format(host['host'],name))
   updateRes = zapi.do_request('host.update',
                          {
                              'hostid': host['hostid'], 'host': host['host'], 'name': name 
                          })
   print updateRes

