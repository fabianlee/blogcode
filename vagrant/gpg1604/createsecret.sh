#!/bin/bash

# create directory r/w only by root/sudo
sudo mkdir /etc/deployerkeys
sudo chmod 600 /etc/deployerkeys

# define input used to generate key
cat >genkeyinput <<EOF
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 2048
Name-Real: deployers
Expire-Date: 0
%no-protection
%commit
%echo done
EOF

# create private key
sudo gpg --batch --gen-key --homedir /etc/deployerkeys genkeyinput

# starts with spaces, so not saved to bash history
 echo -n "MyP4ss!" | sudo gpg --armor --batch --trust-model always --encrypt --homedir /etc/deployerkeys -r deployers > /tmp/test.crypt

