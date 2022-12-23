#!/bin/bash
#
# Create either github OR gitlb repo and create branch structure
#
# Branch structure:
# [main]    main.txt
# [dev]     overlays/dev/dev.txt
# [preprod] overlays/preprod/preprod.txt
# [prod]    overlays/prod/prod.txt
#
# Branches are treated either as:
# 1. independent branches - each with their own environment files
# 2. promotional branches - cascading changes from (main->dev->preprod->prod)
#

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

function choose_git_provider() {

[ -n "$git_provider" ] || read -p "github or gitlab provider? " git_provider

if [ "$git_provider" == "github" ]; then
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

elif [ "$git_provider" == "gitlab" ]; then
  the_bin=$(which glab)
  [ -n "$the_bin" ] || { echo "ERROR could not find gitlab CLI 'glab', see https://gitlab.com/gitlab-org/cli#linux"; exit 2; }

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

}

function ensure_main_branch_exists() {
  if [ "$git_provider" == "github" ]; then
    # if 'main' does not exist, then create
    git checkout main || git branch -M main
  elif [ "$git_provider" == "gitlab" ]; then
    # if 'main' does not exist, then create
    git checkout main || git branch -M main
  fi
}

function populate_independent_branches() {

  ensure_main_branch_exists
 
  # main branch
  git checkout main
  if [ ! -f "main.txt" ]; then
     echo "main value" > main.txt
     git add main.txt
     git commit -a -m "for main at $(date)"
  fi
  git push -u origin main
 
  # add tags for independent branches
  for thebranch in dev preprod prod; do 
    sleep 1
    echo "mod for $thebranch pin tag" >> main.txt
    git commit -m "for $thebranch at $(date)" main.txt
    git tag pin-$thebranch HEAD
  done
  git push --tags

  # other branches
  for thebranch in dev preprod prod; do 
    sleep 1

    # each branch starts from 'pin-*' tag on main, so each is independent
    git checkout -b $thebranch pin-$thebranch

    mkdir -p overlays/$thebranch
    if [ ! -f "overlays/$thebranch/$thebranch.txt" ]; then
      echo "$thebranch value" > overlays/$thebranch/$thebranch.txt
      git add overlays/$thebranch/$thebranch.txt
      git commit -a -m "for branch $thebranch at $(date)"
    fi
    git push -u origin $thebranch
  done

  # finish by showing all
  git checkout main
  git branch -avv
}

function populate_promotional_branches() {

  ensure_main_branch_exists
 
  # main branch
  git checkout main
  if [ ! -f ".gitbranches" ]; then
    cat <<EOF >.gitbranches
main<
dev<main
preprod<dev
prod<preprod
EOF
    git add .gitbranches
  fi

  if [ ! -f "main.txt" ]; then
     echo "main value" > main.txt
     git add main.txt
     git commit -a -m "for main at $(date)"
  fi
  git push -u origin main

  # other branches
  for thebranch in dev preprod prod; do 
    sleep 1

    # create branch from the current, which gives us dependent promotional concept
    git branch $thebranch; git checkout $thebranch

    mkdir -p overlays/$thebranch
    if [ ! -f "overlays/$thebranch/$thebranch.txt" ]; then
      echo "$thebranch value" > overlays/$thebranch/$thebranch.txt
      git add overlays/$thebranch/$thebranch.txt
      git commit -a -m "for branch $thebranch at $(date)"
    fi
    git push -u origin $thebranch
  done

  # finish by showing all
  git checkout main
  git branch -avv
  
}

### MAIN #####

# either github or gitlab
git_provider="$1"
choose_git_provider


while [ 1 -eq 1 ]; do

echo ""
echo "==== $git_provider as $username ===="
echo "list       list repositories"
echo "show       show local repository remotes"
echo "create     create repository"
echo "ibranch    populate with independent branches (main|dev|preprod|prod)"
echo "pbranch    populate with promotion branches (main>dev>preprod>prod)"
echo "clone      clone remote repository into local dir"
echo "fork       create personal fork of repository"
echo "delete     delete repository"
echo ""
read -p "choice (q=quit)? " answer

case $answer in

list)
if [ "$git_provider" == "github" ]; then
  gh repo list
  repo_list=$(gh repo list | grep "^$username/" | cut -f1 | cut -d'/' -f2)
  echo ""
elif [ "$git_provider" == "gitlab" ]; then
  glab repo list
  repo_list=$(glab repo list | grep "^$username/" | cut -f1 | cut -d'/' -f2)
fi

# show which repo are cloned locally
IFS=$'\n'
for therepo in $repo_list; do
  if [ -d "$therepo" ]; then
    echo "$therepo found locally"
  #else
  #  echo "$therepo NOT found locally"
  fi
done
;;

show)
read -p "Name of repository? " repository_name
if [ -d "$repository_name" ]; then
  cd $repository_name
  git remote -v
  git branch -avv
  cd ..
else
  echo "SKIP could not find repo $repository_name"
fi
;;


ibranch)
read -p "Name of repository? " repository_name
if [ ! -d "$repository_name" ]; then
  echo "ERROR no local repository for $repository_name"
  continue
fi
cd $repository_name
populate_independent_branches
cd ..
;;

pbranch)
read -p "Name of repository? " repository_name
if [ ! -d "$repository_name" ]; then
  echo "ERROR no local repository for $repository_name"
  continue
fi
cd $repository_name
populate_promotional_branches
cd ..
;;


create)
read -p "Name of repository? " repository_name
if [ "$git_provider" == "github" ]; then
  if gh repo list | grep -q "/${repository_name}"; then
    echo "ERROR github repository already exists with that name $repository_name"
    exit 5
  else
    gh repo create $repository_name --public --clone
  fi
elif [ "$git_provider" == "gitlab" ]; then
  if glab repo list | grep -q "${repository_name}.git"; then
    echo "ERROR gitlab repository already exists with that name $repository_name"
    exit 5
  else
    glab repo create $repository_name --public --defaultBranch main
    if [ -d $repository_name ]; then
       echo "modifying 'origin' so it uses https instead of ssh defaulted by glab"
       cd $repository_name
       git remote set-url origin https://gitlab.com/$username/$repository_name.git
       cd ..
    fi
  fi
fi
;;


clone)
read -p "Name of repository? " repository_name
if [ -d "$repository_name" ]; then
  echo "SKIP not going to clone because it appears that '$repository_name' has been cloned locally"
  cd $repository_name
  git remote -v
  cd ..
  continue
fi

if [ "$git_provider" == "github" ]; then
  gh repo clone $repository_name
elif [ "$git_provider" == "gitlab" ]; then
  glab repo clone $repository_name
fi
;;


fork)
read -p "Name of upstream repository or remote URL? " repository_name
read -p "Name of forked repo? " fork_name
if [ -d "$fork_name" ]; then
  echo "SKIP directory $fork_name already exists"
  continue
fi

if [ "$git_provider" == "github" ]; then
  gh repo fork $repository_name --fork-name $fork_name --clone
elif [ "$git_provider" == "gitlab" ]; then
  if echo $repository_name | grep -q "/"; then
    glab repo fork $repository_name --name $fork_name --path $fork_name --clone --remote
  else
    echo "no repo owner supplied, so using self: $username/repository_name"
    glab repo fork $username/$repository_name --name $fork_name --path $fork_name --clone --remote
  fi
fi
;;


delete)
read -p "Name of repository? " repository_name
if [ "$git_provider" == "github" ]; then
  gh repo delete $repository_name --confirm
elif [ "$git_provider" == "gitlab" ]; then
  glab repo delete $username/$repository_name -y
fi
# delete local directory also
if [ $? -eq 0 ]; then
  [ -d "$repository_name" ] && rm -fr $repository_name
fi
;;


q)
  exit 0
  ;;
*)
  echo "ERROR unrecognized command"
  ;;

esac


done
