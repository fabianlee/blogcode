#!/bin/bash
#
# Pulls all PEM certs out of yaml file
# then examines properties using openssl

# pull out multiline sections, remove leading spaces
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' test.yml | sed 's/^\s*//' > allcerts.pem

# count how many certs were pulled
certcount=$(grep -e "-----BEGIN CERTIFICATE-----" allcerts.pem | wc -l)

# pull each cert individually, use openssl to show critical properties
for index in $(seq 1 $certcount); do
  echo "==== cert $index"
  awk "/-----BEGIN CERTIFICATE-----/{i++}i==$index" allcerts.pem > $index.crt
  openssl x509 -in $index.crt -text -noout | grep -E "Subject:|Not After :"
  rm $index.crt
done
