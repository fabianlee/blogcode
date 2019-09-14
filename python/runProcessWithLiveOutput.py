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
def invoke_process_live_output(command):
  try:
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE)
  except:
    print("ERROR while running {}".format(command))
    return
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
    
    print("== invoke_process_live_output  ==============")
    invoke_process_live_output(cmd)



if __name__=='__main__':main(sys.argv)
