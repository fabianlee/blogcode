#!/usr/bin/env python
#
# Use Decorators and introspection to see the arguments passed to a function
#
#
#
import sys
import argparse
import inspect
import functools

# decorator that injects itself into each function
def showargs_decorator(func):

    # updates special attributes e.g. __name__,__doc__
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
      # call inspection logic
      inspect_decorator(func,args,kwargs)
      # calls original function
      func(*args, **kwargs)

    return wrapper

# inspect function name, parameters
def inspect_decorator(func,args,kwargs):
  funcname = func.__name__
  print("function {}()".format(funcname))

  # python3
  if sys.version_info >= (3, 0):
    co = func.__code__ # py3
  else:
    co = func.func_code # py2

  argspec = inspect.getargspec(func)

  # go through each position based argument        
  counter = 0
  if argspec.args and type(argspec.args is list):
    for arg in args:
      # when you run past the formal positional arguments
      try:
        print(str(argspec.args[counter]) + "=" + str(arg))
        counter+=1
      except IndexError as e:
        # then fallback to using the positional varargs name
        if argspec.varargs:
          varargsname = argspec.varargs
          print("*" + varargsname + "=" + str(arg))
        pass

  # finally show the named varargs
  if argspec.keywords:
    kwargsname = argspec.keywords
    for k,v in kwargs.items():
      print("**" + kwargsname + " " + k + "=" + str(v))

 


@showargs_decorator
def showHelloWorld():
  print("Hello, World!")

# perform math operation, by default addition
@showargs_decorator
def showMathResult(a,b,showLower=True):
  opDisplay = "plus" if showLower else "PLUS"
  print("{} {} {} = {}".format(a,opDisplay,b,a+b))


# perform math operation, variable number of positional args
@showargs_decorator
def showMathResultVarPositionalArgs(a,b,*args):

  sum = a + b
  sys.stdout.write("{} + {}".format(a,b))

  for n in args:
    sys.stdout.write(" + " + str(n))
    sum += n

  sys.stdout.write(" = " + str(sum))
  sys.stdout.write("\n")
  sys.stdout.flush()

# perform math operation, variable number of named args
@showargs_decorator
def showMathResultVarNamedArgs(a,b,**kwargs):

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

  # no args function
  print("")
  showHelloWorld()

  # function with ints and optional params
  print("")
  showMathResult(args.a,args.b)

  print("")
  showMathResultVarPositionalArgs(args.a,args.b,4,5,6)

  print("")
  showMathResultVarNamedArgs(args.a,args.b,c=4,d=5,e=6)





  



if __name__=='__main__':main(sys.argv)
