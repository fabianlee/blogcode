#!/bin/bash

# send back discovery key, list of all available array keys
# for a discovery type of "Zabbix agent"
cat << EOF
{ "data": [
  { "{#ITEMNAME}":"carrot" },
  { "{#ITEMNAME}":"banana" },
  { "{#ITEMNAME}":"lettuce" },
  { "{#ITEMNAME}":"tomato" }
]}
EOF

# now take advantage of this invocation to send back values
# build up list of values in /tmp/zdata.txt
agenthost="`hostname -f`"
zserver="myzabbix"
zport="10051"

cat /dev/null > /tmp/zdata.txt
for item in "carrot" "banana" "lettuce" "tomato"; do
  randNum="$(( (RANDOM % 30)+1 ))"
  echo $agenthost instock[$item] $randNum >> /tmp/zdata.txt
done

# push all these trapper values back to zabbix
zabbix_sender -vv -z $zserver -p $zport -i /tmp/zdata.txt >> /tmp/zsender.log 2>&1
