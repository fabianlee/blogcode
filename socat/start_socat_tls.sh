#!/bin/bash
#
# uses socat to create HTTPS web server running on local port
#

FQDN="${1:-mysocat.local}"
PORT="${2:-9443}"

[[ -x $(which socat) ]] || sudo apt install socat -y
#which socat
#if [[ $? -ne 0 ]]; then
#  sudo apt install socat -y
#fi

set -x

[[ -f $FQDN.key ]] || openssl genrsa -out $FQDN.key 2048
[[ -f $FQDN.crt ]] || openssl req -new -key $FQDN.key -x509 -days 3653 -out $FQDN.crt -subj "/C=US/ST=CA/L=SFO/O=myorg/CN=$FQDN"
[[ -f $FQDN.pem ]] || cat $FQDN.key $FQDN.crt >$FQDN.pem

chmod 600 $FQDN.key $FQDN.pem
chmod 644 $FQDN.crt

# shows HTTP protocol
socat -v -ls OPENSSL-LISTEN:${PORT},reuseaddr,cert=${FQDN}.pem,verify=0,crlf,fork SYSTEM:"echo HTTP/1.0 200; echo Content-Type\: text/plain; echo; echo \"hello from $(hostname) at \$(date)\""
