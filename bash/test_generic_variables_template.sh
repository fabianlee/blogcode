#!/bin/bash
#
# using sed or envsubst to replace multiple variables in template
# blog: https://fabianlee.org/2021/05/29/bash-render-template-from-matching-bash-variables/
#

# declare variables
first="1"
animal="dog"

echo ""
echo "##########"
echo "Dollar sign templating style"
echo "##########"

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



echo ""
echo "##########"
echo "Dollar sign with curly bracket style"
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


echo ""
echo "##########"
echo "Using envsubst"
echo "##########"

export first
export animal
# only substitute listed variables
echo "$mytemplate" | envsubst '$first $animal'
# substitute all env variables
#echo "$mytemplate" | envsubst
