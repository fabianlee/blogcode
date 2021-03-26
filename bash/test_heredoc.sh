#!/bin/bash
# https://tldp.org/LDP/abs/html/here-docs.html
# https://linuxize.com/post/bash-heredoc/
# https://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash
# https://stackoverflow.com/questions/7316107/how-to-split-strings-over-multiple-lines-in-bash
# escaping characters in heredoc, https://www.baeldung.com/linux/heredoc-herestring
# process substitution using >() http://www.gnu.org/software/bash/manual/bash.html#Process-Substitution
# best explanation of syntax of process substitution https://stackoverflow.com/questions/28927162/why-process-substitution-does-not-always-work-with-while-loop-in-bash#28927847

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
echo "*** append to file ***"
datestr=$(date +"%D %T")
cat <<EOF >> /tmp/appendint.txt
appended at $datestr
EOF




