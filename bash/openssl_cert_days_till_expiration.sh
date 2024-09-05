#!/bin/bash
#
# shows number of days before expiration of certificate using openssl
#
# https://stackoverflow.com/questions/10175812/how-to-generate-a-self-signed-ssl-certificate-using-openssl
# test using self-signed cert:
# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"
#

# need parameter and valid certificate file
[[ -n "$1" && -f "$1" ]] || { echo "Usage: certFile"; exit 1; }

# calculate difference in days of strings in GMT format
# https://unix.stackexchange.com/questions/24626/quickly-calculate-date-differences/24636#24636
function datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    # in days
    echo $(( (d1 - d2) / 86400 + 1 ))
}


# pull expiration string from certificate
cert_expiration_str=$(openssl x509 -in cert.pem -text -noout | grep -Po "Not After : \K.*" | head -n1)
echo "cert_expiration_str=$cert_expiration_str"

# show number of days till expiration
echo "days till expiration:" $(datediff "$cert_expiration_str" "$(date -u)")

