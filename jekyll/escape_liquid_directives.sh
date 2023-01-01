#!/bin/bash
# 
# Escapes double curly brackets and curly bracket percent that 
# would be interpreted as Liquid template directives

me=$(basename "$0")

for pattern in '{{' '}}' '{%' '%}'; do
  echo "PATTERN $pattern"
  for file in $(grep -srl $pattern); do
    if [[ "$file" == "$me" ]]; then
      #echo "SKIPPING self"
      continue
    fi

    echo "CLEANING $file"

    # clean up {% ... %}
    sed -i 's/{%/{\\%/g' $file
    sed -i 's/%}/\\%}/g' $file

    # clean up {{ ... }}
    sed -i 's/{{/\\{\\{/g' $file
    sed -i 's/}}/\\}\\}/g' $file
  done
done
