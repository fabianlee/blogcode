#!/bin/bash
#
# validates if ssh key and its pub key are matched 
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

# intentionally not using '-e' which echoes .pub file when it exists!
keyfingerprint=$(ssh-keygen -y -f $sshkeyfile | ssh-keygen -lf -)
echo "key: $keyfingerprint"

if [[ ! -f $sshpubfile ]]; then
  echo ""
  echo "WARNING: did not find pub file ${sshpubfile}, but here is what the public cert and fingerprint should be (based on the private key):"
  ssh-keygen -y -f $sshkeyfile
  echo ""
  ssh-keygen -y -f $sshkeyfile | ssh-keygen -l -f $sshkeyfile
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
justsha_key=$(echo $keyfingerprint | cut -d' ' -f2)
justsha_pub=$(echo $pubfingerprint | cut -d' ' -f2)
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


