#!/bin/bash
#
# This is run inside a Kubernetes container
# as a bootstrap for our OAuth2 Client
#


# creates user, set credentials, adds to group
function create_user() {
  username=$1
  group=$2
  email="$3"
  firstName="$4"
  lastName="$5"

  if [[ -n "$firstName" && -n "$lastName" ]]; then
    ./kcadm.sh create users -r myrealm -s username=$username -s enabled=true -s emailVerified=true -s email="$email" -s firstName=$firstName -s lastName=$lastName
  else
    ./kcadm.sh create users -r myrealm -s username=$username -s enabled=true -s emailVerified=true -s email="$email"
  fi

  ./kcadm.sh set-password -r myrealm --username $username --new-password Password1! --temporary=false
  
  # fetch user and group id
  userid=$(./kcadm.sh get users -r myrealm -q username=$username --fields id --format csv --noquotes)
  groupid=$(./kcadm.sh get groups -r myrealm -q name=$group --fields id --format csv --noquotes)
  
  # no group membership yet, but add
  ./kcadm.sh update users/$userid/groups/$groupid -r myrealm -s realm=myrealm -s userId=$userid -s groupId=$groupid -n
  ./kcadm.sh get users/$userid/groups -r myrealm
}

###### MAIN ######################

# first wait for port 8080 to be ready
port_ready=0
while [[ $port_ready -eq 0 ]]; do
  curl --retry 0 http://localhost:8080/realms/master
  if [ $? -eq 0 ]; then
    echo "port 8080 is now ready"
    port_ready=1
  fi
  echo "waiting another 5 seconds for port 8080 to be ready..."
  sleep 5
done

sleepSeconds="${1:-30}"
echo "going to wait for initialization/stabilization of server, sleeping for $sleepSeconds"
sleep $sleepSeconds

cd /opt/keycloak/bin

# login
./kcadm.sh config credentials --realm master --user admin --password admin --server http://localhost:8080

# create realm
./kcadm.sh create realms -s realm=myrealm -s enabled=true -o

# disable 'rsa-enc-generated' key for realm to avoid JWKS 'RSA-OAEP' key types which jwt module cannot parse
component_id=$(./kcadm.sh get components -r myrealm -q name=rsa-enc-generated --fields id --format csv --noquotes)
./kcadm.sh update components/$component_id -r myrealm -s 'config.active=["false"]'
./kcadm.sh update components/$component_id -r myrealm -s 'config.enabled=["false"]'

# create groups
./kcadm.sh create groups -r myrealm -s name=mygroup
./kcadm.sh create groups -r myrealm -s name=engineers
./kcadm.sh create groups -r myrealm -s name=managers

# creates users in various groups
create_user myuser mygroup first.last@kubeadm.local first last
create_user engineer1 engineers engineer1@kubeadm.local
create_user engineer2 engineers engineer2@kubeadm.local
create_user manager1 managers manager1@kubeadm.local

# create client from json placed unto container (secret generated)
./kcadm.sh create clients -r myrealm -f /tmp/myclient.exported.json

# get secret for 'myclient' that was just generated upon import
clientid=$(./kcadm.sh get clients -r myrealm -q clientId=myclient --fields id --format csv --noquotes)
clientsecret=$(./kcadm.sh get clients/$clientid/client-secret -r myrealm --fields value --format csv --noquotes)
outfile=/tmp/keycloak.properties
touch $outfile
chmod 666 $outfile
echo "realm=myrealm" >> $outfile
echo "clientid=myclient" >> $outfile
echo "clientsecret=$clientsecret" >> $outfile
