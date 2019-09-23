#!/usr/bin/env python
"""
 Use introspection to see the arguments passed to a function

 https://fabianlee.org/2019/09/21/python-using-inspection-to-view-the-parameters-of-a-function/
"""
import sys
import argparse
import inspect


def inspect_simple(frame):
    """ inspect function name, parameters """
    funcname = frame.f_code.co_name
    print("function {}()".format(funcname))

    # pull tuple from frame
    args, args_paramname, kwargs_paramname, values = inspect.getargvalues(
        frame)

    # show formal parameters
    for i in (args if args is not None else []):
        print("\t{}={}".format(i, values[i]))

    # show positional varargs
    if args_paramname is not None:
        varglist = values[args_paramname]
        for v in (varglist if varglist is not None else []):
            print("\t*{}={}".format(args_paramname, v))

    # show named varargs
    if kwargs_paramname is not None:
        varglist = values[kwargs_paramname]
        for k in (sorted(varglist) if varglist is not None else []):
            print("\t*{} {}={}".format(kwargs_paramname, k, varglist[k]))


def show_hello_world_basic(name="World"):
    """simplest example of instrospection without helper method"""
    myframe = inspect.currentframe()
    args, _, _, values = inspect.getargvalues(myframe)
    # function name could also have been pulled from stack
    # inspect.stack()[0][3]
    funcname = myframe.f_code.co_name
    print("function {}()".format(funcname))
    for i in (args if not args is None else []):
        print("\t{}={}".format(i, values[i]))
    print("Hello {}!".format(name))


def show_hello_world_inspect():
    """simple no arg function"""
    inspect_simple(inspect.currentframe())
    print("Hello, World!")



def show_math_result(a, b, show_lower=True):
    """perform math operation, by default addition"""
    inspect_simple(inspect.currentframe())
    op_display = "plus" if show_lower else "PLUS"
    print("{} {} {} = {}".format(a, op_display, b, a + b))
    return a+b


def sum_var_positional_args(a, b, *args):
    """perform math operation, variable number of positional args"""
    inspect_simple(inspect.currentframe())

    thesum = a + b
    for n in args:
        thesum += n

    return thesum


def sum_var_named_args(a, b, **kwargs):
    """perform math operation, variable number of named args"""
    inspect_simple(inspect.currentframe())

    thesum = a + b
    for key, value in sorted(kwargs.items()):
        thesum += value

    return thesum


def main(argv):

    # parse arguments
    ap = argparse.ArgumentParser(description="Example using introspection")
    ap.add_argument('a', type=int, help="first integer")
    ap.add_argument('b', type=int, help="second integer")
    args = ap.parse_args()

    # simplest example of introspection
    show_hello_world_basic("World")

    # no args function
    print("")
    show_hello_world_inspect()

    # function with ints and optional params
    print("")
    show_math_result(args.a, args.b)

    # function wth variable number of positional args
    print("")
    res = sum_var_positional_args(args.a, args.b, 4, 5, 6)
    print("final sum = {}".format(res))

    # function with variable number of named args
    print("")
    res = sum_var_named_args(args.a, args.b, c=4, d=5, e=6)
    print("final sum = {}".format(res))


if __name__ == '__main__':
    main(sys.argv)
