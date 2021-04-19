#!/bin/bash
#
# using sed begin and end range
#
# then using awk to get Nth match
#

echo "***get only certificate data..."

openssl s_client -showcerts -servername www.google.com -connect www.google.com:443 < /dev/null 2>/dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'

echo ""
echo "***get Nth certificate data, awk starts at index 1..."

openssl s_client -showcerts -servername www.google.com -connect www.google.com:443 < /dev/null 2>/dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | awk "/-----BEGIN CERTIFICATE-----/{i++}i==2"
