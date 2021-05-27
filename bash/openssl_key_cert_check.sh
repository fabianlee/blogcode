#!/bin/bash
#
# validates if key and cert are matched
#

openssl rsa -noout -modulus -in $1 | openssl md5
openssl x509 -noout -modulus -in  $2 | openssl md5

echo "if the md5 matches, the key matches the cert"
