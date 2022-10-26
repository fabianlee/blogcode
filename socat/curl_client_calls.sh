#!/bin/bash
#
# uses curl to test socat HTTPS web server
#
# blog: https://fabianlee.org/2022/10/26/linux-socat-used-as-secure-https-web-server/
#

[[ -x $(which curl) ]] || sudo apt install curl -y

FQDN="${1:-mysocat.local}"
PORT="${2:-9443}"

cacert="${FQDN}.crt"
resolvestr="${FQDN}:${PORT}:127.0.0.1"

set -x
curl --cacert $cacert --resolve $resolvestr https://${FQDN}:${PORT}/

# do POST with x-www-form-urlencoded parameters
curl --cacert $cacert --resolve $resolvestr -X POST -d 'foo=bar&email=me@mydomain.com' https://${FQDN}:${PORT}/test

# do file POST
[[ -f toupload.txt ]] || echo "this is going up">toupload.txt
curl --cacert $cacert --resolve $resolvestr -X POST -F 'image=@toupload.txt' https://${FQDN}:${PORT}/test
