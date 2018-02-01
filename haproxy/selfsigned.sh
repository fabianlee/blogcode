#!/bin/bash

sudo mkdir -p /etc/pki/tls/certs
sudo chmod 755 /etc/pki/tls/certs
sudo apt-get install libssl1.0.0 -y

cd /etc/pki/tls/certs
export FQDN=`hostname -f`
echo -------------------
echo FQDN is $FQDN
echo -------------------

sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
-keyout $FQDN.key -out $FQDN.crt \
-subj "/C=US/ST=CA/L=SFO/O=myorg/CN=$FQDN"

cat $FQDN.crt $FQDN.key | sudo tee -a $FQDN.pem
openssl x509 -noout -subject -in /etc/pki/tls/certs/$FQDN.crt
