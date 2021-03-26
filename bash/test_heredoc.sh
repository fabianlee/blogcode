#!/bin/bash
#
# Examples with heredoc
#
# https://tldp.org/LDP/abs/html/here-docs.html
# https://linuxize.com/post/bash-heredoc/
# https://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash
# https://stackoverflow.com/questions/7316107/how-to-split-strings-over-multiple-lines-in-bash
# escaping characters in heredoc, https://www.baeldung.com/linux/heredoc-herestring
# http://www.linuxcommand.org/lc3_man_pages/readh.html

echo ""
echo "*** do not strip tabs ***"
cat <<EOF
a
	b
		c
EOF


echo ""
echo "*** strip tabs ***"
cat <<-EOF
a
	b
		c
EOF


echo ""
echo "*** put into variable ***"
read -r -d '' myheredoc1 <<EOF
a
        b
                c
EOF
echo "$myheredoc1"



echo ""
echo "*** with variables and subshell ***"
greeting="hello, world!"
cat <<EOF
$greeting
I am ${USER} in directory $(pwd)
$(for i in $(seq 1 9); do echo "hello $i"; done)
if you want a dollar sign, then \$escape it
last line
EOF


echo ""
echo "*** put into variable with subshell ***"
greeting="hello, world!"
# -r do not allow backslashes to escape, -d delimiter
read -r -d '' myheredoc2 <<EOF
$greeting
I am ${USER} in directory $(pwd)
$(for i in $(seq 1 9); do echo "hello $i"; done)
EOF
echo "$myheredoc2"


echo ""
echo "*** append to file /tmp/appendint.txt ***"
datestr=$(date +"%D %T")
cat <<EOF >> /tmp/appendint.txt
appended at $datestr
EOF




