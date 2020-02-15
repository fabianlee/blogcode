#!/usr/bin/env python
#
# Creates test host, then a web scenarios and trigger for failure
# 
# PREREQ:
#   sudo pip install py-zabbix --proxy http://<squid>:3128/
# OR preferred virtualenv
#   virtualenv py-zabbix --no-download
#   source py-zabbix/bin/activate
#   pip install py-zabbix --proxy http://<squid>:3128/
# 

import logging
import os
import sys
import argparse
import time
import pprint
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

from zabbix.api import ZabbixAPI

scriptPath=os.path.dirname(os.path.abspath(__file__))
#sys.path.append(scriptPath + '/modules')


# argument check
if len(sys.argv)<7:
  print("Expecting 7 arguments, only got {}".format( len(sys.argv) ))
  print("USAGE: zabbixURL user pass host domain hostgroup priority")
  print("EXAMPLE: http://127.0.0.1/zabbix Admin zabbix mytesthost1 'Linux servers' 4")
  sys.exit(1)

# simple parse for arguments
url = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
zhost = sys.argv[4]
zgroup = sys.argv[5]
tpriority=int(sys.argv[6])

# create web scenario to google main landing page
service_name="google"
service_url="https://www.google.com"
service_expected_status="200"

  
print("Going to connect to {} as {}".format(url,user))

# pretty printer
pp = pprint.PrettyPrinter(indent=4)


def zabbix_get_host(zhost):
  # zabbix api to get zabbix host
  hostRes = zapi.do_request('host.get',
                          {
                              'filter': { 'host': [zhost] }
                          })
  #pp.pprint(hostRes)
  return hostRes

def zabbix_get_hostgroup(zgroup):
  # zabbix api to get hostgroup id
  # pull first using:  hostgroupResults['result'][0]['groupid']
  hostgroupResults = zapi.do_request('hostgroup.get', {'filter': { 'name': [ zgroup ]  } })
  return hostgroupResults

def zabbix_host_create(zhost,groupId):
  createRes = zapi.do_request('host.create',
    {
    'host': zhost,
    'interfaces': [{ 'type':1, 'main':1, 'useip':1, 'ip': '127.0.0.1', 'dns': zhost, 'port':'10050' }],
    'groups':  [{'groupid': groupId }],
    })
  return createRes

def zabbix_http_test_create(zfunc,hostid,service_name,service_url,service_expected_status):
    # makes zabbix api call out to create httptest object
    createRes = zapi.do_request(zfunc+'.create',
                      {
                          'name': service_name,
                          'hostid': hostid,
                          'steps': [
                            {
                              'name': service_name,
                              'url': service_url,
                              'status_codes': service_expected_status,
                              'no': 1
                            }
                          ]
                      })
    return createRes

def zabbix_trigger_get(hostid, service_name):
    # retrieves trigger
    getRes = zapi.do_request('trigger.get',{ 'hostids': hostid, 
           'output': 'extend', 
           'selectHosts': 'extent', 
           'expandExpression': True, 
           'expandDescription': True, 
           'skipDependent': False, 
           'filter': {'description': service_name } })
    return getRes

def zabbix_webfail_trigger_create(webTestId,service_name,tpriority):
    # makes zabbix api call to create trigger for http test
    trigRes = zapi.do_request('trigger.create',
                  {
                          'hostid': webTestId,
                          'description': service_name + ' is down',
                          'expression': '{' + zhost + ':web.test.fail[' + service_name + '].max(#3)}=1',
                          'priority': tpriority 
                  })
    return trigRes



################# MAIN ######################################3


# Create ZabbixAPI class instance
use_older_authenticate_method = False
zapi = ZabbixAPI(url, use_older_authenticate_method, user, password)

zversion = zapi.do_request('apiinfo.version')
print("Zabbix API version: {}".format(zversion['result']))
version_number = zversion['result']
# API func changed from 2.x to 3.x
zfunc = "httptest" if version_number>"2." else "webcheck"


# Get or create test host
print("============host creation===================")
hostRes = zabbix_get_host(zhost)
# only want single host operations
hostid = 0
if len(hostRes['result'])>1:
  print("This operation is only meant for single hosts.")
  exit(1)
elif len(hostRes['result'])==1:
  hostid = hostRes['result'][0]['hostid']
  print("found host {} with id {}".format(zhost,hostid))
elif len(hostRes['result'])==0:
  print("Need to create host")
  print("Trying to resolve hostgroup: {}".format(zgroup))
  hgRes = zabbix_get_hostgroup(zgroup)
  #pp.pprint(hgRes)
  if len(hgRes['result'])==0:
    print("ERROR could not resolve hostgroup {} to id, does not exist".format(zgroup))
    exit(2)
  groupId = hgRes['result'][0]['groupid']
  print("{} group resolves to id {}".format(zgroup,groupId ))
  createRes = zabbix_host_create(zhost,groupId)
  pp.pprint(createRes)
  hostid = createRes['result']['hostids'][0]



# creates web scenarios first
print("============web scenario creation===================")
# do http test creation
getRes = zapi.do_request(zfunc + '.get',{ 'hostids': hostid, 'filter': {'name': service_name} })
#pp.pprint(getRes)
if len(getRes['result'])<1:
    print("creating web scenario for {}".format(service_name))
    createRes = zabbix_http_test_create(zfunc,hostid,service_name,service_url,service_expected_status)
    #pp.pprint(createRes)
    webTestId = createRes['result']['httptestids'] # no arrayed result
    print("just created web test {} with id {}".format(service_name,webTestId))
else:
    print("found existing web test for {}".format(service_name))
    webTestId = getRes['result'][0]['httptestid']
print("")


print("DONE with web scenarios, moving on to triggers")


# create triggers
print("============trigger creation===================")
# do trigger creation for http test
print("going to check on trigger for http test id {}".format(webTestId))
getRes = zabbix_trigger_get(hostid,service_name+' is down')

#pp.pprint(getRes)
if len(getRes['result'])<1:
    print("creating trigger for {}".format(service_name))
    trigRes = zabbix_webfail_trigger_create(webTestId,service_name,tpriority)
    #pp.pprint(trigRes)
    time.sleep(1)
else:
    print("found existing trigger for {} id {}".format(service_name,getRes['result'][0]['triggerid']))
print("")


