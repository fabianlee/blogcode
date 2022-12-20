#!/bin/bash
#
# merging section of one file to another using yq (https://github.com/mikefarah/yq)
#

echo ""
echo "--- company-servers.yaml --"
cat company-servers.yaml

echo ""
echo "--- company-regions-new.yaml --"
cat company-regions-new.yaml

echo ""
echo "--- merging 'regions-new' with eval-all and fileIndex ---"
yq eval-all 'select(fileIndex==0).company.regions = select(fileIndex==1).regions-new | select(fileIndex==0)' company-servers.yaml company-regions-new.yaml
