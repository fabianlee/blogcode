#!/bin/bash
#
# Removes followers of github account by temporarily blocking/unblocking
#
# Requires github personal access token so that API calls can be run:
# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
#

token=$github_pat
[ -n "$token" ] || { echo "ERROR, need to define 'github_pat' env variable which is github personal access token"; echo ""; echo "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"; exit 1; }

# https://docs.github.com/en/rest/reference/users#get-the-authenticated-user
github_user=$(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $github_pat" https://api.github.com/user | jq -r ".login")
echo "github_user = $github_user"

# https://docs.github.com/en/rest/reference/users#list-followers-of-the-authenticated-user
#
total_followers=$(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $github_pat" https://api.github.com/users/$github_user | jq ".followers")
echo "Number of followers of $github_user = $total_followers"


# https://docs.github.com/en/rest/reference/users#list-followers-of-the-authenticated-user
#
for follower in $(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $github_pat" https://api.github.com/users/$github_user/followers | jq -r ".[].login"); do
  echo "need to block/unblock $follower"

  # block user temporarily (destroys their follow)
  # https://docs.github.com/en/rest/reference/users#block-a-user
  #
  curl \
    -s \
    -X PUT \
    -H "Authorization: token $github_pat" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/blocks/$follower
  # unblock user
  curl \
    -s \
    -X DELETE \
    -H "Authorization: token $github_pat" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/blocks/$follower

done

echo ""
echo "waiting 10 seconds for settling before checking final followers count..."
sleep 10

total_followers=$(curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $github_pat" https://api.github.com/users/$github_user | jq ".followers")
echo "FINAL Number of followers of $github_user = $total_followers"

