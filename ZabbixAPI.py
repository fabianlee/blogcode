#!/usr/bin/python

import logging
import sys
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

from zabbix.api import ZabbixAPI


# argument check
if len(sys.argv)<3:
  print "USAGE: zabbixURL user pass"
  print "EXAMPLE: http://127.0.0.1/zabbix Admin zabbix"
  sys.exit(1)

# simple parse for arguments
url = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
print "Going to connect to {} as {}".format(url,user)


# Create ZabbixAPI class instance
use_older_authenticate_method = False
zapi = ZabbixAPI(url, use_older_authenticate_method, user, password)

zversion = zapi.do_request('apiinfo.version')
print "Zabbix API version: {}".format(zversion['result'])

# https://www.zabbix.com/documentation/2.2/manual/api/reference/host/get
# Get all enabled hosts
print "----------------------------"
enabledhosts = zapi.do_request('host.get',
                          {
                              'filter': {'status': '0'},
                              'output': 'extend'
                          })
hostnames = [host['host'] for host in enabledhosts['result']]
print "All enabled hosts: {}".format(hostnames)


#https://www.zabbix.com/documentation/2.2/manual/appendix/api/template/get
# get all templates that contain 'Linux'
print "----------------------------"
templates = zapi.do_request('template.get', {'search': { 'host':'Linux'}, 'output':'extend'})
templates = [ template['host'] for template in templates['result']  ]
print "templates with Linux in their name: {}".format(templates)

# https://www.zabbix.com/documentation/2.2/manual/api/reference/trigger/get
# get latest 5 triggers
print "----------------------------"
triggers = zapi.do_request('trigger.get', { 'sortfield': ['triggerid'], 'sortorder': 'DESC', 'limit':'5', 'output':'extend'  }  )
for trigger in triggers['result']:
  print "TRIGGER {}: {}".format(trigger['triggerid'],trigger['description'])
