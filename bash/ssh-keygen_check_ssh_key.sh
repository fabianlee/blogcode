#!/bin/bash
#
# validates if ssh key and its pub key are matched 
#
# this script works for both 'rsa' and 'ecdsa' types, examples:
#   ssh-keygen -t rsa -b 4096 -f $sshkeyfile -C test -N "" -q
#   ssh-keygen -t ecdsa -b 521 -f $sshkeyfile -C test -N "" -q
#

[[ -n "$1" ]] || { echo "Usage: sshKeyFile [sshPubFile]"; exit 1; }

sshkeyfile="$1"
if [[ -z "$2" ]]; then
  sshpubfile="${1}.pub"
else
  sshpubfile="$2"
fi

[[ -f $sshkeyfile ]] || { echo "ERROR: could not find ssh keyfile $sshkeyfile";exit 2; }
keyperms=$(stat -c '%a' $sshkeyfile)
if [[ $keyperms -gt 600 ]]; then
  echo "ERROR, the key permissions are > 600 for $sshkeyfile, use 'chmod 600'"
  exit 3
fi

keyfingerprint=$(ssh-keygen -l -f $sshkeyfile)
echo "key: $keyfingerprint"

if [[ ! -f $sshpubfile ]]; then
  echo ""
  echo "WARNING: did not find pub file '${sshpubfile}', but here is what the public cert should be (extracted from private key):"
  ssh-keygen -y -f $sshkeyfile -N ""
  exit 0
fi

pubperms=$(stat -c '%a' $sshpubfile)
echo $pubperms
gperm=$((pubperms % 100))
operm=$((pubperms % 10))
if [[ $pubperms -ge 700 || $gperm -ge 50 || $operm -ge 5 ]] ; then
  echo "ERROR, the file permissions are too wide for the public $sshpubfile, use 'chmod 644'"
  exit 3
fi
pubfingerprint=$(ssh-keygen -l -f $sshpubfile)
echo "pub: $pubfingerprint"

# do comparison without comment field
justsha_key=$(echo $keyfingerprint)
justsha_pub=$(echo $pubfingerprint)
#echo $justsha_key
#echo $justsha_pub
if [[ "$justsha_key" == "$justsha_pub" ]]; then
  echo "OK SHA fingerprint for ssh key and pub cert matched."
else
  echo "ERROR SHA fingerprint for ssh key and pub cert did not match!!!"
  echo ""
  echo "Based on the private key, here is what the .pub cert should be:"
  ssh-keygen -y -f $sshkeyfile
  exit 9
fi


