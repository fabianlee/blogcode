#!/bin/bash

# will be replaced by Terraform templating
default_args="${params_for_inline_command}"

# double dollar sign is escape so Terraform does not replace
final_args="$${@:-$default_args}"
echo "final_args = $final_args"

for myarg in $final_args; do
  echo "arg is $myarg"
done

echo "Illustrating a way to inject Terraform list variables via templating"
%{ for param in params ~}
echo "list item param is ${param}"
%{ endfor ~}
