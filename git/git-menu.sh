#!/bin/bash
#
# CLI menu system for handling sync, merge/pull requests between repo and its forks
#

function show_fork_menu() {
echo "status    show status of each branch"
echo "upstream  get latest changes from upstream for each branch"
echo "latest    show latest test files"
echo ""
echo "branch    switch branches, current is $branch"
echo "log       show latest log lines for branch $branch"
echo "test      test change on branch $branch"
echo "push      push changes from branch $branch"
if [ "$git_provider" == "github" ]; then
  echo "createpr  create github pull request for changes on branch $branch"
elif [ "$git_provider" == "gitlab" ]; then
  echo "createmr  create gitlab merge request for changes on branch $branch"
fi
echo ""
}
function show_central_menu() {

echo "status    show status of each branch"
echo "origin    get latest changes from origin for each branch"
echo "latest    show latest test files"
if [ "$git_provider" == "github" ]; then
  echo "mergepr   squash and merge any pending github pull request"
elif [ "$git_provider" == "gitlab" ]; then
  echo "mergemr   squash and merge any pending gitlab merge request"
fi
echo ""
echo "branch    switch branches, current is $branch"
echo "log       show latest log lines for branch $branch"
echo "test      commit change on branch $branch"
echo "testall   commit change on all branches ($branches_type)"
echo "push      push changes from branch $branch"
echo "pushall   push all branches and all tags"
echo ""

if [[ ($independent_branches -eq 1) && ("$primary_branch" != "$branch") ]]; then
  echo "pin       tag primary branch with 'pin-$branch'"
  echo "promote   merge into branch '$branch' < 'pin-$branch'"
fi

if [[ ($independent_branches -eq 0) && ("$primary_branch" != "$branch") ]]; then
  echo "promote   merge into branch '$branch' < '${parent_branch[$branch]}'"
fi

if [[ $independent_branches -eq 0 ]]; then
  # show promotion chain
  chain=""
  for src_branch in "${branch_array[@]}"; do
    chain="$chain>$src_branch"
  done
  echo "promall   merge ${chain:1}"
fi

if [[ "$branch" != "$primary_branch" ]]; then
  echo "tag       tag branch '$branch' with 'tag-$branch'"
fi

}

function tag_branch() {
  if [[ "$branch" == "$primary_branch" ]]; then
    echoRed "This was meant for custom branches, not master|main"
    return
  fi

  tag="$1"
  echo "Going to tag branch '$branch' with tag '$tag'" 

  latest_sha=$(git rev-parse $branch --short HEAD)
  git log --oneline -n10
  echo ""
  read -p "Which sha should be tagged with '$tag'? " sha

  if [ -n "$sha" ]; then
    # remove local and remote tag
    git tag -d $tag
    git push origin --delete $tag

    # add local and remote tag
    if git tag $tag $sha; then
      git push --tags
      git log --oneline -n10
    else
      echo "ERROR tagging with $tag"
    fi

  fi

}

function merge_code_from_tag() {
  if [[ "$branch" == "$primary_branch" ]]; then
    echoRed "This was meant for custom branches, not master|main"
    return
  fi

  tag="$1"
  echo "Going to merge into branch $branch from tag $tag" 

  if git tag | grep "^$tag"; then
    git merge $tag --no-edit
    if [ $? -eq 0 ]; then
      echo "SUCCESS merging from tag $tag $?"
      if git status | grep -q ahead; then
        echoYellow "Going to attempt push of branch $src_branch !!!"
        git push
      fi
    else
      echo "ERROR doing merge into $branch from tag $tag"
    fi
  else
    echo "ERROR could not find tag $tag"
  fi

}

function merge_code_from_branch() {
  the_parent_branch="$1"
  if [[ "$branch" == "$primary_branch" ]]; then
    echoRed "This was meant for custom branches, not master|main"
    return
  fi

  echo "Going to merge into branch '$branch' < '$the_parent_branch'"
  git merge $the_parent_branch --no-edit
  if [ $? -eq 0 ]; then
    echo "SUCCESS merging branch"
    if git status | grep -q ahead; then
      echoYellow "Going to attempt push of branch $branch !!!"
      git push
    fi
  else
    echo "ERROR doing merge into '$branch' < '$the_parent_branch'"
  fi

}

function merge_cascade_promotional_branches() {
  saved_branch=$branch

  for src_branch in "${branch_array[@]}"; do
    [ "$src_branch" == "$primary_branch" ] && continue

    echoYellow "Going to merge: $src_branch < ${parent_branch[$branch]}"
    git checkout $src_branch
    [[ $? -eq 0 ]] || { echoRed "ERROR doing checkout of $src_branch"; return; }
    branch=$src_branch

    git merge "${parent_branch[$branch]}" --no-edit
    if [ $? -eq 0 ]; then
      echo "SUCCESS merging"
    else
      echoRed "ERROR doing merge $src_branch < ${parent_branch[$branch]}"
      return
    fi
  done

  branch=$saved_branch
  git checkout $branch
}

function tag_primary_branch() {
  if [[ "$branch" == "$primary_branch" ]]; then
    echoRed "This was meant for custom branches, not master|main"
    return
  fi
  tagprefix="$1"

  latest_sha=$(git rev-parse $primary_branch --short HEAD)
  git log $primary_branch --oneline -n7
  echo ""
  read -p "Which sha from branch '$primary_branch' should be tagged with '$tagprefix-$branch'? " sha

  if [ -n "$sha" ]; then
    # remove local and remote tag
    git tag -d $tagprefix-$branch
    git push origin --delete $tagprefix-$branch 

    # add local and remote tag
    if git tag $tagprefix-$branch $sha; then
      git push --tags
      git log $primary_branch --oneline -n7
    else
      echo "ERROR tagging with $tagprefix-$branch"
    fi

  fi

}

function show_all_status() {
  git remote -v

  saved_branch=$branch

  any_ahead=0

  for src_branch in "${branch_array[@]}"; do
    git checkout $src_branch 2>/dev/null && branch=$src_branch
    if [ $? -eq 0 ]; then
      echo ""
      echoYellow "==== $src_branch ===="
      git status
      if git status | grep -q ahead; then
        echoYellow "TODO need to push $src_branch !!!"
	any_ahead=1
      fi
    fi
  done

  if [ $any_ahead -eq 1 ]; then
    read -p "some branches are ahead, push all (y/n) ?" to_push
    if [ "$to_push" == "y" ]; then
      git push --all
      if [ $? -eq 0 ]; then
        echo "SUCCESS. pushed all"
      fi
    fi
  fi

  branch=$saved_branch
  git checkout $branch
}

function show_log() {
  git log --oneline -n5
  #for src_branch in "${branch_array[@]}"; do
  #  echo ""
  #  echo "==== $src_branch ====" 
  #  git log $src_branch --oneline -n5
  #done
}

function switch_branch() {
  git branch
  echo ""
  read -p "Which branch? " newbranch

  if [ -n "$newbranch" ]; then
    git checkout $newbranch
    if [ $? -eq 0 ]; then
      branch=$newbranch

      # show end results
      # git branch --format="%(refname:short)"
      git branch
    fi
  fi
}

function pull_from_upstream() {
  saved_branch=$branch
  git pull --all

  any_ahead=0
  for localbranch in "${branch_array[@]}"; do
    git checkout $localbranch && branch=$localbranch
    git fetch upstream $localbranch
    git merge upstream/$localbranch --no-edit
    if [ $? -eq 0 ]; then
      if git status | grep -q ahead; then
        echoYellow "TODO need to push $localbranch !!!"
        any_ahead=1
      fi
    else
      echoRed "ERROR while trying to merge on $localbranch"
      return
    fi
  done

  if [ $any_ahead -eq 1 ]; then
    read -p "some branches are ahead, push all (y/n) ?" to_push
    if [ "$to_push" == "y" ]; then
      git push --all
      if [ $? -eq 0 ]; then
        echo "SUCCESS. pushed all"
      fi
    fi
  fi

  branch=$saved_branch
  git checkout $branch 1>/dev/null 2>&1
}
function sync_from_origin() {
  saved_branch=$branch

  for localbranch in "${branch_array[@]}"; do
    git checkout $localbranch 2>/dev/null && branch=$localbranch
    if [ $? -eq 0 ]; then
      git fetch origin $localbranch
      # we are just a fork, so favor the origin changes (avoids most sync conflicts)
      git merge -s recursive -Xtheirs origin/$localbranch --no-edit
      if [ $? -ne 0 ]; then
        echoRed "ERROR while trying to merge from origin/$localbranch"
        return
      fi
    fi
  done

  branch=$saved_branch
  git checkout $branch 1>/dev/null 2>&1
}

function show_latest_test_files() {
  saved_branch=$branch

  echo ""

  # for independent branches, switch to each different branch and show file
  if [[ $independent_branches -eq 1 ]]; then
    echoYellow "==== Latest test files in each independent branch ===="

    for localbranch in "${branch_array[@]}"; do
      git checkout $localbranch 1>/dev/null 2>&1 && branch=$localbranch
      if [ $? -eq 0 ]; then
  
        if [[ "$localbranch" == "$primary_branch" ]]; then
          outfile="$root_repo_dir/$localbranch.txt"
          showfile="$localbranch.txt"
        else
          outfile="$root_repo_dir/overlays/$localbranch/$localbranch.txt"
          showfile="overlays/$localbranch"
        fi
  
        if [ -f "$outfile" ]; then
          echo -en "${showfile}: "
          tail -n1 $outfile
        else
          echo "${showfile}: null"
        fi
      fi
    done

  # for promotional branches, show each expected file for current branch
  else
    echoYellow "==== Latest test files in promotional branch $branch ===="
    
    for localbranch in "${branch_array[@]}"; do
  
        if [[ "$localbranch" == "$primary_branch" ]]; then
          outfile="$root_repo_dir/$localbranch.txt"
          showfile="$localbranch.txt"
        else
          outfile="$root_repo_dir/overlays/$localbranch/$localbranch.txt"
          showfile="overlays/$localbranch"
        fi
  
        if [ -f "$outfile" ]; then
          echo -en "${showfile}: "
          tail -n1 $outfile
        else
          echo "${showfile}: null"
        fi

    done

  fi

  branch=$saved_branch
  git checkout $branch 1>/dev/null 2>&1
}

function change_and_commit_test_file_current_branch() {
  msg="$1"

  if [[ "$branch" == "$primary_branch" ]]; then
    thedir="$root_repo_dir"
    outfile="main.txt"
  else
    thedir="$root_repo_dir/overlays/$branch"
    mkdir -p $thedir
    outfile="$thedir/$branch.txt"
  fi

  datestr=$(date)
  echo "$msg on $branch @ $datestr" | tee -a "$outfile"
  git add "$outfile"
  git commit -a -m "$msg on $branch @ $datestr"
}

function change_and_commit_test_file_all_independent_branches() {
  msg="$1"
  saved_branch=$branch

  for src_branch in "${branch_array[@]}"; do
    sleep 2
    git checkout $src_branch && branch=$src_branch
    echoYellow "=== puttting independent change on $src_branch ==="
    change_and_commit_test_file_current_branch "$msg"
  done

  branch=$saved_branch
  git checkout $branch
}

function change_and_commit_test_file_all_promoted_branches() {
  msg="$1"
  saved_branch=$branch

  for src_branch in "${branch_array[@]}"; do
    sleep 2
    git checkout $src_branch && branch=$src_branch
    echoYellow "=== puttting promotional change on $src_branch ==="
    change_and_commit_test_file_current_branch "$msg"

    if [ "$src_branch" != "$primary_branch" ]; then
      echoYellow "=== merging promotional changes $src_branch < ${parent_branch[$src_branch]} ==="
      git merge ${parent_branch[$src_branch]} --no-edit
      if [ $? -ne 0 ]; then
        echoRed "ERROR conflict while trying to merge on $src_branch"
        return
      fi
    fi

  done

  branch=$saved_branch
  git checkout $branch
}

function do_push() {
  echo "doing push on $branch branch"
  git push
}

function get_repo_remote() {
  remote_name="$1"
  remote_owner_repo=$(git remote get-url "$remote_name" 2>/dev/null | cut -d'/' -f4- | sed 's/\.git//')
  echo "$remote_owner_repo"
}

function create_pull_request_github() {
  msg="$1"
  datestr=$(date)

  upstream_owner_repo=$(get_repo_remote "upstream")
  [ -n "$upstream_owner_repo" ] || { echoRed "ERROR need upstream owner defined when submitting PR"; return; }

  gh pr create --title "$msg at $datestr" --base $branch --repo $upstream_owner_repo --body ""
}

function merge_pull_request_github() {
  origin_owner_repo=$(get_repo_remote "origin")
  [ -n "$origin_owner_repo" ] || { echoRed "ERROR need origin owner defined when merging PR"; return; }

  gh pr list --repo $origin_owner_repo
  if [ $? -ne 0 ]; then
    echoRed "ERROR trying to get pr list"
    return
  fi

  if gh pr list --repo $origin_owner_repo | grep -q "no open"; then
    echoYellow "There were no github pull requests to show"
    return
  fi
  
  read -p "Squash and merge which pull request number? " to_merge
  if [ -n "$to_merge" ]; then
    mr_status=$(gh pr view $to_merge --repo $origin_owner_repo --json closed -t "{{.closed}}")
    if [ "$mr_status" == "false" ]; then

      merge_branch=$(gh pr view $to_merge --repo $origin_owner_repo --json author,headRefName -t "{{.headRefName}}")
      echo "Going to merge $to_merge into branch $merge_branch"
      gh pr merge --repo $origin_owner_repo -s $to_merge

      # after merge request, need to sync up local again
      saved_branch=$branch
      git checkout $merge_branch
      git pull -r
      branch=$saved_branch
      git checkout $branch
     
    else
      echo "SKIP either merge request $to_merge does not exist, or it is closed"
    fi
  fi
}


function create_merge_request_gitlab() {
  msg="$1"
  # glab does not require unpushed commit to exist

  # get fully qualified 'owner/repo' name of remotes
  origin_owner_repo=$(get_repo_remote "origin")
  upstream_owner_repo=$(get_repo_remote "upstream")
  echo "origin=$origin_owner_repo upstream=$upstream_owner_repo"
  [[ (-n "$origin_owner_repo") && (-n "$upstream_owner_repo") ]] || { echoRed "ERROR needed both 'origin' and 'repo' remotes in order to create merge request on fork"; return; }

  echo "going to submit MR: $origin_owner_repo [$branch] -> $upstream_owner_repo [$branch]"
  # create MR in 'upstream' repo
  glab mr create --title "$msg" --description "" --squash-before-merge --source-branch $branch --target-branch $branch --head $origin_owner_repo --repo $upstream_owner_repo -y
}

function merge_merge_request_gitlab() {
  # get fully qualified 'owner/repo' name of origin
  origin_owner_repo=$(get_repo_remote "origin")
  echo "origin=$origin_owner_repo"

  glab mr list --repo $origin_owner_repo
  if glab mr list --repo $origin_owner_repo | grep -q "No open"; then
    echoYellow "There were no gitlab merge requests to show"
    return
  fi
  
  read -p "Squash and merge which merge request number? " to_merge
  if [ -n "$to_merge" ]; then
    mr_status=$(glab mr view $to_merge --repo $origin_owner_repo | grep ^state | cut -f2)
    if [ "$mr_status" == "open" ]; then

      # which branch is this MR destined for?
      found_branch=$(glab mr list --repo $origin_owner_repo | grep "^\!$to_merge" | grep -Po "(\(.*\)) " | tr -d "() ")
      if [ -z "$found_branch" ]; then
        echo "ERROR could not find branch that mr $to_merge was on"
        return
      else
        echo "found mr $to_merge on branch '$found_branch'"
      fi

      # view in full details, then merge
      glab mr view $to_merge --repo $origin_owner_repo | tee
      glab mr merge $to_merge -s -y

      # after merge request, need to sync up local again
      saved_branch=$branch
      git checkout $found_branch
      git pull -r
      branch=$saved_branch
      git checkout $branch
     
    else
      echo "SKIP either merge request $to_merge does not exist, or it is closed"
    fi
  fi
}

function discover_branches() {
  if [ -f "$root_repo_dir/.gitbranches" ]; then
    OLDIFS=$IFS
    IFS=$'\n'
    # skip lines commented out with hash and empty lines
    for line in $(cat "$root_repo_dir/.gitbranches" | grep -v "^#" | grep -v "^$"); do
      src=$(echo $line | cut -d'<' -f1)
      dst=$(echo $line | cut -d'<' -f2)
      branch_array+=($src)
      if [ -n "$dst" ]; then
        parent_branch[$src]="$dst"
      fi
    done
    IFS=$OLDIFS
  else
    # add primary branch first
    branch_array+=($primary_branch)
    parent_branch[$primary_branch]=""

    # if no special config file, then assume independent environment branches
    # that merge from 'pin-<branchname>'
    for localbranch in $(git branch -r | grep -o "^\s*origin/[^ ]*" | grep -v HEAD | cut -d'/' -f2); do 
      [ "$localbranch" == "$primary_branch" ] && continue

      branch_array+=($localbranch)
      parent_branch[$localbranch]="pin-$localbranch"
    done

  fi
}

function populate_fork_branches() {
  echo ""
  for localbranch in "${branch_array[@]}"; do
    git checkout $localbranch 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
      git checkout -b $localbranch -t origin/$localbranch
    fi
  done
  git checkout $branch
}

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
function echoGreen() {
  echo -e "${GREEN}$1${NC}"
}
function echoRed() {
  echo -e "${RED}$1${NC}"
}
function echoYellow() {
  echo -e "${YELLOW}$1${NC}"
}


### MAIN #####

if ! git status 1>/dev/null 2>&1; then
  echo "ERROR run this from a git enbled directory"
  exit 1
fi

git_provider=""
if git remote -v | grep -q "github.com"; then
  git_provider=github
  the_bin=$(which gh)
  [ -n "$the_bin" ] || { echo "ERROR could not find github CLI 'gh', see https://github.com/cli/cli#installation"; exit 2; }

  # check for login
  if gh auth status 2>&1 | grep -q "Logged in to github.com"; then
    echo "SKIP gh login because already logged in"
  else
    gh auth login --hostname github.com -p https
  fi

  # who is logged in (~/.config/gh/hosts.yml is toml that is hard to parse if multiple hosts)
  username=$(gh auth status 2>&1 | grep -Po "Logged in to github.com as \K(.*) \(" | cut -d' ' -f1)
  echo "github user: $username"

elif git remote -v | grep -q "gitlab"; then
  git_provider=gitlab
  the_bin=$(which glab)
  [ -n "$the_bin" ] || { echo "ERROR could not find gitlab CLI 'lab', see https://gitlab.com/gitlab-org/cli#linux"; exit 2; }

  # check for login
  if glab auth status 2>&1 | grep -q "Logged in to gitlab.com"; then
    echo "SKIP glab login because already logged in"
  else
    glab auth login
  fi

  # who is logged in (~/.config/glab-cli/config.yml is yaml that is hard to parse if multiple hosts)
  username=$(glab auth status 2>&1 | grep -Po "Logged in to gitlab.com as \K(.*) \(" | cut -d' ' -f1)
  echo "gitlab user: $username"
else
  echo "ERROR this script only recognizes github|gitlab git repositories"
  exit 4
fi

origin_owner_repo=$(get_repo_remote "origin")
echo "origin=$origin_owner_repo"
upstream_owner_repo=$(get_repo_remote "upstream")

# Indicator of where a contribution is coming from in commits:
# 'self'               central repo where there is no upstream
# 'self/<forkname>'    forked repo where origin and upstream have same git owner
# '<user>/<forkname>'  forked repo where origin and upstream have different git owner
mixed_ownership="self"
if [ -n "$upstream_owner_repo" ]; then
  echo "upstream=$upstream_owner_repo"
  if [[ "$(dirname $upstream_owner_repo)" == "$(dirname $origin_owner_repo)" ]]; then
    mixed_ownership="self/$(basename $upstream_owner_repo)"
  else
    mixed_ownership="$origin_owner_repo"
  fi 
fi
echo "ownership: $mixed_ownership"

# is this a central repository, or personal fork?
repo_type=""
if git remote -v | grep -q ^upstream; then
  repo_type=fork
else
  repo_type=central
fi
echo "repo_type=$repo_type"

# repository root dir on local filesystem
root_repo_dir=$(git rev-parse --show-toplevel)

# current branch
branch=$(git branch --show-current)
echo "current branch=$branch"

# primary branch most often called main|master
primary_branch=""
if git branch | grep -q main; then
  primary_branch="main"
elif git branch | grep -q master; then
  primary_branch="master"
fi
if [[ "$primary_branch" == @("main"|"master") ]]; then
  echo "primary_branch=$primary_branch"
else
  echoRed "ERROR did not find expected main|master primary branch, which this script requires"
  exit 5
fi

# does this have independent branches OR promotional (main>dev>preprod>prod)
independent_branches=1
[ -f "$root_repo_dir/.gitbranches" ] && independent_branches=0
[ $independent_branches -eq 1 ] && branches_type=independent || branches_type=promotion
echo "branches: $branches_type"


# get list of branches for traversal and parent lineage used for merging
branch_array=()
declare -A parent_branch
discover_branches
echo ""
echoYellow "==== LINEAGE ===="
for src_branch in "${branch_array[@]}"; do
  echo "$src_branch < ${parent_branch[$src_branch]}"
done

# avoids forced prompt of merge request in case --no-edit is not supported
export GIT_MERGE_AUTOEDIT=no

# checkout branches with tracking back to origin
if [[ "$repo_type" == "fork" ]]; then
  populate_fork_branches
fi

while [[ 1 == 1 ]]; do
  echo ""
  echoYellow "==== [$repo_type] $origin_owner_repo > $branch ===="
  echo ""
  [ "$repo_type" == "fork" ] && show_fork_menu || show_central_menu

  echo ""
  read -p "choice (q=quit)? " answer

if [[ "$repo_type" == "fork" ]]; then
 
  case $answer in
  status)
    show_all_status
    ;;
  upstream)
    pull_from_upstream
    ;;
  branch)
    switch_branch
    ;;
  log)
    show_log
    ;;
  latest)
    show_latest_test_files
    ;;
  test)
    change_and_commit_test_file_current_branch "from $mixed_ownership fork"
    ;;
  push)
    do_push
    ;;
  createpr)
    create_pull_request_github "from $mixed_ownership fork"
    ;;
  createmr)
    create_merge_request_gitlab "from $mixed_ownership fork"
    ;;
  q)
    exit 0
    ;;
  *)
    echo "ERROR unrecognized command for fork repo"
    ;;
  esac

elif [[ "$repo_type" == "central" ]]; then

  case $answer in
  status)
    show_all_status
    ;;
  origin)
    sync_from_origin
    ;;
  branch)
    switch_branch
    ;;
  log)
    show_log
    ;;
  latest)
    show_latest_test_files
    ;;
  test)
    change_and_commit_test_file_current_branch "from central"
    ;;
  testall)
    if [[ $independent_branches -eq 1 ]]; then
      change_and_commit_test_file_all_independent_branches "i from central"
    else
      change_and_commit_test_file_all_promoted_branches "p from central"
    fi
    ;;
  push)
    do_push
    ;;
  pushall)
    git push --all
    git push --tags
    ;;
  mergepr)
    merge_pull_request_github
    ;;
  mergemr)
    merge_merge_request_gitlab
    ;;
  pin)
    tag_primary_branch "pin"
    ;;
  promote)
    #echo "promote   merge into branch '$branch' < '${parent_branch[$branch]}'"
    if [[ $independent_branches -eq 1 ]]; then
      merge_code_from_tag "pin-$branch"
    else
      merge_code_from_branch "${parent_branch[$branch]}"
    fi
    ;;
  promall)
    merge_cascade_promotional_branches
    ;;
  tag)
    tag_branch "tag-$branch"
    ;;
  q)
    exit 0
    ;;
  *)
    echo "ERROR unrecognized command for central repo"
    ;;
  esac

fi

done

