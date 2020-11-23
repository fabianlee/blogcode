#!/bin/bash
#
# Shows untracked files in git repo
#
# more typical would be to simply use 'git status --ignored -s' or 'git ls-files --others'
# https://fabianlee.org/2020/11/22/git-identifying-files-that-gitignore-is-purposely-skipping/
#

global_allfiles=$(mktemp)
global_gitfiles=$(mktemp)

# all files in folder, no hidden folders
find . -type f -not -path '*/\.*' | sort > $global_allfiles

# all files in git already under source control
git ls-files | xargs -d '\n' printf "./%s\n" | sort > $global_gitfiles

comm $global_allfiles $global_gitfiles -2 | grep -v "^\s"

rm $global_allfiles
rm $global_gitfiles
