#!/usr/bin/env python
#
# shows live output from invoked subprocess
# usually you only get output once process completes
#
# https://github.com/fabianlee/blogcode/blob/master/python/runProcessWithLiveOutput.py
#
import sys
import argparse
import subprocess
import shlex


# runs subprocess with Popen, but output only returned when process complete
def invoke_process_popen_blocking(command,shellType=False,stdoutType=subprocess.PIPE):
  try:
    process = subprocess.Popen(shlex.split(command),shell=shellType,stdout=stdoutType)
    (stdout,stderr) = process.communicate()
    print(stdout)
  except:
    print("ERROR {} while running {}".format(sys.exc_info()[1],command))


# runs subprocess with Popen/poll so that live stdout is shown
def invoke_process_popen_poll_live(command,shellType=False,stdoutType=subprocess.PIPE):
  try:
    process = subprocess.Popen(shlex.split(command),shell=shellType,stdout=stdoutType)
  except:
    print("ERROR {} while running {}".format(sys.exc_info()[1],command))
    return None
  while True:
    output = process.stdout.readline()
    if output == '' and process.poll() is not None:
      break
    if output:
      print output.strip()
  rc = process.poll()
  return rc



def main(argv):
  while True:
    cmd = raw_input("Execute which commmand [./loopWithSleep.sh]: ")
    if "quit"==cmd: break
    if ""==cmd: cmd="./loopWithSleep.sh"

    print("== invoke_process_popen_blocking  ==============")
    invoke_process_popen_blocking(cmd)
    
    print("== invoke_process_popen_poll_live  ==============")
    invoke_process_popen_poll_live(cmd)



if __name__=='__main__':main(sys.argv)
