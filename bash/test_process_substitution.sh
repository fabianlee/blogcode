#!/bin/bash
# 
# Bash process substitution examples i.e. <() and >()
# 
# process substitution using >() http://www.gnu.org/software/bash/manual/bash.html#Process-Substitution
# best explanation of syntax of process substitution https://stackoverflow.com/questions/28927162/why-process-substitution-does-not-always-work-with-while-loop-in-bash#28927847

echo ""
echo "*** put into variable ***"
read -r -d '' myheredoc1 <<EOF
a
b
c
EOF
echo "$myheredoc1"


echo ""
echo "*** using process substitution to feed 'while' standard input lines ***"
while read -r line || [ -n "$line" ]; do
  echo "line: $line"
done < <(echo "$myheredoc1")


# read needs [ -n ] evaluation if the last line does not have a newline
# if not provided, the last line will not process
# so either guarantee a newline at the end of input, or use this evaluation
echo ""
echo "*** (line separator) illustrating need to have last line end with newline or use evaluation ***"
while read -r line || [ -n "$line" ]; do
  echo "line: $line"
done < <(echo -en "line1\nline2\nline3")


# setting IFS to comma for single line input will not assist in read's parse, need delimiter set '-d'
#
# read needs [ -n ] evaluation or else last value will not be read. explanation:
#  (for multiline stdin) read will not parse last line if it doesn't end with newline
#  (for sigle line stdin) read will not parse last value if it doesn't end with char delimiter
echo ""
echo "*** (char separator) illustrating need to have last value end with char delimiter or use evaluation ***"
mycsvlist="a,b,c"
while read -r -d ',' val || [ -n "$val" ] ; do
  echo "val: $val"
done < <(echo "$mycsvlist")
#done <<EOD
#a,b,c
#EOD


echo ""
echo "*** using IFS and for loop for single line delimited parsing ***"
mycsvlist="a,b,c"
IFS=,
for val in $mycsvlist; do 
  echo "forval: $val"
done

