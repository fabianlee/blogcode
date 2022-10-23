#!/bin/bash

sudo mkdir -p /etc/pki/tls/certs
sudo chmod 755 /etc/pki/tls/certs

# https://askubuntu.com/questions/1424442/libssl1-1-is-deprecated-in-ubuntu-22-04-what-to-do-now
#lsb_release -rs
# package only valid for Ubuntu<22
sudo apt-get install libssl1.0.0 -y

cd /etc/pki/tls/certs
if [[ -n "$1" ]]; then
  export FQDN="$1"
else
  export FQDN=`hostname -f`
fi
echo -------------------
echo FQDN is $FQDN
echo -------------------

sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
-keyout $FQDN.key -out $FQDN.crt \
-subj "/C=US/ST=CA/L=SFO/O=myorg/CN=$FQDN"

sudo cat $FQDN.crt $FQDN.key | sudo tee -a $FQDN.pem
openssl x509 -noout -subject -in /etc/pki/tls/certs/$FQDN.crt
