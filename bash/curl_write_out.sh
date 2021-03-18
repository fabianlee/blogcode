#!/bin/bash
#
# Example showing how curl can be used in scripting

# -w used to write out special variables
# --fail uses exit code for better scripting
# -s silent, -o output
# could use --head to fetch headers only

echo ""
echo "*************************************************************"
echo "Pulling page that should succeed"
echo "*************************************************************"
page="https://www.google.com"
outstr=$(curl --fail --connect-timeout 3 --retry 0 -s -o /dev/null -w "%{http_code}" $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "ERROR should have been able to pull $page, retVal=$retVal, code=$outstr"; exit 4; }
echo "OK pulling from $page successful, retVal=$retVal, code=$outstr"

echo ""
echo "*************************************************************"
echo "Pulling bad page from good domain"
echo "*************************************************************"
page="https://www.google.com/fake/page/123"
outstr=$(curl --fail --connect-timeout 3 --retry 0 -s -o /dev/null -w "%{http_code}" $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "EXPECTED_FAILURE pulling bad $page, retVal=$retVal, code=$outstr"; }


echo ""
echo "*************************************************************"
echo "Pulling from bad domain"
echo "*************************************************************"
page="https://www.google-makemefail123.com/fake"
outstr=$(curl --fail --connect-timeout 3 --retry 0 -s -o /dev/null -w "%{http_code}" $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "EXPECTED_FAILURE $page domain is bad, retVal=$retVal, code=$outstr"; }
