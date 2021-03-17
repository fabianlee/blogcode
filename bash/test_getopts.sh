#!/bin/bash


# check for optional values
# https://stackoverflow.com/questions/18414054/reading-optarg-for-optional-flags#18414091

# ensure sure option has value
function enforce_mandatory_value() {
  str_opt="$1"
  str_optarg="$2"
  varname="$3"
  if [[ "${OPTARG}" =~ ^- ]]; then
    echo "$str_opt option must have value specified"
    exit 3
  else
    printf -v "${varname}" '%s' "${OPTARG}"
  fi
}
# if option is bare flag, uses default
function allow_optional_value() {
  str_opt="$1"
  str_optarg="$2"
  varname="$3"
  defaultval="$4"
  if [[ "${OPTARG}" =~ ^- ]]; then 
    echo "$str_opt value is optional, so setting default"
    printf -v "${varname}" '%s' "${defaultval}"
    # rollback OPTIND if it accidently ate next option
    OPTIND=$((OPTIND - 1))
  else
    printf -v "${varname}" '%s' "${OPTARG}"
  fi
}
# must be positive integer
function enforce_integer() {
  str_opt="$1"
  thevalue="$2"
  [[ $thevalue =~ ^([[:digit:]]*)$ ]] || { 
    echo "ERROR only integers allowed for '$str_opt' not value $thevalue"; 
    exit 3; 
  }
}
# must be one of the values in space separated list
function enforce_enumeration() {
  str_opt="$1"
  thevalue="$2"
  valid_values="$3"
  echo "$valid_values" | grep -q -w "$thevalue" > /dev/null || { 
    echo "ERROR only valid values for '$str_opt' are one of: '$valid_values'"; 
    exit 3; 
  }
}


function show_usage {
  echo "./$(basename $0) [-h] -a <int> -b <int> [-o add|mul]"
  echo -e "-h\thelp"
  echo -e "-a\tfirst number"
  echo -e "-b\tsecond number"
  echo -e "-o\teither add or mul (default is add)"
}

# default operation is addition, allow override to multiplication through option
op="add"
c=99
d=""

# colon as first char means program will provide its own error messages
optionArgs=":ha:b:c:d::eo:"
while getopts "$optionArgs" arg; do
  case "${arg}" in
    h)
      show_usage
      exit 1
      ;;
    a)
      enforce_mandatory_value $arg $OPTARG a
      enforce_integer $arg $a
      ;;
    b)
      enforce_mandatory_value $arg $OPTARG b
      enforce_integer $arg $b
      ;;
    c)
      enforce_mandatory_value $arg $OPTARG c
      ;;
    d)
      echo "doing d..."
      allow_optional_value $arg $OPTARG d ""
      ;;
    e)
      e="$OPTARGS"
      echo "e hit $e"
      ;;
    o)
      enforce_mandatory_value $arg $OPTARG o
      enforce_enumeration $arg "$o" "add mul"
      if [[ "$o" == "mul" ]]; then
        op="mul"
      fi
      ;;
    # getopts makes value "?" if flag unrecognized
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 3
      ;;
    :)
      # this OOTB check only works when option is last
      # which is why we use enforce_mandatory_value
      echo "$0: Must supply an argument to -$OPTARG." >&2
      exit 3
      ;;
  esac
done
shift $((OPTIND -1))

# show values after processing getopts
echo "a is $a"
echo "b is $b"
echo "c is $c"
echo "d is $d"
echo "e is $e"

# check for mandatory args
if [ -z "$a" ] || [ -z "$b" ]; then
    show_usage
    exit 5
fi


# any positional arguments left?
shift $((OPTIND - 1))
if (($# == 0))
then
    echo "No positional arguments specified"
else
  echo "additional positional args: " $@
fi


# perform mathematical operation on numbers
if [ "$op" == "add" ]; then
  echo "$a + $b = $((a+b))"
elif [ "$op" == "mul" ]; then
  echo "$a * $b = $((a*b))"
else
  echo "ERROR did not recognize operation '$op'"
fi

