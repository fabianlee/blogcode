#!/bin/bash

project="gitlab-org/cli"

# make sure jq is installed
sudo apt install jq -y

# https://gitlab.com/gitlab-org/cli/-/releases
latest_version=$(curl -s \
  -X POST \
  -H 'Content-Type: application/json' \
  --data-raw '[{"operationName":"allReleases","variables":{"fullPath":"gitlab-org/cli","first":10,"sort":"RELEASED_AT_DESC"},"query":"query allReleases($fullPath: ID!, $first: Int, $last: Int, $before: String, $after: String, $sort: ReleaseSort) {\n  project(fullPath: $fullPath) {\n    id\n    releases(\n      first: $first\n      last: $last\n      before: $before\n      after: $after\n      sort: $sort\n    ) {\n nodes {\n ...Release\n }\n }\n }\n}\n\nfragment Release on Release {\n  id\n  name\n }\n  \n"}]' \
  https://gitlab.com/api/graphql | jq -r ".[].data.project.releases.nodes[0].name")
echo "latest_version=$latest_version"

# strip off 'v' for filename
tar_file="glab_${latest_version//v}_Linux_x86_64.tar.gz"
tar_url="https://gitlab.com/$project/-/releases/$latest_version/downloads/$tar_file"
echo "downloading: $tar_url"
[ -f /tmp/$tar_file ] || wget $tar_url -O /tmp/$tar_file

# place binary in current directory, then move to PATH
tar xvfz /tmp/$tar_file bin/glab --strip=1
sudo chown root:root glab
sudo mv glab /usr/local/bin/.

which glab
glab --version

echo "Run 'glab auth login' to authenticate"

