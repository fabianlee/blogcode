#!/usr/bin/env python
#
# Example usage of argparse library
#
# https://fabianlee.org/2019/09/14/python-parsing-command-line-arguments-with-argparse/
#
import sys
import argparse


# perform math operation, by default addition
def showMathResult(a,b,op="add"):
  res = 0
  if op=="mul":
    res= a * b
  else:
    res = a + b
  print("{} {} {} = {}".format(a,op,b,res))


def main(argv):

#  # define arguments
  ap = argparse.ArgumentParser(description="Example using ArgParse library")
  ap.add_argument('a',type=int,help="first integer")
  ap.add_argument('b',type=int,help="second integer")
  ap.add_argument('-o','--op',default="add",help="operation=add|mul")

  # parse args
  args = ap.parse_args()

  # print results of math operation
  showMathResult(args.a,args.b,args.op)



if __name__=='__main__':main(sys.argv)
