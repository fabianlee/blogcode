#!/bin/bash
#
# update deeply nested elementing using yq (https://github.com/mikefarah/yq)
#

echo ""
echo "--- company-servers.yaml --"
cat company-servers.yaml

echo ""
echo "-- replace all tags --"
yq '(.. | select(has("tags")).tags) = ["coreos","arm64"]' company-servers.yaml

echo ""
echo "-- append to tags --"
yq '(.. | select(has("tags")).tags) += ["amd64"]' company-servers.yaml


echo ""
echo "-- update tags where region=us-east --"
yq '(.. | select(has("tags") and .region=="us-east").tags) += ["amd64"]' company-servers.yaml
