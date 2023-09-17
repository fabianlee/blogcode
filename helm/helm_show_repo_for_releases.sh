#!/bin/bash
#
# Answers question: which helm repo did this release come from?
#
# For each release installed into Kubernetes cluster,
# does brute force check into each local helm repo to see if there is a chart match
#
# This is no guarantee of provenance (that release actually came from this exact repo),
# but at least it at provides a repo that could be used to maintain/upgrade release going forward
#

# gets list of local helm repo
repo_list_local=$(helm repo list | tail -n+2 | grep -v "^stable " | awk '{print $1}')
>&2 echo -en "will search for installed charts in local repos (skipping 'stable'):\n$repo_list_local"
>&2 echo ""
>&2 echo ""
>&2 echo "RELEASE,CHART,VERSION,REPO"

# for each installed Release
IFS=$'\n'
for line in $(helm list -A 2>/dev/null | tail -n+2); do 
  # release name
  name=$(echo $line | awk '{print $1}' | xargs)

  # skip 'stable' because it is central hub for too many charts
  [[ $name == "stable" ]] && continue

  # chart name is '<name>-<version>', split it
  chart_with_suffix=$(echo $line | awk -F' ' '{print $9}' | xargs)
  chart_name=${chart_with_suffix%-*}
  chart_version=${chart_with_suffix##*-}

  # brute-force check of each local repo
  while read -r repo; do 
    helm show chart $repo/$chart_name >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "$name,$chart_name,$chart_version,$repo"
    fi
  done < <(echo "$repo_list_local")

done
