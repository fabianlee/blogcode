#!/bin/bash
#
# Determines exact buildpack details for CloudFoundry app
# 
# Supporting blog: https://fabianlee.org/2020/10/20/cloudfoundry-determining-buildpack-used-by-application/
#
app="$1"
if [ -z "$app" ]; then
  echo "ERROR You must provide a valid cf app name"
  exit 1
fi

cf apps | awk {'print $1'} | grep $app >/dev/null
if [ $? -eq 1 ]; then
  echo "ERROR the source app name $app is not valid"
  exit 1
fi

guid=$(cf app $app --guid)
echo "$app guid = $guid"

bpackguid=$(cf curl /v2/apps/$guid/summary | jq .detected_buildpack_guid | tr -d '"')
echo "buildpack guid = $bpackguid"

# list all buildpacks
# cf curl /v2/buildpacks
bpackname=$(cf curl /v2/buildpacks/$bpackguid | jq .entity.name | tr -d '"')
bpackfile=$(cf curl /v2/buildpacks/$bpackguid | jq .entity.filename | tr -d '"')
echo "buildpack used by $app name/file = $bpackname/$bpackfile"
