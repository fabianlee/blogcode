#!/bin/bash
# 
# Shows how to use printf for padding
#

# pading string
padding="......................................"

printf  "==== TABLE OF CONTENTS ===========================\n"

title="1) Chapter one - the intro"
printf "%s%s %s\n" "$title" "${padding:${#title}}" "Page 1"

title="2) Chapter two - summary"
printf "%s%s %s\n" "$title" "${padding:${#title}}" "Page 4"

title="3) Chapter three - explanation"
printf "%s%s %s\n" "$title" "${padding:${#title}}" "Page 12"

title="4) Conclusion"
printf "%s%s %s\n" "$title" "${padding:${#title}}" "Page 16"

