#!/bin/bash
#
# Example showing how curl can be used in scripting
# blog: https://fabianlee.org/2021/03/18/bash-capturing-http-status-code-using-curl-write-out/
#
# -w used to write out special variables
# --fail uses exit code for better scripting
# -s silent, -o output
# could use --head to fetch headers only
options='--fail --connect-timeout 3 --retry 0 -s -o /dev/null -w %{http_code}'


echo ""
echo "*************************************************************"
echo "Pulling page that should succeed"
echo "*************************************************************"
page="https://www.google.com"
outstr=$(curl $options $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "ERROR should have been able to pull $page, retVal=$retVal, code=$outstr"; exit 4; }
echo "OK pulling from $page successful, retVal=$retVal, code=$outstr"


echo ""
echo "*************************************************************"
echo "Pulling bad page from good domain"
echo "*************************************************************"
page="https://www.google.com/fake/page/123"
outstr=$(curl $options $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "EXPECTED_FAILURE pulling bad $page, retVal=$retVal, code=$outstr"; }


echo ""
echo "*************************************************************"
echo "Pulling from bad domain"
echo "*************************************************************"
page="https://www.google-makemefail123.com/fake"
outstr=$(curl $options $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "EXPECTED_FAILURE $page domain is bad, retVal=$retVal, code=$outstr"; }


echo ""
echo "*************************************************************"
echo "POST to good domain and page"
echo "*************************************************************"
page="https://httpbin.org/post"
outstr=$(curl $options -X POST --data  "{ foo: 'bar'}" -H 'Content-Type:application/json' $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "ERROR should have been able to post to $page, retVal=$retVal, code=$outstr"; exit 4; }
echo "OK post to $page successful, retVal=$retVal, code=$outstr"

