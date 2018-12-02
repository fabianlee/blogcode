#!/usr/bin/python
#
# Merges together template file and properties file using mako templating
# supporting calling Python function with arguments
#
# Prequisites Python2
# Ubuntu dependencies:
#   sudo apt-get install python-dev python-pip
#   pip install mako
#
#
import sys
import os.path
import traceback
import mako.runtime
from mako.template import Template
from mako.runtime import Context
from mako import exceptions
from StringIO import StringIO

# build a filename using author and basename, indent content
def get_quote_and_indent(author,basename,indent):
  with open(author + '-' + basename) as f:
    arr = f.readlines()
  firstTime=True
  buf = ""
  for line in arr:
    if not firstTime: buf = buf + ' '.ljust(indent)
    firstTime=False
    buf = buf + line
  return buf.rstrip()


# parse properties file
def parsePropertiesFile(filename):
  myprops = {}
  with open(filename,'r') as f:
    for line in f:
      line = line.rstrip()

      # skip invalid lines
      if "=" not in line: continue
      if line.startswith("#"): continue

      # split on first equal sign
      k,v = line.split("=",1)
      myprops[k.strip()] = v
      #print ("*{}={}*".format(k,v))

  return myprops



####### MAIN ########################

if len(sys.argv)<3:
  print("ERROR: needs two arguments")
  print("USAGE: templateFile propertiesFile")
  exit(1) 

if not os.path.isfile(sys.argv[1]):
  print("ERROR: cannot find template file")
  exit(2)
if not os.path.isfile(sys.argv[2]):
  print("ERROR: cannot find properties file")
  exit(2)


# get mako template
mytemplate = Template(filename=sys.argv[1])

# get properties
myprops = parsePropertiesFile(sys.argv[2])

# exposed functions
myprops['get_quote_and_indent'] = get_quote_and_indent

# create context and render
mako.runtime.UNDEFINED = "missing" # this does not seem to work!
buf = StringIO()
ctx = Context(buf,**myprops)
try:
  mytemplate.render_context(ctx)
except NameError:
  # default error handling does not show you missing name var
  sys.stderr.write(exceptions.text_error_template().render())
  exit(3)   

# output rendering
print (buf.getvalue())


