#!/bin/bash
#
# Uses gcloud to create service account, download key, assign IAM roles
#
# blog: https://fabianlee.org/2021/03/17/gcp-creating-gcp-service-account-with-iam-roles-using-gcloud/
#

if [ $# -eq 0 ]; then
  echo "usage: gcpProjectName"
  exit 1
fi
project="$1"

newServiceAccount="mytest1-$project"

# resolve project name to project id (can be different)
projectId=$(gcloud projects list --filter="name=$project" --format='value(project_id)')
echo "project/projectId=$project/$projectId"
gcloud config set project $projectId

# check if service account already exists
alreadyExists=$(gcloud iam service-accounts list --filter="name ~ ${newServiceAccount}@" 2>/dev/null | wc -l)
[ $alreadyExists -eq 0 ] || { echo "ABORTING the service account $newServiceAccount already exists!"; exit 0; }

# create service account
gcloud iam service-accounts create $newServiceAccount --display-name "test account" --project=$projectId
echo "sleeping 30 seconds to allow consistency..."
sleep 30

# get full email identifier for service account
accountEmail=$(gcloud iam service-accounts list --project=$projectId --filter=$newServiceAccount --format="value(email)")

# download key
gcloud iam service-accounts keys create $newServiceAccount-$projectId.json --iam-account $accountEmail

# assign IAM roles
for role in roles/storage.objectViewer roles/storage.objectCreator; do
  gcloud projects add-iam-policy-binding $projectId --member=serviceAccount:$accountEmail --role=$role > /dev/null
done

# show all roles for this service account
echo "**********************************************"
echo "Final roles for $newServiceAccount:"
gcloud projects get-iam-policy $projectId --flatten="bindings[].members" --filter="bindings.members=serviceAccount:$accountEmail" --format="value(bindings.role)"

