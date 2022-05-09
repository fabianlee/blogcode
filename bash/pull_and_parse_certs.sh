#!/bin/bash
#
# Pulls all PEM certs out of yaml file
# then examines properties using openssl

server_name="$1"
server_ip="$2"
if [[ -z "$server_name" ]]; then
  echo "usage: serverFQDN [serverIP]"
  exit 3
fi
[[ -n "$server_ip" ]] || server_ip="$server_name"

echo | openssl s_client -showcerts -servername $server_name -connect $server_ip:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $1.crt

# pull out multiline sections, remove leading spaces
sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' $1.crt | sed 's/^\s*//' > allcerts.pem

# count how many certs were pulled
certcount=$(grep -e "-----BEGIN CERTIFICATE-----" allcerts.pem | wc -l)

# pull each cert individually, use openssl to show critical properties
for index in $(seq 1 $certcount); do
  echo "==== cert $index"
  awk "/-----BEGIN CERTIFICATE-----/{i++}i==$index" allcerts.pem > $index.crt
  openssl x509 -in $index.crt -text -noout | grep -E "Subject:|Not After :|DNS:"
  rm $index.crt
done

rm allcerts.pem
