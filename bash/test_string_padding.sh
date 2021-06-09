#!/bin/bash
# 
# Shows how to use printf for padding
#
# blog: https://fabianlee.org/2021/06/09/bash-using-printf-to-display-fixed-width-padded-string/
#

# maximum length of label
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

