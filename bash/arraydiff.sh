#!/bin/bash
# 
# Example showing difference of two arrays
#

# calculates diff of array
# https://stackoverflow.com/questions/2312762/compare-difference-of-two-arrays-in-bash
function arraydiff() {
   awk 'BEGIN{RS=ORS=" "}
        {NR==FNR?a[$0]++:a[$0]--}
        END{for(k in a)if(a[k])print k}' <(echo -n "${!1}") <(echo -n "${!2}")
}

# given a list of OS packages
# use dpkg to find out which are installed on this host,
# then arraydiff to show which are not installed
function show_ubuntu_package_not_installed() {
  candidatepkgs="$1"
  echo "candidate package list: $candidatepkgs"

  # use dpgk to query for packages already installed
  alreadyinstalled=$(dpkg --get-selections $candidatepkgs 2>&1 | grep 'install$' | awk '{ print $1 }' | tr "\n" " ")
  echo "packages already installed: $alreadyinstalled"

  IFS=' ' read -r -a candidateArray <<< $candidatepkgs
  IFS=' ' read -r -a installedArray <<< $alreadyinstalled

  notInstalledArray=($(arraydiff candidateArray[@] installedArray[@]))
  echo "packages not yet installed:" ${notInstalledArray[@]}
}


#### MAIN #################

declare -a animals
declare -a mammals
declare -a nonmammals

# set of all animals, then mammals
animals=( "fox" "tiger" "alligator" "snake" "bear" )
mammals=( "fox" "tiger" "bear" )

# calculate difference in these sets
nonmammals=($(arraydiff animals[@] mammals[@]))

# show results
echo "======= Example of simple array difference ======="
echo "total set of animals:" ${animals[@]}
echo "mammals:" ${mammals[@]}
echo "non-mammals:" ${nonmammals[@]}

echo ""
if [ -f /etc/debian_version ]; then
  echo "======= Example of array difference using package list  ======="
  show_ubuntu_package_not_installed "vim fakepackage123 dos2unix"
else
  echo "sorry, the package difference example is written only for ubuntu"
fi






