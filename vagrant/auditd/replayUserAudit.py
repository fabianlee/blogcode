#!/usr/bin/python3

import logging
import sys
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
import time
import os
import pwd
from datetime import date,timedelta,datetime
import subprocess
from pprint import pprint
import locale

# argument check
if len(sys.argv)<2:
  print ("USAGE: username [startDate=YYYY-MM-DD|today|yesterday|this-week]")
  print ("EXAMPLE: alice today")
  sys.exit(1)

# basic audit record fields
class AuditRecord:
  def __init__(self):
    ts = date.today()
    type = ""
    pid = 0
    ppid = 0
    euid = 0
    auid = 0
    # USER_CMD has response code and full command
    user_res = ""
    user_cmd = ""
    # EXECVE has full command
    execve_fullcmd = ""
    # SYSCALL has success (yes|no) and exit code
    # if success=no, then no EXECVE
    syscall_success = ""
    syscall_exit = 0

def callProcess(cmdstr):
  # search audit trail for userid
  print ("exec: {}".format(cmdstr))
  p = subprocess.Popen(cmdstr, stdout=subprocess.PIPE, shell=True)
  (output, err) = p.communicate()
  p_status = p.wait()
  return output, p_status, err

def splitAndMakeDict(str,splitBy,keyBy):
  dict = {}

  fields = str.split(splitBy)
  for f in fields:
    if keyBy in f:
      (k,v) = f.split(keyBy,1)
      dict[k] = v

  return dict


def concatDictArgs(dict,keyPrefix):
  retstr = ""
  for x in range(0,20):
    lookForKey = "{}{}".format(keyPrefix,x)
    #print ("looking for key {}".format(lookForKey))
    if lookForKey in dict:
      retstr = retstr + dict[lookForKey].strip('\"') + " "
  return retstr


def parseRecordList(rawList):
  output = rawList
  recList = []

  # iterate through record set, decode() necessary for python3
  recordlist = output.decode().split('----')
  for record in recordlist:

    # go through each line in a record
    auditrec = AuditRecord()
    linelist = record.split('\n')
    for line in linelist:
      if line.strip()=="----" or line.strip()=="" :
        continue
      if line.startswith("time->"):
        line = line[6:]
        datetime_object = datetime.strptime(line,'%a %b %d %H:%M:%S %Y')
        auditrec.ts = datetime_object.strftime('%Y-%m-%d %H:%M:%S')
      if line.startswith("type=EXECVE"):
        dict = splitAndMakeDict(line,' ','=')
        auditrec.execve_fullcmd = concatDictArgs(dict,'a')
      if line.startswith("type=USER_CMD") or line.startswith("type=SYSCALL") or line.startswith("type=USER_AUTH"):
        #print ("LINE {}".format(line))
        dict = splitAndMakeDict(line,' ','=')
        auditrec.type = dict['type']

        if 'uid' in dict:
          auditrec.uid = dict['uid']
        if 'pid' in dict:
          auditrec.pid = dict['pid']
        if 'ppid' in dict:
          auditrec.ppid = dict['ppid']
        if 'auid' in dict:
          auditrec.auid = dict['auid']
        if 'res' in dict:
          # USER_CMD success code
          #print ("found 'res' {}".format(dict['res']))
          auditrec.user_res = dict['res']
          # chop off last char if single quote
          if auditrec.user_res.endswith("'"):
            auditrec.user_res = auditrec.user_res[:-1]
        if 'success' in dict:
          auditrec.syscall_success = dict['success']
          if auditrec.syscall_success=="yes":
            auditrec.syscall_success = "success"
          elif auditrec.syscall_success=="no":
            auditrec.syscall_success = "fail" 
        if 'exit' in dict:
          auditrec.syscall_exit = dict['exit']
        if 'cmd' in dict:
          # cmd needs to be parsed manually
          index1 = line.index("cmd=")
          # up to next field with =
          index2 = line.index("=",index1+5)
          auditrec.user_cmd = line[index1:index2]
          # still need to chop off last field
          lastspace = auditrec.user_cmd.rindex(' ')
          auditrec.user_cmd = auditrec.user_cmd[:lastspace]

          # used when not using '-i'
          #try:
          #  auditrec.user_cmd = dict['cmd'].decode("hex")
          #except:
          #  auditrec.user_cmd = dict['cmd']
        if "msg=audit(" in line:
          # timestamp needs to be parsed manually
          index1 = line.index("msg=audit(")
          index2 = line.index(")",index1+10)
          auditrec.ts = line[index1+10:index2]


      if False: #line.startswith("type=SYSCALL"):
        # only SYSCALL, and no EXECVE if failure
        auditrec.type = "SYSCALL"
        dict = splitAndMakeDict(line,' ','=')
        auditrec.syscall_success = dict['success']
        if auditrec.syscall_success=="yes":
          auditrec.syscall_success = "success"
        elif auditrec.syscall_success=="no":
          auditrec.syscall_success = "fail" 
        auditrec.syscall_exit = dict['exit']
 
    # add record to returning list 
    recList.append(auditrec)

  return recList


############### MAIN ###############################

# simple parse for arguments
# use today startdate if not specified
username = sys.argv[1]
if len(sys.argv)<3:
  curlocale = locale.getdefaultlocale()
  locale.setlocale(locale.LC_TIME, curlocale)

  today = date.today()
  # hardcoding this date format means other locale would not work
  #startDate = today.strftime('%m/%d/%Y')
  startDate = time.strftime('%x')

  print ("Getting today date {} based on locale {}".format(startDate,curlocale))
else:
  startDate = sys.argv[2]
print ("startDate: " + startDate)

# must run as root/sudo to search audit reports
if os.geteuid()!=0:
  print ("ERROR - must run as root/sudo in order to search audit logs")
  sys.exit(2)

# get userid based on name
try:
  userid = pwd.getpwnam(username).pw_uid
except:
  print ("ERROR trying to resolve user id for {}".format(username))
  sys.exit(3)
print ("Going to trace commands for user {} with id {}".format(username,userid))

# search audit trail for userid
cmdstr="sudo ausearch -ui {} -i -ts {}".format(userid,startDate)
(output, pstatus, err) = callProcess(cmdstr)
#print ("Command return code: ", pstatus)

# iterate through record list 
print ("----Commands by {} starting at {}-----".format(username,startDate))
recList = parseRecordList(output)
for p in recList:
  if not hasattr(p,'type'):
    continue
  #pprint(vars(p))
  if p.type.startswith("USER_CMD"):
    print ("{:10s} {:10s} at {} by {}/{} executing {}".format(p.type,p.user_res,p.ts,p.auid,p.uid,p.user_cmd))
  elif p.type.startswith("SYSCALL"):
    print ("{:10s} {:10s} at {} by {}/{} executing {}".format(p.type,p.syscall_success,p.ts,p.auid,p.uid,p.execve_fullcmd if hasattr(p,"execve_fullcmd") else "?"))
  elif p.type.startswith("USER_AUTH"):
    print ("{:10s} {:10s} at {} by {}/{}".format(p.type,p.user_res,p.ts,p.auid,p.uid))


sys.exit(4)

for rec in recList:
  pprint(vars(rec))

  # search audit trail for process
  try:
    cmdstr="sudo ausearch -p {}".format(rec.user_pid)
    (output, pstatus, err) = callProcess(cmdstr)
    #print ("Command return code: ", pstatus)
    print ("PROCESS")
    pList = parseRecordList(output)
    for p in pList:
      #pprint(vars(p))
      print ("{} by {}/{} executing {}".format(p.user_res,p.ts,p.auid,p.uid,p.user_cmd))
  except AttributeError:
    pass # ok if pid does not exist for record

  # search audit trail for parent process
  try:
    cmdstr="sudo ausearch -pp {}".format(rec.user_ppid)
    (output, pstatus, err) = callProcess(cmdstr)
    #print ("Command return code: ", pstatus)
    print ("PARENT PROCESS")
    ppList = parseRecordList(output)
    for pp in ppList:
      pprint(vars(pp))
  except AttributeError:
    pass # ok if parent pid does not exist for record

  # search root audit trail for process
  try:
    cmdstr="sudo ausearch -k rootcmd -p {}".format(rec.user_ppid)
    (output, pstatus, err) = callProcess(cmdstr)
    #print ("Command return code: ", pstatus)
    print ("ROOT PROCESS")
    ppList = parseRecordList(output)
    for pp in ppList:
      pprint(vars(pp))
  except AttributeError:
    pass # ok if parent pid does not exist for record

  # search root audit trail for parent process
  try:
    cmdstr="sudo ausearch -k rootcmd -pp {}".format(rec.user_ppid)
    (output, pstatus, err) = callProcess(cmdstr)
    #print ("Command return code: ", pstatus)
    print ("ROOT PARENT PROCESS")
    ppList = parseRecordList(output)
    for pp in ppList:
      pprint(vars(pp))
  except AttributeError:
    pass # ok if parent pid does not exist for record

  print ("***REC******************************************\n\n") 




