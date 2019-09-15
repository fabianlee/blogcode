#!/usr/bin/env python
#
# shows live output from invoked subprocess
# usually you only get output once process completes
#
import sys
import argparse
import subprocess
import shlex


# runs subprocess with poll so that live output is shown
def invoke_process_live_output(command,shellType=False,stdoutType=subprocess.PIPE):
  try:
    process = subprocess.Popen(shlex.split(command),shell=shellType,stdout=stdoutType)
  except:
    print("ERROR while running {}".format(command))
    return None
  while True:
    output = process.stdout.readline()
    if output == '' and process.poll() is not None:
      break
    if output:
      print output.strip()
  rc = process.poll()
  return rc


# runs subprocess, output returned when process exits
def invoke_process(command,shellType=False,stdoutType=subprocess.PIPE):
  try:
    process = subprocess.Popen(shlex.split(command),shell=shellType,stdout=stdoutType)
    stdout,stderr = process.communicate()
    print(stdout)
  except:
    print("ERROR while running {}".format(command))


def main(argv):
  while True:
    cmd = raw_input("Execute which commmand [./loopWithSleep.sh]: ")
    if "quit"==cmd: break
    if ""==cmd: cmd="./loopWithSleep.sh"

    print("== invoke_process  ==============")
    invoke_process(cmd)
    
    print("== invoke_process_live_output  ==============")
    invoke_process_live_output(cmd)



if __name__=='__main__':main(sys.argv)
