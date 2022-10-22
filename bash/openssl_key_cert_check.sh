#!/bin/bash
#
# validates if key and cert are matched
# can also check against custom CA
#

[[ -n "$1" && -n "$2" ]] || { echo "Usage: keyFile certFile [CACertFile]"; exit 1; }

openssl rsa -noout -modulus -in $1 | openssl md5
openssl x509 -noout -modulus -in  $2 | openssl md5
echo "if the md5 matches, the key matches the cert"

if [ -n "$3" ]; then
  echo "Check if CA and cert are paired"
  openssl verify -CAfile $3 $2
fi

# check info in csr
#openssl req -text -noout -verify -in my.csr
