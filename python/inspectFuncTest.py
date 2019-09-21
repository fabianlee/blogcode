#!/usr/bin/env python
#
# Use introspection to see the arguments passed to a function
#
# https://fabianlee.org/2019/09/20/
#
#
import sys
import argparse
import inspect


# inspect function name, parameters
def inspect_simple(frame):
  # pull tuple from frame
  args,args_paramname,kwargs_paramname,values = inspect.getargvalues(frame)

  # stack param could be used to pull function name
  #funcname = stack[0][3]
  funcname = frame.f_code.co_name
  print("function {}()".format(funcname))

  # show static parameters
  for i in (args if not args is None else []):
    print("\t{}={}".format(i,values[i]))

  # show positional varargs
  if args_paramname is not None:
    varglist = values[args_paramname]
    for v in (varglist if not varglist is None else []):
      print("\t*{}={}".format(args_paramname,v))

  # show named varargs
  if kwargs_paramname is not None:
    varglist = values[kwargs_paramname]
    for k in (sorted(varglist) if not varglist is None else []):
      print("\t*{} {}={}".format(kwargs_paramname,k,varglist[k]))


# simplest example of instrospection without helper method
def showHelloWorldBasic(name="World"):
  myframe = inspect.currentframe()
  args,_,_,values = inspect.getargvalues(myframe)
  # function name could also have been pulled from stack
  # inspect.stack()[0][3])
  funcname = myframe.f_code.co_name
  print("function {}()".format(funcname))
  for i in (args if not args is None else []):
    print("\t{}={}".format(i,values[i]))
  print("Hello {}!".format(name))
  

# simple no arg function
def showHelloWorldInspect():
  inspect_simple(inspect.currentframe())
  print("Hello, World!")

# perform math operation, by default addition
def showMathResult(a,b,showLower=True):
  inspect_simple(inspect.currentframe())
  opDisplay = "plus" if showLower else "PLUS"
  print("{} {} {} = {}".format(a,opDisplay,b,a+b))


# perform math operation, variable number of positional args
def showMathResultVarPositionalArgs(a,b,*args):
  inspect_simple(inspect.currentframe())

  sum = a + b
  sys.stdout.write("{} + {}".format(a,b))

  for n in args:
    sys.stdout.write(" + " + str(n))
    sum += n

  sys.stdout.write(" = " + str(sum))
  sys.stdout.write("\n")
  sys.stdout.flush()

# perform math operation, variable number of named args
def showMathResultVarNamedArgs(a,b,**kwargs):
  inspect_simple(inspect.currentframe())

  sum = a + b
  sys.stdout.write("{} + {}".format(a,b))

  for key,value in sorted(kwargs.items()):
    sys.stdout.write(" + " + str(value))
    sum += value 

  sys.stdout.write(" = " + str(sum))
  sys.stdout.write("\n")
  sys.stdout.flush()



def main(argv):

  # parse arguments
  ap = argparse.ArgumentParser(description="Example using introspection")
  ap.add_argument('a',type=int,help="first integer")
  ap.add_argument('b',type=int,help="second integer")
  args = ap.parse_args()

  # simplest example of introspection
  showHelloWorldBasic("World")

  # no args function
  print("")
  showHelloWorldInspect()

  # function with ints and optional params
  print("")
  showMathResult(args.a,args.b)
  
  # function wth variable number of positional args
  print("")
  showMathResultVarPositionalArgs(args.a,args.b,4,5,6)

  # function with variable number of named args
  print("")
  showMathResultVarNamedArgs(args.a,args.b,c=4,d=5,e=6)




if __name__=='__main__':main(sys.argv)
