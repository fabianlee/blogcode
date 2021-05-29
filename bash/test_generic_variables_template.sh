#!/bin/bash
#
# using sed to replace multiple variables in template
# blog: https://fabianlee.org/2021/05/29/bash-render-template-from-matching-bash-variables/
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

