#!/bin/bash

FQDN="$1"
[ -n "$FQDN" ] || { echo "ERROR provide FQDN for self-signed cert"; exit 3; }

# older was libssl1.0.0
sudo apt install libssl1.1 -y

echo -------------------
echo FQDN is $FQDN
echo -------------------

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
-keyout /tmp/$FQDN.key -out /tmp/$FQDN.pem \
-subj "/C=US/ST=CA/L=SFO/O=myorg/CN=$FQDN"

openssl x509 -in /tmp/$FQDN.pem -text -noout | grep -E "Subject:|Not After :|DNS:|Issuer:"

echo ""
echo "public cert and private key are located in /tmp directory"

