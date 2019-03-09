#
# for single user:
# pip install jsonpath-rw jsonpath-rw-ext --user
# for global:
# sudo -H pip install jsonpath-rw jsonpath-rw-ext
#
# OR preferred way through virtualenv
# virtualenv jsonpath
# source jsonpath/bin/activate
# pip install jsonpath-rw jsonpath-rw-ext
#

import json

from jsonpath_rw import jsonpath
#from jsonpath_rw import parse
# override parse for more capabilities
from jsonpath_rw_ext import parse

import jsonpath_rw_ext as jp

# does work, but extension makes it easier to just use 'match' and 'match1'
# so this goes unused now
def showJSONValues( json_data, expr ):
  jsonpath_expr = parse(expr)
  for match in jsonpath_expr.find(json_data):
    print(match.value)
  return


####### MAIN ##########################################################3

# read file from disk
json_file = open("squad.json")
json_data=json.load(json_file)

# show simple attribute, then values from array
print("Squad: {}".format( jp.match1("squadName",json_data) ) )
print("\nMembers:")
for name in jp.match("$.members[*].name",json_data):
  print("  {}".format(name))

# get all members, count length of returned list
print("\nCount members in list: {}".format( len(jp.match("$.members[*]",json_data ))  ))

# use extensions to provide direct count of number of members in array
print("Count members using len extension: {}".format( jp.match1("$.members.`len`",json_data  ) ))

# lookup array element given element inside array item
lookFor="Madame Uppercut"
print("\nPowers of {}".format(lookFor))
powers = jp.match1("members[?name='" + lookFor + "'].powers",json_data)
for power in powers:
  print("  {} has the power of {}".format(lookFor,power))

# find only array items that have element
print("\nAliases?")
memberHasAliases=jp.match("members[?(aliases)]",json_data)
for member in memberHasAliases:
  print("{} has aliases: {}".format( member['name'],member['aliases']  ))

# find only array items that have nested element
print("\nDoes anyone have an alias that contains 'Red'?")
memberHasAliases=jp.match("members[?(aliases[*]~'.*Red.*')]",json_data)
for member in memberHasAliases:
  print("{} has alias that contains 'Red', {}".format( member['name'],member['aliases']  ))

# find nested array items that contain word
print("\nWhich specific aliases contain the word 'Red'?")
for thisalias in jp.match("members[*].aliases[?(@~'.*Red.*')]",json_data):
  print(" Alias that contains 'Red': {}".format( thisalias ))

