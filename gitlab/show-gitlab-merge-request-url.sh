#!/bin/bash
# Construct URL for Merge Request from fork to upstream
#
# blog: https://fabianlee.org/2023/05/21/gitlab-generating-url-that-can-be-used-for-merge-request-from-fork-to-upstream/
# 
# Even if the repo and project level squash settings are set properly,
# I think there is an issue with the web UI page honoring squash/squash_on_merge settings
# https://gitlab.com/gitlab-org/gitlab/-/issues/297248
# https://stackoverflow.com/questions/70613965/set-squash-boolean-when-creating-a-merge-request-from-a-url
#

# one way to do URL encoding, assuming 'od' utility is installed
# https://unix.stackexchange.com/questions/60653/urlencode-function
# another way is using jq: echo -n "$1" | jq -sRr @uri
function urlencode_od_awk () {
  echo -n "$1" | od -t d1 | awk '{
      for (i = 2; i <= NF; i++) {
        printf( ($i>=48 && $i<=57) || ($i>=65 && $i<=90) || ($i>=97 && $i<=122) || $i==45 || $i==46 || $i==95 || $i==126 ? "%c" : "%%%02x", $i )
      }
    }'
}

current_branch=$(git branch --show-current)
[ -n "$current_branch" ] || { echo "ERROR could not determine current git branch"; exit 2; }

# require 'origin' and 'upstream' remotes
origin=$(git remote get-url origin)
upstream=$(git remote get-url upstream)
[[ -n "$origin" && -n "$upstream" ]] || { echo "ERROR expecting 'origin' and 'upstream' remotes"; exit 3; }
echo "origin: $origin"
echo "upstream: $upstream"

origin_url=$(git remote get-url origin | sed 's/oauth2@//' | sed 's/\.git$//')

last_commit_message=$(git log -1 --pretty=%B | head -n1)
urlencoded_title=$(urlencode_od_awk "$last_commit_message")

# parameters documented here:
# https://docs.gitlab.com/ee/api/merge_requests.html#create-mr
echo ""
echo "To create merge request for '$current_branch' from origin->upstream:"
echo ""
echo "    $origin_url/-/merge_requests/new?merge_request%5Bsource_branch%5D=$current_branch&merge_request%5Btarget_branch%5D=$current_branch&merge_request%5Bforce_remove_source_branch%5D=false&merge_request%5Bsquash%5D=true&merge_request%5Bsquash_on_merge%5D=true&merge_request%5Btitle%5D=$urlencoded_title"
echo ""

