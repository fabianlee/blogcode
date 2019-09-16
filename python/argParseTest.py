#!/usr/bin/env python
#
# Example usage of argparse library
#
# https://fabianlee.org/2019/09/14/python-parsing-command-line-arguments-with-argparse/
#
# USAGE
# ./argParseTest2.py 3 4
# ./argParseTest2.py 3 4 --op=mul
#
import sys
import argparse


# perform math operation, by default addition
def showMathResult(a,b,op="add",upper=False):
  res = 0
  if op=="mul":
    res= a * b
  else:
    res = a + b
  opDisplay = op.upper() if upper else op
  print("{} {} {} = {}".format(a,opDisplay,b,res))


def main(argv):

  # define arguments
  ap = argparse.ArgumentParser(description="Example using ArgParse library")
  ap.add_argument('a',type=int,help="first integer")
  ap.add_argument('b',type=int,help="second integer")
  ap.add_argument('-o','--op',default="add",choices=['add','mul'],help="operation=add|mul")
  ap.add_argument('-u','--upper',action="store_true",help="show uppercase")

  # parse args
  args = ap.parse_args()

  # print results of math operation
  showMathResult(args.a,args.b,args.op,args.upper)



if __name__=='__main__':main(sys.argv)
