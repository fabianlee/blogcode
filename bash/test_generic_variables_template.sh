#!/bin/bash
#
# using sed to replace multiple variables in template
#
#

# declare variables
first="1"
animal="dog"

# create template, heredoc without var evaluation
read -r -d '' mytemplate <<'EOF'
this is $first
the $animal goes woof
EOF

# create list of sed replacements
sedcmd=''
for var in first animal ; do
  printf -v sc 's/$%s/%s/;' $var "${!var//\//\\/}"
  sedcmd+="$sc"
done
sed -e "$sedcmd" <(echo "$mytemplate")


echo "##########"
echo "Alternative templating style"
echo "##########"


# allow var evaluation, so escape dollar sign
read -r -d '' mytemplate <<EOF
this is \${first}
the \${animal} goes woof
EOF

# create list of sed replacements
sedcmd=''
for var in first animal ; do
  printf -v sc 's/${%s}/%s/;' $var "${!var//\//\\/}"
  sedcmd+="$sc"
done
sed -e "$sedcmd" <(echo "$mytemplate")

