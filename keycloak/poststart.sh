#!/bin/bash

# default 
sleepSeconds="${1:-90}"
echo "going to sleep for $sleepSeconds"
sleep $sleepSeconds

cd /opt/keycloak/bin

# login
./kcadm.sh config credentials --realm master --user admin --password admin --server http://localhost:8080

# create realm
./kcadm.sh create realms -s realm=myrealm -s enabled=true -o

# create group
./kcadm.sh create groups -r myrealm -s name=mygroup

# creates user and set credentials
./kcadm.sh create users -r myrealm -s username=myuser -s enabled=true -s emailVerified=true -s email="first.last@kubeadm.local" -s firstName=first -s lastName=last
./kcadm.sh set-password -r myrealm --username myuser --new-password Password1! --temporary=false

# fetch user and group id
userid=$(./kcadm.sh get users -r myrealm -q username=myuser --fields id --format csv --noquotes)
groupid=$(./kcadm.sh get groups -r myrealm -q name=mygroup --fields id --format csv --noquotes)

# no groups yet, but add
./kcadm.sh update users/$userid/groups/$groupid -r myrealm -s realm=myrealm -s userId=$userid -s groupId=$groupid -n
./kcadm.sh get users/$userid/groups -r myrealm

# create client from json placed unto container (secret generated)
./kcadm.sh create clients -r myrealm -f /tmp/myclient.exported.json

# get secret for 'myclient' that was just generated upon import
# needed later for oauth2-proxy OAUTH2_PROXY_CLIENT_SECRET
clientid=$(./kcadm.sh get clients -r myrealm -q clientId=myclient --fields id --format csv --noquotes)
clientsecret=$(./kcadm.sh get clients/$clientid/client-secret -r myrealm --fields value --format csv --noquotes)
outfile=/tmp/keycloak.properties
touch $outfile
chmod 666 $outfile
echo "realm=myrealm" >> $outfile
echo "clientid=$clientid" >> $outfile
echo "clientsecret=$clientsecret" >> $outfile
