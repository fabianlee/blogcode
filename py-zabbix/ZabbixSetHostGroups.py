#!/usr/bin/python
#
# Sets the hostgroups for a host. 
# Default action is to append hostgroup, but override parameter to truncate and set
#
# PREREQ:
#   sudo pip install py-zabbix --proxy http://<squid>:3128/
# OR preferred virtualenv
#   virtualenv py-zabbix
#   source py-zabbix/bin/activate
#   pip install py-zabbix
#
# 

import logging
import sys
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

from zabbix.api import ZabbixAPI


# argument check
if len(sys.argv)<5:
  print("Expecting 5 arguments, only got {}".format( len(sys.argv) ))
  print "USAGE: zabbixURL user pass host 'csvHostGroups' [--truncate]"
  print "EXAMPLE: http://127.0.0.1/zabbix myid P4ssword myHostname 'MyGroup One,MyGroup Two'"
  sys.exit(1)
doTruncate=False
if len(sys.argv)>=5 and sys.argv[6]=="--truncate":
  doTruncate=True
  print("Overriding default behavior, going to truncate all original hostgroups")
  

# simple parse for arguments
url = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
zhost = sys.argv[4]
csvHostGroups = sys.argv[5]
print "Going to connect to {} as {}".format(url,user)
print ("Will try to update zabbix hostgroups for {} with groups: {}".format(zhost,csvHostGroups))


# Create ZabbixAPI class instance
use_older_authenticate_method = False
zapi = ZabbixAPI(url, use_older_authenticate_method, user, password)

zversion = zapi.do_request('apiinfo.version')
print "Zabbix API version: {}".format(zversion['result'])


# first need to resolve the list of hostgroup names to proper ids
candidateGroupIds=[]
candidateGroups=csvHostGroups.split(",")
for candidateGroup in candidateGroups:
  print("Trying to resolve hostgroup: {}".format(candidateGroup))
  hostgroupResults = zapi.do_request('hostgroup.get', {'filter': { 'name': [ candidateGroup ]  } })
  #print("result {}, count {}".format( hostgroupResults['result'], len(hostgroupResults['result'])  ))
  if len(hostgroupResults['result'])==0:
    print("ERROR could not resolve hostgroup to id, does not exist")
    exit(2)
  else:
    print("hostgroup {} resolves to id {}".format( candidateGroup, hostgroupResults['result'][0]['groupid'] ))
    candidateGroupIds.append( { 'groupid' : hostgroupResults['result'][0]['groupid'] }  )
print("The final set of candidateGroupIds: {}".format( candidateGroupIds ))
 


# Get host with extended hostgroup output so we can determine which groups it is already a memember of
print "----------------------------"
hosts = zapi.do_request('host.get',
                          {
                              'selectGroups': 'extend',
                              'filter': {'host': zhost}
                          })
hostnames = [host['host'] for host in hosts['result']]
print "Found hosts: {}".format(hostnames)

# only want single host operations
if len(hostnames)>1:
  print("This name update is only meant for single hosts.")
  exit(1)
elif len(hostnames)==0:
  print("No hosts match that criteria, no updates made")
  exit(1)


for host in hosts['result']:
   # get current list of hostgroup
   print("About to update {} that has groups {}".format( host['host'], host['groups'] ))
   # construct list of { groupid: n } representing current groups
   currentgroups = []
   for g in host['groups']:
     currentgroups.append( { 'groupid': g['groupid'] } )
   print("curentgroups: {}".format( currentgroups ))

   # construct new set of groups which contains current groups + new candidates from command line
   # even if there are duplicates, the host.update request does not complain
   if doTruncate:
      print("TRUNCATE is enabled, so ignoring current hostgroups")
      newgroups = candidateGroupIds
   else:
     newgroups = currentgroups + candidateGroupIds

   # update host
   print("total set of hostgroup being set for this host: {}".format( newgroups ))
   updateRes = zapi.do_request('host.update',
                          {
                              'hostid': host['hostid'], 'groups': newgroups
                          })
   print updateRes




