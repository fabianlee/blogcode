#!/usr/bin/env python
#
# Use Decorators and introspection to see the arguments passed to a function
#
# https://fabianlee.org/2019/09/22/python-using-a-custom-decorator-to-inspect-function-arguments/
#
import sys
import argparse
import inspect
import functools

# custom decorator
def showargs_decorator(func):

    # updates special attributes e.g. __name__,__doc__
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
      # call custom inspection logic
      inspect_decorator(func,args,kwargs)
      # calls original function
      return func(*args, **kwargs)

    return wrapper

# inspect function name, parameters
def inspect_decorator(func,args,kwargs):
  funcname = func.__name__
  print("function {}()".format(funcname))

  # py3 vs py2
  if sys.version_info >= (3, 0):
    co = func.__code__ # py3
  else:
    co = func.func_code # py2

  # get description of function parameters expected
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
  return a+b


# perform math operation, variable number of positional args
@showargs_decorator
def addVarPositionalArgs(a,b,*args):
  # does not work unless decorator used functools.wrap
  #print("func name inside {}".format(showMathResultVarPositionalArgs.__name__))

  sum = a + b
  for n in args:
    sum += n

  return sum

# perform math operation, variable number of named args
@showargs_decorator
def addVarNamedArgs(a,b,**kwargs):

  sum = a + b
  for key,value in sorted(kwargs.items()):
    sum += value 

  return sum



def main(argv):

  # parse arguments
  ap = argparse.ArgumentParser(description="introspection using decorator")
  ap.add_argument('a',type=int,help="first integer")
  ap.add_argument('b',type=int,help="second integer")
  args = ap.parse_args()

  # no args function
  print("")
  showHelloWorld()

  # function with ints and optional params
  print("")
  res = showMathResult(args.a,args.b)
  print("final sum = {}".format(res))

  print("")
  res = addVarPositionalArgs(args.a,args.b,4,5,6)
  print("final sum = {}".format(res))

  print("")
  res = addVarNamedArgs(args.a,args.b,c=4,d=5,e=6)
  print("final sum = {}".format(res))





  



if __name__=='__main__':main(sys.argv)
