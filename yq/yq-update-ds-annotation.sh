#!/bin/bash
#
# reads multi-document yaml, adds row to array of only targeted ones
# https://mikefarah.gitbook.io/yq/usage/tips-and-tricks
#
# blog: https://fabianlee.org/2022/07/02/kubernetes-targeting-the-addition-of-array-items-to-a-multi-document-yaml-manifest


# adds array row indiscrimanately to all documents (not what we want)
#cat multi-doc.yaml | yq '.spec.template.metadata.annotations."prometheus.io/scrape"="true"'
#exit 0

# adds array row to only DaemonSet, but does not show other docs (not what we want)
#cat multi-doc.yaml | yq 'select(.kind=="DaemonSet") | .spec.template.metadata.annotations."prometheus.io/scrape"="true"'
#exit 0


# adds array row to both DaemonSet and Deployment, both of which have target path
# but also does not show other docs (not what we want)
#cat multi-doc.yaml | yq 'select(.spec.template.metadata.annotations) | .spec.template.metadata.annotations."prometheus.io/scrape"="true"'
#exit 0

# final correct logic to target modification, but output all documents
cat multi-doc.yaml | yq 'select (.spec.template.metadata.annotations) |= (  
  select (.kind=="DaemonSet") | 
  with(
    select(.spec.template.metadata.annotations."prometheus.io/scrape"==null); 
      .spec.template.metadata.annotations."prometheus.io/scrape"="true" | .spec.template.metadata.annotations."prometheus.io/port"="10254"
  )  
)'

